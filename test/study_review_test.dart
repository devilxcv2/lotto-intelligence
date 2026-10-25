import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/prize_table.dart';
import 'package:lotto_intelligence/features/virtual_wallet/data/wallet_repository.dart';
import 'package:lotto_intelligence/features/virtual_wallet/domain/study_review.dart';

StoredTicket _ticket({
  required int id,
  required String note,
  required int hits,
  required Set<int> hitNumbers,
  required List<int> numbers,
  int stake = 100,
  int net = 0,
}) {
  return StoredTicket(
    id: id,
    wheelCode: 'BA',
    stakeCents: stake,
    stakes: {LottoSorte.ambo: stake},
    createdAt: DateTime.utc(2026, 10, 1),
    targetDrawDate: DateTime.utc(2026, 10, 2),
    status: 'evaluated',
    numbers: numbers,
    note: note,
    strategyId: null,
    evaluation: TicketEvaluation(
      evaluatedAt: DateTime.utc(2026, 10, 2, 21),
      drawDate: DateTime.utc(2026, 10, 2),
      hits: hits,
      grossCents: net > 0 ? (net / 0.92).round() : 0,
      netCents: net,
      hitsByWheel: {'BA': hits},
      grossBySorte: const {},
      hitNumbers: hitNumbers,
      note: '',
    ),
  );
}

void main() {
  test('raggruppa Zoppe e spiega i miss', () {
    final tickets = [
      _ticket(
        id: 1,
        note: 'Auto · Zoppe. Creata dall\'app.',
        hits: 1,
        hitNumbers: {12},
        numbers: [12, 34, 56, 78, 90],
        net: 0,
      ),
      _ticket(
        id: 2,
        note: 'Auto · Ritardi. Creata dall\'app.',
        hits: 2,
        hitNumbers: {1, 2},
        numbers: [1, 2, 3, 4, 5],
        net: 2500,
      ),
    ];
    final scores = scoreByMethod(tickets);
    expect(scores.length, 2);
    final lessons = lessonsFromTickets(tickets);
    expect(lessons, isNotEmpty);
    expect(lessons.first.body.toLowerCase(), anyOf(contains('zoppe'), contains('ritard')));
  });
}
