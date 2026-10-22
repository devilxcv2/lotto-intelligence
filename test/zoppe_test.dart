// test/zoppe_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/hypergeometric.dart';
import 'package:lotto_intelligence/features/systems/domain/zoppe_system.dart';

void main() {
  Map<int, int> distinctHits() => {for (var number = 1; number <= 90; number++) number: number};

  test('la fascia 30–45 è il complemento e non ripete la maschera positiva', () {
    final positive = {1, 2, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90};
    final result = buildZoppeSystem(positiveMask: positive, hits: distinctHits(), positiveShare: 0.15, windowDraws: 100);
    expect(result.error, isNull);
    expect(result.positiveSlice, [89, 90]);
    expect(result.negativeBand, [for (var number = 28; number <= 41; number++) number]);
    expect(result.negativeBand.toSet().intersection(positive), isEmpty);
    expect(result.fromPositive, 2);
    expect(result.fromNegative, 3);
    expect(result.columns, hasLength(364));
    expect(result.leadColumn, [39, 40, 41, 89, 90]);
    for (final column in result.columns) {
      expect(column.where(result.positiveSlice.contains), hasLength(2));
      expect(column.where(result.negativeBand.contains), hasLength(3));
    }
  });

  test('senza maschera positiva non inventa colonne', () {
    final result = buildZoppeSystem(positiveMask: const {}, hits: distinctHits());
    expect(result.columns, isEmpty);
    expect(result.error, contains('maschera positiva'));
    expect(result.negativeMask, hasLength(90));
  });

  test('un numero della positiva non entra nella fascia anche se il percentile ci cade', () {
    final result = buildZoppeSystem(positiveMask: {30, 89, 90}, hits: distinctHits(), positiveShare: 0.15);
    expect(result.negativeBand.contains(30), isFalse);
    expect(result.positiveMask.contains(30), isTrue);
  });

  test('i pari merito troppo larghi si accorciano verso il centro della fascia', () {
    final hits = {for (var number = 1; number <= 90; number++) number: 50};
    for (var number = 1; number <= 8; number++) {
      hits[number] = number;
    }
    for (var number = 60; number <= 90; number++) {
      hits[number] = 100 + number;
    }
    final result = buildZoppeSystem(
      positiveMask: {for (var number = 71; number <= 90; number++) number},
      hits: hits,
      positiveShare: 0.15,
    );
    expect(result.trimmed, isTrue);
    expect(result.error, isNull);
    expect(result.positiveSlice, [88, 89, 90]);
    expect(result.negativeBand, hasLength(35));
    expect(result.negativeBand.first, 9);
    expect(result.negativeBand.last, 43);
    expect(result.columns, hasLength(19635));
    expect(result.leadColumn, [9, 10, 11, 89, 90]);
  });

  test('la probabilità equa non dipende dalla fascia', () {
    expect(singleNumberProbability, closeTo(5 / 90, 1e-12));
    expect(zoppeFairAtLeastOne(0), 0);
    expect(zoppeFairAtLeastOne(5), closeTo(1 - (binomial(85, 5) / binomial(90, 5)).toDouble(), 1e-9));
  });
}
