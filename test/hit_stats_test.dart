import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/prize_table.dart';
import 'package:lotto_intelligence/features/superenalotto/data/se_ticket_repository.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_repository.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/se_hit_stats.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/superenalotto_studio.dart';
import 'package:lotto_intelligence/features/virtual_wallet/data/wallet_repository.dart';
import 'package:lotto_intelligence/features/virtual_wallet/domain/lotto_hit_stats.dart';

void main() {
  group('lotto hit stats', () {
    test('aggrega numeri vincenti e uscite recenti per ruota', () {
      final tickets = [
        StoredTicket(
          id: 1,
          wheelCode: 'BA',
          stakeCents: 100,
          stakes: const {LottoSorte.ambo: 100},
          createdAt: DateTime.utc(2026, 10, 1),
          targetDrawDate: DateTime.utc(2026, 10, 1),
          status: 'evaluated',
          numbers: const [5, 17, 42],
          note: null,
          strategyId: null,
          evaluation: TicketEvaluation(
            evaluatedAt: DateTime.utc(2026, 10, 1, 21),
            drawDate: DateTime.utc(2026, 10, 1),
            hits: 2,
            grossCents: 2500,
            netCents: 2300,
            hitsByWheel: const {'BA': 2},
            grossBySorte: const {LottoSorte.ambo: 2500},
            hitNumbers: const {5, 17},
            note: 'ok',
          ),
        ),
        StoredTicket(
          id: 2,
          wheelCode: 'MI',
          stakeCents: 100,
          stakes: const {LottoSorte.estratto: 100},
          createdAt: DateTime.utc(2026, 10, 2),
          targetDrawDate: DateTime.utc(2026, 10, 2),
          status: 'evaluated',
          numbers: const [17],
          note: null,
          strategyId: null,
          evaluation: TicketEvaluation(
            evaluatedAt: DateTime.utc(2026, 10, 2, 21),
            drawDate: DateTime.utc(2026, 10, 2),
            hits: 1,
            grossCents: 1123,
            netCents: 1033,
            hitsByWheel: const {'MI': 1},
            grossBySorte: const {LottoSorte.estratto: 1123},
            hitNumbers: const {17},
            note: 'ok',
          ),
        ),
      ];
      final recent = {
        17: [
          (date: DateTime.utc(2026, 10, 3), wheelCode: 'BA'),
          (date: DateTime.utc(2026, 10, 3), wheelCode: 'RM'),
        ],
        5: [
          (date: DateTime.utc(2026, 10, 3), wheelCode: 'FI'),
        ],
      };
      final report = buildLottoHitStats(tickets: tickets, recent: recent, drawDays: 3);
      expect(report.payingTicketCount, 2);
      expect(report.numbers.first.number, 17);
      expect(report.numbers.first.payingTickets, 2);
      expect(report.numbers.first.recentByWheel['BA'], 1);
      expect(report.numbers.first.recentByWheel['RM'], 1);
    });
  });

  group('se hit stats', () {
    test('usa intersezione con l\'estrazione e le ultime uscite', () {
      final day = DateTime.utc(2026, 10, 1);
      final tickets = [
        SeTicket(
          id: 1,
          numbers: const [1, 2, 3, 4, 5, 6],
          superstar: 7,
          targetDrawDate: day,
          status: 'evaluated',
          origin: 'manuale',
          note: null,
          createdAt: day,
          match: const SeMatch(hits: 3, jollyMatched: false, superstarMatched: false, category: 'tre'),
          contestNumber: 1,
        ),
      ];
      final history = [
        SuperenalottoDraw(
          date: day,
          contestNumber: 1,
          numbers: const [1, 2, 3, 40, 50, 60],
          jolly: 70,
          superstar: 80,
          officiallyVerified: true,
        ),
        SuperenalottoDraw(
          date: DateTime.utc(2026, 10, 2),
          contestNumber: 2,
          numbers: const [1, 10, 20, 30, 40, 50],
          jolly: 2,
          superstar: 3,
          officiallyVerified: true,
        ),
      ];
      final report = buildSeHitStats(tickets: tickets, historyChronological: history, lookbackDraws: 12);
      expect(report.categoryTicketCount, 1);
      expect(report.numbers.map((n) => n.number).toSet(), {1, 2, 3});
      expect(report.numbers.firstWhere((n) => n.number == 1).recentMain, 2);
    });
  });
}
