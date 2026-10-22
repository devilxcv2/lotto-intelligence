// lib/features/superenalotto/data/se_ticket_repository.dart

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../domain/superenalotto_studio.dart';

class SeTicket {
  const SeTicket({
    required this.id,
    required this.numbers,
    required this.superstar,
    required this.targetDrawDate,
    required this.status,
    required this.origin,
    required this.note,
    required this.createdAt,
    required this.match,
    required this.contestNumber,
  });

  final int id;
  final List<int> numbers;
  final int? superstar;
  final DateTime targetDrawDate;
  final String status;
  final String origin;
  final String? note;
  final DateTime createdAt;
  final SeMatch? match;
  final int? contestNumber;

  bool get isOpen => status == 'open';
}

class SeTicketRepository {
  SeTicketRepository(this._db);

  final AppDatabase _db;

  Future<int> add({
    required List<int> numbers,
    int? superstar,
    required String origin,
    String? note,
    DateTime? now,
  }) async {
    final sorted = [...numbers]..sort();
    final problem = seTicketProblem(sorted, superstar: superstar);
    if (problem != null) throw StateError(problem);
    final target = nextOpenDrawDate(now ?? DateTime.now());
    return _db.into(_db.superenalottoTickets).insert(SuperenalottoTicketsCompanion.insert(
          n1: sorted[0],
          n2: sorted[1],
          n3: sorted[2],
          n4: sorted[3],
          n5: sorted[4],
          n6: sorted[5],
          superstar: Value(superstar),
          targetDrawDate: target,
          origin: Value(origin),
          note: Value(note),
          createdAt: DateTime.now().toUtc(),
        ));
  }

  Future<List<SeTicket>> list() async {
    final tickets = await (_db.select(_db.superenalottoTickets)..orderBy([(row) => OrderingTerm.desc(row.id)])).get();
    final results = await _db.select(_db.superenalottoTicketResults).get();
    final byTicket = {for (final row in results) row.ticketId: row};
    return [
      for (final ticket in tickets)
        SeTicket(
          id: ticket.id,
          numbers: [ticket.n1, ticket.n2, ticket.n3, ticket.n4, ticket.n5, ticket.n6],
          superstar: ticket.superstar,
          targetDrawDate: ticket.targetDrawDate.toUtc(),
          status: ticket.status,
          origin: ticket.origin,
          note: ticket.note,
          createdAt: ticket.createdAt.toUtc(),
          match: byTicket[ticket.id] == null
              ? null
              : SeMatch(
                  hits: byTicket[ticket.id]!.hits,
                  jollyMatched: byTicket[ticket.id]!.jollyMatched,
                  superstarMatched: byTicket[ticket.id]!.superstarMatched,
                  category: byTicket[ticket.id]!.category,
                ),
          contestNumber: byTicket[ticket.id]?.contestNumber,
        ),
    ];
  }

  /// Chiude le schedine il cui concorso, lo stesso giorno, è in archivio.
  Future<int> evaluateOpen() async {
    final open = await (_db.select(_db.superenalottoTickets)..where((row) => row.status.equals('open'))).get();
    if (open.isEmpty) return 0;
    final draws = await (_db.select(_db.superenalottoDraws)).get();
    final byDay = <String, SuperenalottoDrawRow>{};
    for (final draw in draws) {
      byDay[formatIsoDate(draw.drawDate.toUtc())] = draw;
    }
    var closed = 0;
    for (final ticket in open) {
      final draw = byDay[formatIsoDate(ticket.targetDrawDate.toUtc())];
      if (draw == null) continue;
      final match = matchSuperenalotto(
        played: [ticket.n1, ticket.n2, ticket.n3, ticket.n4, ticket.n5, ticket.n6],
        superstar: ticket.superstar,
        drawn: [draw.n1, draw.n2, draw.n3, draw.n4, draw.n5, draw.n6],
        jolly: draw.jolly,
        drawnSuperstar: draw.superstar,
      );
      await _db.transaction(() async {
        await _db.into(_db.superenalottoTicketResults).insert(SuperenalottoTicketResultsCompanion.insert(
              ticketId: ticket.id,
              contestNumber: draw.contestNumber,
              drawDate: draw.drawDate,
              hits: match.hits,
              jollyMatched: match.jollyMatched,
              superstarMatched: match.superstarMatched,
              category: match.category,
              evaluatedAt: DateTime.now().toUtc(),
            ));
        await (_db.update(_db.superenalottoTickets)..where((row) => row.id.equals(ticket.id)))
            .write(const SuperenalottoTicketsCompanion(status: Value('evaluated')));
      });
      closed++;
    }
    return closed;
  }
}

final seTicketRepositoryProvider = Provider<SeTicketRepository>((ref) {
  return SeTicketRepository(ref.watch(databaseProvider));
});

final seTicketsProvider = FutureProvider<List<SeTicket>>((ref) {
  return ref.watch(seTicketRepositoryProvider).list();
});
