// lib/features/virtual_wallet/data/wallet_repository.dart

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/prize_table.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';

class BudgetDecision {
  const BudgetDecision.allowed() : allowed = true, message = null;
  const BudgetDecision.blocked(this.message) : allowed = false;

  final bool allowed;
  final String? message;
}

/// Esito registrato di una schedina.
class TicketEvaluation {
  const TicketEvaluation({
    required this.evaluatedAt,
    required this.drawDate,
    required this.hits,
    required this.grossCents,
    required this.netCents,
    required this.hitsByWheel,
    required this.grossBySorte,
    required this.note,
  });

  final DateTime evaluatedAt;
  final DateTime? drawDate;
  final int hits;
  final int grossCents;
  final int netCents;
  final Map<String, int> hitsByWheel;
  final Map<LottoSorte, int> grossBySorte;
  final String note;
}

class StoredTicket {
  const StoredTicket({
    required this.id,
    required this.wheelCode,
    required this.stakeCents,
    required this.stakes,
    required this.createdAt,
    required this.targetDrawDate,
    required this.status,
    required this.numbers,
    required this.note,
    required this.strategyId,
    required this.evaluation,
  });

  final int id;
  final String wheelCode;
  final int stakeCents;
  final Map<LottoSorte, int> stakes;
  final DateTime createdAt;
  final DateTime? targetDrawDate;
  final String status;
  final List<int> numbers;
  final String? note;
  final int? strategyId;
  final TicketEvaluation? evaluation;

  bool get isOpen => status == 'open';
  bool get isLegacy => status == 'legacy';
  bool get coversAllWheels => wheelCode == allWheelsCode;
  int get wheelsCovered => coversAllWheels ? 10 : 1;

  /// Netto meno posta; null finché non c'è un esito con importi.
  int? get balanceCents => evaluation == null || isLegacy ? null : evaluation!.netCents - stakeCents;
}

class WalletSummary {
  const WalletSummary({
    required this.openCount,
    required this.evaluatedCount,
    required this.legacyCount,
    required this.stakedCents,
    required this.openStakeCents,
    required this.grossCents,
    required this.netCents,
    required this.winningTickets,
    required this.bestNetCents,
    required this.timeline,
  });

  final int openCount;
  final int evaluatedCount;
  final int legacyCount;

  /// Posta delle schedine già valutate.
  final int stakedCents;
  final int openStakeCents;
  final int grossCents;
  final int netCents;
  final int winningTickets;
  final int bestNetCents;

  /// Saldo cumulato (netto meno poste) dopo ogni schedina valutata.
  final List<({DateTime date, int balanceCents})> timeline;

  int get balanceCents => netCents - stakedCents;
  double? get returnRatio => stakedCents == 0 ? null : netCents / stakedCents;
}

class TicketDraft {
  const TicketDraft({
    required this.wheelCode,
    required this.numbers,
    required this.stakes,
    this.strategyId,
    this.note,
  });

  final String wheelCode;
  final List<int> numbers;
  final Map<LottoSorte, int> stakes;
  final int? strategyId;
  final String? note;

  int get stakeCents => stakes.values.fold(0, (sum, value) => sum + value);

  /// Messaggio di errore oppure null se la schedina è registrabile.
  String? problem() {
    if (numbers.isEmpty) return 'Scegli almeno un numero.';
    if (numbers.length > maxTicketNumbers) return 'Al massimo $maxTicketNumbers numeri.';
    if (numbers.toSet().length != numbers.length) return 'Ci sono numeri ripetuti.';
    if (numbers.any((n) => n < 1 || n > 90)) return 'I numeri vanno da 1 a 90.';
    if (wheelCode != allWheelsCode && wheelByCode(wheelCode) == null) return 'Ruota sconosciuta.';
    final active = stakes.entries.where((entry) => entry.value > 0).toList();
    if (active.isEmpty) return 'Indica una posta su almeno una sorte.';
    for (final entry in active) {
      if (entry.value % stakeStepCents != 0) return 'La posta su ${entry.key.label} deve crescere a passi di 0,50 €.';
      if (numbers.length < entry.key.hitsRequired) {
        return 'Per ${entry.key.label.toLowerCase()} servono almeno ${entry.key.hitsRequired} numeri.';
      }
    }
    return stakeProblem(stakeCents);
  }
}

