import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/prize_table.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/se_prize_estimates.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/superenalotto_studio.dart';

void main() {
  group('stime SuperEnalotto', () {
    test('categorie base da quote medie Sisal', () {
      expect(seCategoryEstimateCents('sei'), isNull);
      expect(seCategoryEstimateCents('cinque_jolly'), 62000000);
      expect(seCategoryEstimateCents('cinque'), 3200000);
      expect(seCategoryEstimateCents('quattro'), 30000);
      expect(seCategoryEstimateCents('tre'), 2500);
      expect(seCategoryEstimateCents('due'), 500);
      expect(seCombinationCostCents, 100);
    });

    test('estimateSeWin somma categoria e SuperStar tipica', () {
      final tre = estimateSeWin(const SeMatch(
        hits: 3,
        jollyMatched: false,
        superstarMatched: false,
        category: 'tre',
      ));
      expect(tre.isJackpot, isFalse);
      expect(tre.estimatedCents, 2500);

      final dueStar = estimateSeWin(const SeMatch(
        hits: 2,
        jollyMatched: false,
        superstarMatched: true,
        category: 'due',
      ));
      expect(dueStar.estimatedCents, 500 + 10000);

      final jackpot = estimateSeWin(const SeMatch(
        hits: 6,
        jollyMatched: false,
        superstarMatched: false,
        category: 'sei',
      ));
      expect(jackpot.isJackpot, isTrue);
      expect(jackpot.estimatedCents, 0);
    });
  });

  group('posta minima Lotto', () {
    test('zero e sotto 1 euro bloccati', () {
      expect(stakeProblem(0), isNotNull);
      expect(stakeProblem(50), isNotNull);
      expect(stakeProblem(100), isNull);
    });
  });
}
