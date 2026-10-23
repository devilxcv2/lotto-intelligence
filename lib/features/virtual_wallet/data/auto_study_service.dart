// lib/features/virtual_wallet/data/auto_study_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/prize_table.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_repository.dart';
import '../../draws/data/draw_repository.dart';
import '../../systems/domain/zoppe_system.dart';
import '../domain/auto_study.dart';
import 'wallet_repository.dart';

class AutoStudyCreateResult {
  const AutoStudyCreateResult.skipped(this.reason)
      : ticketId = null,
        numbers = const [],
        method = null;
  const AutoStudyCreateResult.created({
    required this.ticketId,
    required this.numbers,
    required this.method,
  }) : reason = null;

  final int? ticketId;
  final List<int> numbers;
  final AutoStudyMethod? method;
  final String? reason;

  bool get created => ticketId != null;
}

/// Crea al più una schedina di studio per il prossimo concorso aperto.
class AutoStudyService {
  AutoStudyService({
    required this.settingsRepository,
    required this.wallet,
    required this.draws,
  });

  final SettingsRepository settingsRepository;
  final WalletRepository wallet;
  final DrawRepository draws;

  Future<AutoStudyCreateResult> ensureTicket({DateTime? now, AppSettings? settings}) async {
    final clock = now ?? DateTime.now();
    final loaded = settings ?? await settingsRepository.load();
    if (!loaded.autoStudyEnabled) {
      return const AutoStudyCreateResult.skipped('Creazione automatica spenta.');
    }
    final target = nextOpenDrawDate(clock);
    final method = loaded.autoStudyMethod;
    if (await wallet.hasOpenAutoTicket(targetDrawDate: target, method: method)) {
      return const AutoStudyCreateResult.skipped('Schedina automatica già presente per questo concorso.');
    }
    final wheel = loaded.selectedWheelCode;
    final numbers = await _pickNumbers(wheel: wheel, method: method);
    if (numbers.length < 5) {
      return AutoStudyCreateResult.skipped(
        'Archivio insufficiente su $wheel per comporre ${method.label}.',
      );
    }
    final stakes = autoStudyStakes(amboCents: loaded.unitCostCents.clamp(stakeStepCents, 20000));
    final draft = TicketDraft(
      wheelCode: wheel,
      numbers: numbers,
      stakes: stakes,
      note: '${method.noteTag}. Creata dall\'app per il concorso. Nessun acquisto reale.',
    );
    final spent = await wallet.spentThisMonthCents(clock);
    final decision = wallet.assess(settings: loaded, spentThisMonthCents: spent, stakeCents: draft.stakeCents);
    if (!decision.allowed) {
      return AutoStudyCreateResult.skipped(decision.message ?? 'Budget simulato insufficiente.');
    }
    final id = await wallet.addTicket(draft, now: clock);
    return AutoStudyCreateResult.created(ticketId: id, numbers: numbers, method: method);
  }

  Future<List<int>> _pickNumbers({required String wheel, required AutoStudyMethod method}) async {
    final history = await draws.loadWheel(wheel);
    if (history.length < 30) return const [];
    if (method == AutoStudyMethod.zoppe) {
      final window = history.length < zoppeWindowDraws ? history.length : zoppeWindowDraws;
      final counted = frequencyAndDelay(history, window: window);
      final result = buildZoppeSystem(
        hits: counted.hits,
        delays: counted.delay,
        columnSize: 5,
        seed: DateTime.now().millisecondsSinceEpoch % 9973,
        windowDraws: window,
      );
      return result.leadColumn;
    }
    final stats = frequencyAndDelay(history, window: history.length < 100 ? history.length : 100);
    final ranked = [
      for (final number in stats.hits.keys)
        (number: number, hits: stats.hits[number] ?? 0, delay: stats.delay[number] ?? 0),
    ];
    if (method == AutoStudyMethod.delays) {
      ranked.sort((a, b) {
        final byDelay = b.delay.compareTo(a.delay);
        return byDelay != 0 ? byDelay : a.number.compareTo(b.number);
      });
    } else {
      ranked.sort((a, b) {
        final byHits = b.hits.compareTo(a.hits);
        return byHits != 0 ? byHits : a.number.compareTo(b.number);
      });
    }
    return [for (final item in ranked.take(5)) item.number]..sort();
  }
}

final autoStudyServiceProvider = Provider<AutoStudyService>((ref) {
  final db = ref.watch(databaseProvider);
  return AutoStudyService(
    settingsRepository: SettingsRepository(db),
    wallet: WalletRepository(db),
    draws: DrawRepository(db),
  );
});