class WalletRepository {
  WalletRepository(this._db);

  final AppDatabase _db;

  BudgetDecision assess({
    required AppSettings settings,
    required int spentThisMonthCents,
    required int stakeCents,
  }) {
    if (stakeCents <= 0) {
      return const BudgetDecision.blocked('La spesa simulata deve essere maggiore di zero.');
    }
    if (!settings.budgetMode.enforcesLimits) {
      return const BudgetDecision.allowed();
    }
    if (stakeCents > settings.contestBudgetCents) {
      return const BudgetDecision.blocked('Questa schedina supera il budget simulato per concorso. Il limite non viene alzato in automatico.');
    }
    if (spentThisMonthCents + stakeCents > settings.monthlyBudgetCents) {
      return const BudgetDecision.blocked('Il budget simulato del mese è esaurito. La registrazione è bloccata.');
    }
    if (spentThisMonthCents + stakeCents > settings.virtualCapitalCents) {
      return const BudgetDecision.blocked('Il capitale simulato non copre questa schedina.');
    }
    return const BudgetDecision.allowed();
  }

  Future<int> spentThisMonthCents(DateTime now) async {
    final start = DateTime.utc(now.year, now.month);
    final end = DateTime.utc(now.year, now.month + 1);
    final row = await _db.customSelect(
      'SELECT COALESCE(SUM(stake_cents), 0) AS s FROM virtual_tickets WHERE created_at >= ? AND created_at < ?',
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
      readsFrom: {_db.virtualTickets},
    ).getSingle();
    return row.read<int>('s');
  }

  /// Registra la schedina per il prossimo concorso aperto. Nessun acquisto.
  Future<int> addTicket(TicketDraft draft, {DateTime? now}) async {
    final problem = draft.problem();
    if (problem != null) throw StateError(problem);
    final clock = now ?? DateTime.now();
    return _db.transaction(() async {
      final id = await _db.into(_db.virtualTickets).insert(VirtualTicketsCompanion.insert(
            wheelCode: draft.wheelCode,
            stakeCents: draft.stakeCents,
            createdAt: clock.toUtc(),
            strategyId: Value(draft.strategyId),
            note: Value(draft.note ?? 'Schedina ipotetica. Nessun acquisto.'),
            stakeEstrattoCents: Value(draft.stakes[LottoSorte.estratto] ?? 0),
            stakeAmboCents: Value(draft.stakes[LottoSorte.ambo] ?? 0),
            stakeTernoCents: Value(draft.stakes[LottoSorte.terno] ?? 0),
            stakeQuaternaCents: Value(draft.stakes[LottoSorte.quaterna] ?? 0),
            stakeCinquinaCents: Value(draft.stakes[LottoSorte.cinquina] ?? 0),
            targetDrawDate: Value(nextOpenDrawDate(clock)),
            status: const Value('open'),
          ));
      await _db.batch((batch) {
        batch.insertAll(_db.ticketNumbers, [
          for (var i = 0; i < draft.numbers.length; i++)
            TicketNumbersCompanion.insert(ticketId: id, position: i + 1, number: draft.numbers[i]),
        ]);
      });
      return id;
    });
  }

  Future<void> deleteTicket(int id) {
    return (_db.delete(_db.virtualTickets)..where((row) => row.id.equals(id))).go();
  }

