// lib/app/lotto_app.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/evening_sync.dart';
import '../core/lotto/freshness.dart';
import '../core/notifications/notification_service.dart';
import '../core/settings/settings_controller.dart';
import '../features/draws/data/archive_sync.dart';
import '../features/draws/data/draw_repository.dart';
import '../features/superenalotto/data/se_auto_study_service.dart';
import '../features/superenalotto/data/se_ticket_repository.dart';
import '../features/superenalotto/data/superenalotto_sync.dart';
import '../features/virtual_wallet/data/auto_study_service.dart';
import '../features/virtual_wallet/data/wallet_repository.dart';
import '../features/virtual_wallet/domain/auto_study.dart';
import 'result_notice.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Rotta da aprire dopo lo splash perché l'app è partita da una notifica.
final launchRouteProvider = StateProvider<String?>((ref) => null);

class LottoApp extends ConsumerWidget {
  const LottoApp({this.launchRoute, super.key});

  final String? launchRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsControllerProvider).value?.themeMode ?? ThemeMode.dark;
    if (launchRoute != null && ref.read(launchRouteProvider) == null) {
      Future.microtask(() => ref.read(launchRouteProvider.notifier).state = launchRoute);
    }
    return MaterialApp.router(
      title: 'Lotto Intelligence AI',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => LiveSyncHost(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Coordina aggiornamento serale in app, task WorkManager, ritorno in
/// primo piano e tocco sulle notifiche.
class LiveSyncHost extends ConsumerStatefulWidget {
  const LiveSyncHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LiveSyncHost> createState() => _LiveSyncHostState();
}

class _LiveSyncHostState extends ConsumerState<LiveSyncHost> with WidgetsBindingObserver {
  Timer? _timer;
  (bool, bool)? _applied;
  var _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.tappedRoute.addListener(_onNotificationTap);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.tappedRoute.removeListener(_onNotificationTap);
    _timer?.cancel();
    super.dispose();
  }

  void _onNotificationTap() {
    final route = NotificationService.instance.tappedRoute.value;
    if (route == null) return;
    NotificationService.instance.tappedRoute.value = null;
    ref.read(routerProvider).go(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    ref.invalidate(archiveSummaryProvider);
    ref.invalidate(wheelDrawsProvider);
    unawaited(_evaluateTickets(showPopup: true));
    unawaited(_ensureAutoStudy());
    unawaited(_tick());
  }

  Future<void> _evaluateTickets({required bool showPopup}) async {
    final evaluated = await ref.read(walletRepositoryProvider).evaluateOpenTickets();
    if (evaluated.isEmpty) return;
    ref.invalidate(ticketsProvider);
    ref.invalidate(walletSummaryProvider);
    if (showPopup) publishTicketEvaluations(ref, evaluated);
    final settings = ref.read(settingsControllerProvider).value;
    if (settings?.notificationsEnabled == true) {
      final wins = evaluated.where((ticket) => (ticket.evaluation?.netCents ?? 0) > 0).length;
      final net = evaluated.fold<int>(0, (sum, ticket) => sum + (ticket.evaluation?.netCents ?? 0));
      final staked = evaluated.fold<int>(0, (sum, ticket) => sum + ticket.stakeCents);
      await NotificationService.instance.showTicketEvaluations(
        count: evaluated.length,
        wins: wins,
        netCents: net,
        stakedCents: staked,
      );
    }
  }

  Future<void> _ensureAutoStudy() async {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings == null) return;
    if (settings.autoStudyEnabled) {
      final result = await ref.read(autoStudyServiceProvider).ensureTicket(settings: settings);
      if (result.created) {
        ref.invalidate(ticketsProvider);
        ref.invalidate(walletSummaryProvider);
        if (settings.notificationsEnabled) {
          await NotificationService.instance.showAutoTicketCreated(
            methodLabel: result.method!.label,
            wheelCode: settings.selectedWheelCode,
            numbers: result.numbers,
            targetDrawDate: nextOpenDrawDate(DateTime.now()),
          );
        }
      }
    }
    if (settings.autoSeEnabled) {
      final se = await ref.read(seAutoStudyServiceProvider).ensureTickets(settings: settings);
      if (se.anyCreated) {
        ref.invalidate(seTicketsProvider);
        if (settings.notificationsEnabled && se.created.isNotEmpty) {
          final first = se.created.first;
          await NotificationService.instance.showAutoTicketCreated(
            methodLabel: 'SE · ${se.created.length} strategie',
            wheelCode: 'SE',
            numbers: first.numbers,
            targetDrawDate: nextOpenDrawDate(DateTime.now()),
          );
        }
      }
    }
  }

  void _applySchedule({required bool liveSync, required bool notifications}) {
    final next = (liveSync, notifications);
    if (_applied == next) return;
    _applied = next;
    if (notifications || liveSync) {
      unawaited(NotificationService.instance.requestPermission());
    }
    if (liveSync) {
      unawaited(EveningSync.schedule());
      _timer ??= Timer.periodic(const Duration(minutes: 15), (_) => _tick());
      return;
    }
    unawaited(EveningSync.cancel());
    if (notifications) unawaited(EveningSync.schedulePreDraw());
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings == null || !settings.liveSyncEnabled) return;
    final now = DateTime.now();
    if (!isDrawWeekday(now) || now.hour < archiveCheckHour || now.hour > 23) return;
    if (ref.read(archiveSyncProvider).running) return;
    final summary = await ref.read(drawRepositoryProvider).summary(now: now);
    if (summary.freshness == SourceFreshness.delayed || summary.freshness == SourceFreshness.unverified) {
      await ref.read(archiveSyncProvider.notifier).syncOfficial();
    }
    if (!ref.read(superenalottoSyncProvider).running) {
      await ref.read(superenalottoSyncProvider.notifier).syncLatest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    if (settings != null) {
      _applySchedule(liveSync: settings.liveSyncEnabled, notifications: settings.notificationsEnabled);
      if (!_bootstrapped) {
        _bootstrapped = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_ensureAutoStudy());
          unawaited(_evaluateTickets(showPopup: true));
        });
      }
    }
    return widget.child;
  }
}
