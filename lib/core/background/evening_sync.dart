// lib/core/background/evening_sync.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/draws/data/archive_sync_service.dart';
import '../../features/draws/data/draw_repository.dart';
import '../../features/superenalotto/data/se_ticket_repository.dart';
import '../../features/superenalotto/data/superenalotto_repository.dart';
import '../../features/superenalotto/data/superenalotto_sync.dart';
import '../../features/virtual_wallet/data/wallet_repository.dart';
import '../database/app_database.dart';
import '../lotto/freshness.dart';
import '../notifications/notification_service.dart';
import '../settings/settings_repository.dart';

/// Aggiornamento serale a app chiusa e promemoria pre-estrazione.
///
/// Nei giorni di estrazione:
/// - alle 19:00 notifica «estrazione imminente» (risultati non subito online);
/// - dalle 20:15 WorkManager scarica lo ZIP; se manca la data attesa riprova
///   ogni 20 minuti fino alle 23:00. Android può posticipare i task in Doze.
class EveningSync {
  EveningSync._();

  static const taskName = 'lotto.eveningSync';
  static const preDrawTaskName = 'lotto.preDrawReminder';
  static const uniqueName = 'lotto-evening-sync';
  static const retryUniqueName = 'lotto-evening-sync-retry';
  static const preDrawUniqueName = 'lotto-pre-draw-reminder';
  static const retryEvery = Duration(minutes: 20);
  static const lastRetryHour = 23;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  static Future<void> initialize() async {
    if (!supported) return;
    await Workmanager().initialize(eveningSyncDispatcher);
  }

  /// Programma controllo ZIP (20:15) e promemoria pre-estrazione (19:00).
  static Future<void> schedule({DateTime? now, DateTime? after}) async {
    if (!supported) return;
    final clock = now ?? DateTime.now();
    final target = nextCheckTime(after ?? clock);
    await Workmanager().registerOneOffTask(
      uniqueName,
      taskName,
      initialDelay: target.difference(clock),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
      inputData: const {'attempt': 0},
    );
    await schedulePreDraw(now: clock);
  }

  static Future<void> schedulePreDraw({DateTime? now}) async {
    if (!supported) return;
    final clock = now ?? DateTime.now();
    final target = nextPreDrawTime(clock);
    await Workmanager().registerOneOffTask(
      preDrawUniqueName,
      preDrawTaskName,
      initialDelay: target.difference(clock),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: const {},
    );
  }

  static Future<void> cancel() async {
    if (!supported) return;
    await Workmanager().cancelByUniqueName(uniqueName);
    await Workmanager().cancelByUniqueName(retryUniqueName);
    await Workmanager().cancelByUniqueName(preDrawUniqueName);
  }

  /// Prossimo istante locale di controllo ZIP: 20:15 del giorno di estrazione.
  static DateTime nextCheckTime(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (isDrawWeekday(day)) {
      final today = DateTime(day.year, day.month, day.day, archiveCheckHour, archiveCheckMinute);
      if (today.isAfter(now)) return today;
    }
    do {
      day = day.add(const Duration(days: 1));
    } while (!isDrawWeekday(day));
    return DateTime(day.year, day.month, day.day, archiveCheckHour, archiveCheckMinute);
  }

  /// Prossimo promemoria alle 19:00 di un giorno di estrazione.
  static DateTime nextPreDrawTime(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (isDrawWeekday(day)) {
      final today = DateTime(day.year, day.month, day.day, preDrawReminderHour, preDrawReminderMinute);
      if (today.isAfter(now)) return today;
    }
    do {
      day = day.add(const Duration(days: 1));
    } while (!isDrawWeekday(day));
    return DateTime(day.year, day.month, day.day, preDrawReminderHour, preDrawReminderMinute);
  }

