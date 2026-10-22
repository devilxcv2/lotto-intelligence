// test/zoppe_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/hypergeometric.dart';
import 'package:lotto_intelligence/features/systems/domain/zoppe_system.dart';

void main() {
  Map<int, int> distinctHits() => {for (var number = 1; number <= 90; number++) number: number};
  Map<int, int> flatDelay() => {for (var number = 1; number <= 90; number++) number: 91 - number};

  test('compone cinque gambe: gettonato, ritardatario e tre fasce', () {
    final result = buildZoppeSystem(
      hits: distinctHits(),
      delays: flatDelay(),
      columnSize: 5,
      seed: 7,
      windowDraws: 100,
    );
    expect(result.error, isNull);
    expect(result.legs, hasLength(5));
    expect(result.legs.map((leg) => leg.id).toList(), [
      'gettonato',
      'ritardatario',
      'fascia_30_45',
      'fascia_50_65',
      'fascia_70_85',
    ]);
    expect(result.columns, isNotEmpty);
    expect(result.leadColumn, hasLength(5));
    expect(result.legend, contains('gettonati'));
    for (final column in result.columns) {
      expect(column.toSet(), hasLength(5));
    }
  });

  test('sul SuperEnalotto aggiunge la fascia 15–30', () {
    final result = buildZoppeSystem(
      hits: distinctHits(),
      delays: flatDelay(),
      columnSize: 6,
      seed: 3,
    );
    expect(result.error, isNull);
    expect(result.legs.last.id, 'fascia_15_30');
    expect(result.leadColumn, hasLength(6));
  });

  test('con un universo troppo stretto non inventa colonne', () {
    final result = buildZoppeSystem(
      hits: distinctHits(),
      delays: flatDelay(),
      universe: {1, 2, 3},
      columnSize: 5,
    );
    expect(result.columns, isEmpty);
    expect(result.error, isNotNull);
  });

  test('lo stesso seme ripete le stesse colonne', () {
    final first = buildZoppeSystem(hits: distinctHits(), delays: flatDelay(), seed: 11);
    final second = buildZoppeSystem(hits: distinctHits(), delays: flatDelay(), seed: 11);
    expect(first.columns, second.columns);
    expect(first.leadColumn, second.leadColumn);
  });

  test('la probabilità equa non dipende dalle fasce', () {
    expect(singleNumberProbability, closeTo(5 / 90, 1e-12));
    expect(zoppeFairAtLeastOne(0), 0);
    expect(zoppeFairAtLeastOne(5), closeTo(1 - (binomial(85, 5) / binomial(90, 5)).toDouble(), 1e-9));
  });
}
