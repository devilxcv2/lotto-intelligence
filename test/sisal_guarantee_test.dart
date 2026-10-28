import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/settings/app_settings.dart';
import 'package:lotto_intelligence/features/systems/domain/combinations.dart';
import 'package:lotto_intelligence/features/systems/domain/sisal_guarantee.dart';

void main() {
  test('parametri Sisal SE G5/G4/G3', () {
    final g5 = sisalReducedParams(
      guarantee: SisalGuarantee.g5,
      drawnSize: superenalottoDrawnSize,
      combinationSize: 6,
    );
    expect(g5.assumedHits, 6);
    expect(g5.guaranteedHits, 5);
    final g3 = sisalReducedParams(
      guarantee: SisalGuarantee.g3,
      drawnSize: superenalottoDrawnSize,
      combinationSize: 6,
    );
    expect(g3.guaranteedHits, 3);
  });

  test('spesa: totale colonne × posta e consiglio budget', () {
    final spend = buildSisalSpendSummary(
      columns: 14,
      combinationSize: 6,
      poolSize: 10,
      unitCostCents: 100,
      settings: AppSettings.initial.copyWith(
        budgetMode: BudgetMode.limits,
        contestBudgetCents: 1000,
      ),
    );
    expect(spend.totalCents, 1400);
    expect(spend.overContestBudget, isTrue);
    expect(spend.advice.toLowerCase(), contains('budget'));
  });

  test('tabella Sisal riferimento G5 con 10 numeri', () {
    expect(sisalSeReferenceCostCents(SisalGuarantee.g5, 10), 1400);
  });

  test('ridotto SE stile G3 su 8 numeri verifica la garanzia', () {
    final pool = [for (var n = 1; n <= 8; n++) n * 3];
    final params = sisalReducedParams(
      guarantee: SisalGuarantee.g3,
      drawnSize: superenalottoDrawnSize,
      combinationSize: 6,
    );
    final reduced = generateReduced(
      pool: pool,
      combinationSize: 6,
      assumedHits: params.assumedHits,
      guaranteedHits: params.guaranteedHits,
      seed: 7,
    );
    expect(reduced.guaranteeVerified, isTrue);
    expect(reduced.coverageClaim, contains('G3'));
  });

  test('ridotto Lotto stile G4 su 10 numeri verifica la garanzia', () {
    final pool = [for (var n = 1; n <= 10; n++) n * 5];
    final params = sisalReducedParams(
      guarantee: SisalGuarantee.g4,
      drawnSize: lottoDrawnSize,
      combinationSize: 5,
    );
    final reduced = generateReduced(
      pool: pool,
      combinationSize: 5,
      assumedHits: params.assumedHits,
      guaranteedHits: params.guaranteedHits,
      seed: 11,
    );
    expect(reduced.guaranteeVerified, isTrue);
    expect(reduced.coverageClaim, contains('G4'));
  });
}