  /// Corpo del task ZIP. Separato dal dispatcher per i test.
  static Future<EveningSyncResult> runOnce({
    required AppDatabase db,
    required Dio dio,
    required DateTime now,
    required NotificationService? notifications,
  }) async {
    final settings = await SettingsRepository(db).load();
    if (!settings.liveSyncEnabled) return const EveningSyncResult.skipped('Aggiornamento serale disattivato.');
    final repository = DrawRepository(db);
    final wallet = WalletRepository(db);
    final before = await repository.summary(now: now);
    if (settings.notificationsEnabled) {
      final expected = isDrawWeekday(now) ? DateTime(now.year, now.month, now.day) : expectedPublishedDrawDate(now);
      await notifications?.showArchiveCheckStarted(drawDate: expected);
    }
    final service = ArchiveSyncService(repository: repository, wallet: wallet, dio: dio);
    final outcome = await service.syncOfficial();
    final after = await repository.summary(now: now);
    var superInserted = 0;
    var superTickets = 0;
    try {
      final superReport = await syncSuperenalottoLatest(repository: SuperenalottoRepository(db), dio: dio);
      superInserted = superReport.inserted;
      superTickets = await SeTicketRepository(db).evaluateOpen();
    } catch (_) {
      // La pagina del SuperEnalotto non deve far fallire lo ZIP del Lotto.
    }
    final newDraw = after.latestDate != null && (before.latestDate == null || after.latestDate!.isAfter(before.latestDate!));
    if (newDraw || superInserted > 0 || superTickets > 0) {
      var net = 0, staked = 0;
      for (final ticket in outcome.evaluatedTickets) {
        net += ticket.evaluation?.netCents ?? 0;
        staked += ticket.stakeCents;
      }
      if (settings.notificationsEnabled) {
        await notifications?.showNewDraw(
          drawDate: after.latestDate ?? now,
          inserted: outcome.report.inserted,
          evaluatedTickets: outcome.evaluatedTickets.length,
          netCents: net,
          stakedCents: staked,
          superInserted: superInserted,
          superTickets: superTickets,
        );
      }
      if (newDraw) return EveningSyncResult.newDraw(after.latestDate!.toUtc(), outcome.evaluatedTickets.length);
    }
    final stillWaiting = after.freshness == SourceFreshness.delayed && now.hour < lastRetryHour;
    return stillWaiting ? const EveningSyncResult.retryLater() : const EveningSyncResult.skipped('Nessuna nuova estrazione.');
  }

  static Future<void> runPreDrawReminder({
    required AppDatabase db,
    required DateTime now,
    required NotificationService? notifications,
  }) async {
    final settings = await SettingsRepository(db).load();
    if (!settings.notificationsEnabled) return;
    if (!isDrawWeekday(now)) return;
    await notifications?.showPreDrawReminder(drawDate: DateTime(now.year, now.month, now.day));
  }

  static Future<void> _scheduleRetry(int attempt) async {
    await Workmanager().registerOneOffTask(
      retryUniqueName,
      taskName,
      initialDelay: retryEvery,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {'attempt': attempt},
    );
  }
}

class EveningSyncResult {
  const EveningSyncResult.skipped(this.reason)
      : newDrawDate = null,
        evaluatedTickets = 0,
        retry = false;
  const EveningSyncResult.newDraw(this.newDrawDate, this.evaluatedTickets)
      : reason = null,
        retry = false;
  const EveningSyncResult.retryLater()
      : reason = null,
        newDrawDate = null,
        evaluatedTickets = 0,
        retry = true;

  final String? reason;
  final DateTime? newDrawDate;
  final int evaluatedTickets;
  final bool retry;
}

/// Entry point eseguito da WorkManager su un isolate separato.
@pragma('vm:entry-point')
void eveningSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = await AppDatabase.openDefault();
    try {
      final now = DateTime.now();
      if (task == EveningSync.preDrawTaskName) {
        await EveningSync.runPreDrawReminder(
          db: db,
          now: now,
          notifications: NotificationService.instance,
        );
        await EveningSync.schedulePreDraw(now: DateTime(now.year, now.month, now.day, 23, 59));
        return true;
      }
      if (task != EveningSync.taskName) return true;
      final attempt = (inputData?['attempt'] as int?) ?? 0;
      final result = await EveningSync.runOnce(
        db: db,
        dio: Dio(BaseOptions(connectTimeout: const Duration(seconds: 20), receiveTimeout: const Duration(seconds: 90))),
        now: now,
        notifications: NotificationService.instance,
      );
      if (result.retry && attempt < 8) {
        await EveningSync._scheduleRetry(attempt + 1);
      }
      await EveningSync.schedule(now: now, after: DateTime(now.year, now.month, now.day, 23, 59));
      return true;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}