  Future<List<StoredTicket>> list() async {
    final tickets = await (_db.select(_db.virtualTickets)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt), (row) => OrderingTerm.desc(row.id)]))
        .get();
    final numbers = await (_db.select(_db.ticketNumbers)..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    final results = await (_db.select(_db.ticketResults)..orderBy([(row) => OrderingTerm.desc(row.evaluatedAt)])).get();
    final drawIds = results.map((row) => row.drawId).whereType<int>().toSet();
    final drawDates = <int, DateTime>{};
    if (drawIds.isNotEmpty) {
      final draws = await (_db.select(_db.draws)..where((row) => row.id.isIn(drawIds))).get();
      for (final draw in draws) {
        drawDates[draw.id] = draw.drawDate;
      }
    }
    final numbersByTicket = <int, List<int>>{};
    for (final number in numbers) {
      numbersByTicket.putIfAbsent(number.ticketId, () => []).add(number.number);
    }
    final latestResult = <int, TicketResultRow>{};
    for (final result in results) {
      latestResult.putIfAbsent(result.ticketId, () => result);
    }
    return [
      for (final ticket in tickets)
        StoredTicket(
          id: ticket.id,
          wheelCode: ticket.wheelCode,
          stakeCents: ticket.stakeCents,
          stakes: _stakesOf(ticket),
          createdAt: ticket.createdAt,
          targetDrawDate: ticket.targetDrawDate?.toUtc(),
          status: ticket.status,
          numbers: numbersByTicket[ticket.id] ?? const [],
          note: ticket.note,
          strategyId: ticket.strategyId,
          evaluation: _evaluationOf(latestResult[ticket.id], drawDates),
        ),
    ];
  }

  /// Valuta le schedine aperte il cui concorso è ormai in archivio.
  /// Restituisce quelle valutate in questa chiamata.
  Future<List<StoredTicket>> evaluateOpenTickets() async {
    final open = await (_db.select(_db.virtualTickets)
          ..where((row) => row.status.equals('open') & row.targetDrawDate.isNotNull()))
        .get();
    if (open.isEmpty) return const [];
    final evaluatedIds = <int>[];
    final byDate = <DateTime, List<VirtualTicketRow>>{};
    for (final ticket in open) {
      byDate.putIfAbsent(ticket.targetDrawDate!.toUtc(), () => []).add(ticket);
    }
    for (final entry in byDate.entries) {
      final published = await _drawsOn(entry.key);
      if (published.isEmpty) continue;
      for (final ticket in entry.value) {
        final wheels = ticket.wheelCode == allWheelsCode
            ? [for (final wheel in officialWheels) if (wheel.code != 'RN') wheel.code]
            : [ticket.wheelCode];
        if (wheels.any((code) => !published.containsKey(code))) continue;
        final numbers = await (_db.select(_db.ticketNumbers)
              ..where((row) => row.ticketId.equals(ticket.id))
              ..orderBy([(row) => OrderingTerm.asc(row.position)]))
            .get();
        final outcome = evaluateTicket(
          played: [for (final row in numbers) row.number],
          stakes: _stakesOf(ticket),
          drawnByWheel: {for (final code in wheels) code: published[code]!.numbers},
        );
        await _db.transaction(() async {
          await _db.into(_db.ticketResults).insert(TicketResultsCompanion.insert(
                ticketId: ticket.id,
                drawId: Value(wheels.length == 1 ? published[wheels.single]!.drawId : null),
                evaluatedAt: DateTime.now().toUtc(),
                hits: Value(outcome.bestHits),
                grossCents: Value(outcome.grossCents),
                netCents: Value(outcome.netCents),
                outcomeNote: 'Esito calcolato con la tabella premi pubblicata (ritenuta 8%). Nessuna vincita reale.',
                detailJson: Value(jsonEncode({
                  'hitsByWheel': outcome.hitsByWheel,
                  'grossBySorte': {for (final item in outcome.perSorte) item.sorte.name: item.grossCents},
                  'drawDate': formatIsoDate(entry.key),
                })),
              ));
          await (_db.update(_db.virtualTickets)..where((row) => row.id.equals(ticket.id)))
              .write(const VirtualTicketsCompanion(status: Value('evaluated')));
        });
        evaluatedIds.add(ticket.id);
      }
    }
    if (evaluatedIds.isEmpty) return const [];
    final all = await list();
    return [for (final ticket in all) if (evaluatedIds.contains(ticket.id)) ticket];
  }

  Future<WalletSummary> summary() async {
    final tickets = await list();
    var openCount = 0, evaluatedCount = 0, legacyCount = 0;
    var staked = 0, openStake = 0, gross = 0, net = 0, winners = 0, best = 0;
    final evaluated = <StoredTicket>[];
    for (final ticket in tickets) {
      if (ticket.isLegacy) {
        legacyCount++;
      } else if (ticket.isOpen) {
        openCount++;
        openStake += ticket.stakeCents;
      } else if (ticket.evaluation != null) {
        evaluatedCount++;
        staked += ticket.stakeCents;
        gross += ticket.evaluation!.grossCents;
        net += ticket.evaluation!.netCents;
        if (ticket.evaluation!.netCents > 0) winners++;
        if (ticket.evaluation!.netCents > best) best = ticket.evaluation!.netCents;
        evaluated.add(ticket);
      }
    }
    evaluated.sort((a, b) {
      final byDate = (a.targetDrawDate ?? a.createdAt).compareTo(b.targetDrawDate ?? b.createdAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    var running = 0;
    final timeline = <({DateTime date, int balanceCents})>[];
    for (final ticket in evaluated) {
      running += ticket.evaluation!.netCents - ticket.stakeCents;
      timeline.add((date: ticket.targetDrawDate ?? ticket.createdAt, balanceCents: running));
    }
    return WalletSummary(
      openCount: openCount,
      evaluatedCount: evaluatedCount,
      legacyCount: legacyCount,
      stakedCents: staked,
      openStakeCents: openStake,
      grossCents: gross,
      netCents: net,
      winningTickets: winners,
      bestNetCents: best,
      timeline: timeline,
    );
  }

  Future<Map<String, ({int drawId, List<int> numbers})>> _drawsOn(DateTime date) async {
    final rows = await _db.customSelect(
      'SELECT d.id AS id, w.code AS code, n.number AS number FROM draws d '
      'JOIN wheels w ON w.id = d.wheel_id JOIN draw_numbers n ON n.draw_id = d.id '
      'WHERE d.draw_date = ? ORDER BY d.id, n.position',
      variables: [Variable.withDateTime(date)],
      readsFrom: {_db.draws, _db.wheels, _db.drawNumbers},
    ).get();
    final result = <String, ({int drawId, List<int> numbers})>{};
    for (final row in rows) {
      final code = row.read<String>('code');
      final existing = result[code];
      if (existing == null) {
        result[code] = (drawId: row.read<int>('id'), numbers: [row.read<int>('number')]);
      } else {
        existing.numbers.add(row.read<int>('number'));
      }
    }
    result.removeWhere((_, value) => value.numbers.length != 5);
    return result;
  }

  Map<LottoSorte, int> _stakesOf(VirtualTicketRow row) => {
        LottoSorte.estratto: row.stakeEstrattoCents,
        LottoSorte.ambo: row.stakeAmboCents,
        LottoSorte.terno: row.stakeTernoCents,
        LottoSorte.quaterna: row.stakeQuaternaCents,
        LottoSorte.cinquina: row.stakeCinquinaCents,
      };

  TicketEvaluation? _evaluationOf(TicketResultRow? row, Map<int, DateTime> drawDates) {
    if (row == null) return null;
    Map<String, dynamic> detail = const {};
    if (row.detailJson != null) {
      final decoded = jsonDecode(row.detailJson!);
      if (decoded is Map<String, dynamic>) detail = decoded;
    }
    final hitsByWheel = <String, int>{};
    if (detail['hitsByWheel'] is Map) {
      for (final entry in (detail['hitsByWheel'] as Map).entries) {
        hitsByWheel['${entry.key}'] = (entry.value as num).toInt();
      }
    }
    final grossBySorte = <LottoSorte, int>{};
    if (detail['grossBySorte'] is Map) {
      for (final entry in (detail['grossBySorte'] as Map).entries) {
        final sorte = LottoSorte.values.where((item) => item.name == entry.key);
        if (sorte.isNotEmpty) grossBySorte[sorte.first] = (entry.value as num).toInt();
      }
    }
    DateTime? drawDate = row.drawId == null ? null : drawDates[row.drawId];
    if (drawDate == null && detail['drawDate'] is String) {
      drawDate = DateTime.tryParse('${detail['drawDate']}T00:00:00Z');
    }
    return TicketEvaluation(
      evaluatedAt: row.evaluatedAt,
      drawDate: drawDate?.toUtc(),
      hits: row.hits ?? 0,
      grossCents: row.grossCents ?? 0,
      netCents: row.netCents ?? 0,
      hitsByWheel: hitsByWheel,
      grossBySorte: grossBySorte,
      note: row.outcomeNote,
    );
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(databaseProvider));
});

final ticketsProvider = FutureProvider<List<StoredTicket>>((ref) {
  return ref.watch(walletRepositoryProvider).list();
});

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) {
  return ref.watch(walletRepositoryProvider).summary();
});
