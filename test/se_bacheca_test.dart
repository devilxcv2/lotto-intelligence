import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/se_bacheca.dart';
import 'package:lotto_intelligence/features/systems/domain/sisal_guarantee.dart';

void main() {
  test('integrale 8 numeri = 28 sestine', () {
    final r = developIntegrale([1, 2, 3, 4, 5, 6, 7, 8]);
    expect(r.columns, hasLength(28));
    expect(r.costCents, 2800);
    expect(r.catalogColumns, 28);
  });

  test('minicruciverba 9 numeri → 8 sestine', () {
    final r = developMinicruciverba([for (var n = 1; n <= 9; n++) n]);
    expect(r.columns, hasLength(8));
    expect(r.grid, isNotNull);
    for (final row in r.columns) {
      expect(row, hasLength(6));
    }
  });

  test('cruciverba 6x6 → 14 sestine', () {
    final r = developCruciverba([for (var n = 1; n <= 36; n++) n], 6);
    expect(r.columns, hasLength(14));
    expect(r.catalogColumns, 14);
  });

  test('basi varianti B2', () {
    final r = developBasiVarianti(
      basi: [1, 2, 3],
      varianti: [10, 11, 12, 13, 14],
      k: 2,
    );
    // C(3,2)*C(5,4)=3*5=15
    expect(r.columns, hasLength(15));
    for (final row in r.columns) {
      expect(row, hasLength(6));
      expect(row.where((n) => n <= 3).length, 2);
    }
  });

  test('ridotto G5 10 numeri sviluppa colonne', () {
    final r = developRidotto(
      panelA: [for (var n = 1; n <= 10; n++) n * 2],
      guarantee: SisalGuarantee.g5,
    );
    expect(r.columns, isNotEmpty);
    expect(r.guaranteeVerified, isTrue);
    expect(r.catalogColumns, 14);
  });

  test('tabella integrale Sisal', () {
    expect(seIntegralCombinations(6), 1);
    expect(seIntegralCombinations(7), 7);
    expect(seIntegralCombinations(10), 210);
    expect(seIntegralCombinations(19), 27132);
  });
}
