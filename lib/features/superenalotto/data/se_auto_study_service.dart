// lib/features/superenalotto/data/se_auto_study_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_repository.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/zoppe_system.dart';
import '../../virtual_wallet/domain/auto_study.dart';
import '../domain/superenalotto_studio.dart';
import 'se_ticket_repository.dart';
import 'superenalotto_repository.dart';

class SeAutoCreateResult {
  const SeAutoCreateResult({required this.created, required this.skipped});

  final List<({AutoStudyMethod method, List<int> numbers, int? superstar})> created;
  final List<String> skipped;

  bool get anyCreated => created.isNotEmpty;
}

/// Crea fino a tre schedine SE (Zoppe, ritardi, frequenti) per confrontare i trend.
class SeAutoStudyService {
  SeAutoStudyService({
    required this.settingsRepository,
    required this.tickets,
    required this.draws,
  });

  final SettingsRepository settingsRepository;
  final SeTicketRepository tickets;
  final SuperenalottoRepository draws;

  Future<SeAutoCreateResult> ensureTickets({DateTime? now, AppSettings? settings}) async {
    final clock = now ?? DateTime.now();
    final loaded = settings ?? await settingsRepository.load();
    if (!loaded.autoSeEnabled) {
      return const SeAutoCreateResult(created: [], skipped: ['Auto SuperEnalotto spento.']);
    }
    final history = await draws.history();
    if (history.length < 30) {
      return const SeAutoCreateResult(created: [], skipped: ['Archivio SuperEnalotto insufficiente (servono ≥ 30 concorsi).']);
    }
    final target = nextOpenDrawDate(clock);
    final created = <({AutoStudyMethod method, List<int> numbers, int? superstar})>[];
    final skipped = <String>[];
    for (final method in AutoStudyMethod.values) {
      if (await tickets.hasOpenAuto(targetDrawDate: target, method: method)) {
        skipped.add('${method.label}: già presente.');
        continue;
      }
      final pick = _pick(history, method, seed: clock.millisecondsSinceEpoch + method.index * 17);
      if (pick.numbers.length != 6) {
        skipped.add('${method.label}: numeri non disponibili.');
        continue;
      }
      try {
        await tickets.add(
          numbers: pick.numbers,
          superstar: pick.superstar,
          origin: method.noteTag,
          note: 'Creata dall\'app per confrontare i trend. Nessun acquisto reale.',
          now: clock,
        );
        created.add((method: method, numbers: pick.numbers, superstar: pick.superstar));
      } catch (error) {
        skipped.add('${method.label}: $error');
      }
    }
    return SeAutoCreateResult(created: created, skipped: skipped);
  }

  ({List<int> numbers, int? superstar}) _pick(List<SuperenalottoDraw> chronological, AutoStudyMethod method, {required int seed}) {
    final stats = superenalottoStats(chronological);
    if (method == AutoStudyMethod.delays) {
      final delayed = [...stats]..sort((a, b) {
          final byDelay = b.delay.compareTo(a.delay);
          return byDelay != 0 ? byDelay : a.number.compareTo(b.number);
        });
      final numbers = [for (final stat in delayed.take(6)) stat.number]..sort();
      return (numbers: numbers, superstar: suggestSuperstar(chronological).number);
    }
    if (method == AutoStudyMethod.frequent) {
      final window = chronological.length <= 100 ? chronological : chronological.sublist(chronological.length - 100);
      final recent = superenalottoStats(window);
      final frequent = [...recent]..sort((a, b) {
          final byHits = b.hits.compareTo(a.hits);
          return byHits != 0 ? byHits : a.number.compareTo(b.number);
        });
      final numbers = [for (final stat in frequent.take(6)) stat.number]..sort();
      return (numbers: numbers, superstar: suggestSuperstar(chronological).number);
    }
    final asDraws = [
      for (final draw in chronological) ArchivedDraw(date: draw.date, numbers: draw.numbers),
    ];
    final windowDraws = asDraws.length <= 100 ? asDraws : asDraws.sublist(asDraws.length - 100);
    final counted = frequencyAndDelay(windowDraws);
    final zoppe = buildZoppeSystem(
      hits: counted.hits,
      delays: counted.delay,
      columnSize: 6,
      seed: seed % 9973,
      windowDraws: windowDraws.length,
    );
    final six = zoppe.leadColumn;
    if (six.length != 6) return (numbers: const [], superstar: null);
    return (numbers: six, superstar: suggestSuperstar(chronological).number);
  }
}

final seAutoStudyServiceProvider = Provider<SeAutoStudyService>((ref) {
  final db = ref.watch(databaseProvider);
  return SeAutoStudyService(
    settingsRepository: SettingsRepository(db),
    tickets: SeTicketRepository(db),
    draws: SuperenalottoRepository(db),
  );
});
