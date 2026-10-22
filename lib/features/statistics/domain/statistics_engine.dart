// lib/features/statistics/domain/statistics_engine.dart

import 'dart:isolate';
import 'dart:math' as math;

import '../../../core/lotto/hypergeometric.dart';

/// Cinquina già ordinata cronologicamente rispetto alle altre della stessa ruota.
class ArchivedDraw {
  const ArchivedDraw({required this.date, required this.numbers});

  final DateTime date;
  final List<int> numbers;
}

class NumberStat {
  const NumberStat({
    required this.number,
    required this.absoluteFrequency,
    required this.relativeFrequency,
    required this.currentDelay,
    required this.maxDelay,
    required this.meanInterval,
    required this.neverSeen,
    required this.wilsonLow,
    required this.wilsonHigh,
  });

  final int number;
  final int absoluteFrequency;
  final double relativeFrequency;
  final int currentDelay;
  final int maxDelay;

  /// Media delle distanze, in estrazioni, fra due uscite consecutive.
  /// Nulla se il numero è uscito meno di due volte.
  final double? meanInterval;
  final bool neverSeen;
  final double wilsonLow;
  final double wilsonHigh;

  bool get compatibleWithFairDraw => wilsonLow <= singleNumberProbability && singleNumberProbability <= wilsonHigh;
}

class PairStat {
  const PairStat({required this.a, required this.b, required this.count, required this.expected});

  final int a;
  final int b;
  final int count;
  final double expected;
}

class WheelStatistics {
  const WheelStatistics({
    required this.drawCount,
    required this.numbers,
    required this.evenHistogram,
    required this.expectedEvenHistogram,
    required this.lowHistogram,
    required this.sumMean,
    required this.sumMin,
    required this.sumMax,
    required this.drawsWithConsecutive,
    required this.decadeCounts,
    required this.finalDigitCounts,
    required this.positionCounts,
    required this.topPairs,
    required this.expectedPairCount,
  });

  final int drawCount;
  final List<NumberStat> numbers;
  final List<int> evenHistogram;
  final List<double> expectedEvenHistogram;
  final List<int> lowHistogram;
  final double sumMean;
  final int sumMin;
  final int sumMax;
  final int drawsWithConsecutive;
  final List<int> decadeCounts;
  final List<int> finalDigitCounts;

  /// `positionCounts[position - 1][number]` con number da 1 a 90.
  final List<List<int>> positionCounts;
  final List<PairStat> topPairs;
  final double expectedPairCount;

  NumberStat statOf(int number) => numbers[number - 1];
}

class StatisticsEngine {
  const StatisticsEngine();

  WheelStatistics summarize(List<ArchivedDraw> draws) {
    final count = draws.length;
    final frequency = List<int>.filled(91, 0);
    final delay = List<int>.filled(91, 0);
    final maxDelay = List<int>.filled(91, 0);
    final occurrences = List<List<int>>.generate(91, (_) => <int>[]);
    final evenHistogram = List<int>.filled(6, 0);
    final lowHistogram = List<int>.filled(6, 0);
    final decadeCounts = List<int>.filled(9, 0);
    final finalDigitCounts = List<int>.filled(10, 0);
    final positionCounts = List<List<int>>.generate(5, (_) => List<int>.filled(91, 0));
    final pairCounts = <int, int>{};
    var sumTotal = 0;
    var sumMin = 0;
    var sumMax = 0;
    var consecutiveDraws = 0;

    for (var index = 0; index < draws.length; index++) {
      final numbers = draws[index].numbers;
      var even = 0;
      var low = 0;
      var sum = 0;
      var hasConsecutive = false;
      final sorted = [...numbers]..sort();
      for (var i = 1; i < sorted.length; i++) {
        if (sorted[i] == sorted[i - 1] + 1) hasConsecutive = true;
      }
      if (hasConsecutive) consecutiveDraws++;
      for (var position = 0; position < numbers.length; position++) {
        final number = numbers[position];
        frequency[number]++;
        occurrences[number].add(index);
        sum += number;
        if (number.isEven) even++;
        if (number <= 45) low++;
        decadeCounts[(number - 1) ~/ 10]++;
        finalDigitCounts[number % 10]++;
        if (position < 5) positionCounts[position][number]++;
      }
      for (var i = 0; i < sorted.length; i++) {
        for (var j = i + 1; j < sorted.length; j++) {
          final key = sorted[i] * 100 + sorted[j];
          pairCounts[key] = (pairCounts[key] ?? 0) + 1;
        }
      }
      evenHistogram[even]++;
      lowHistogram[low]++;
      sumTotal += sum;
      if (index == 0 || sum < sumMin) sumMin = sum;
      if (index == 0 || sum > sumMax) sumMax = sum;

      for (var number = 1; number <= 90; number++) {
        final present = numbers.contains(number);
        if (present) {
          if (delay[number] > maxDelay[number]) maxDelay[number] = delay[number];
          delay[number] = 0;
        } else {
          delay[number]++;
          if (delay[number] > maxDelay[number]) maxDelay[number] = delay[number];
        }
      }
    }

    final numberStats = <NumberStat>[];
    for (var number = 1; number <= 90; number++) {
      final hits = frequency[number];
      final indexes = occurrences[number];
      double? meanInterval;
      if (indexes.length >= 2) {
        var gapSum = 0;
        for (var i = 1; i < indexes.length; i++) {
          gapSum += indexes[i] - indexes[i - 1];
        }
        meanInterval = gapSum / (indexes.length - 1);
      }
      final wilson = wilsonInterval(hits, count);
      numberStats.add(NumberStat(
        number: number,
        absoluteFrequency: hits,
        relativeFrequency: count == 0 ? 0 : hits / count,
        currentDelay: delay[number],
        maxDelay: maxDelay[number],
        meanInterval: meanInterval,
        neverSeen: hits == 0,
        wilsonLow: wilson.$1,
        wilsonHigh: wilson.$2,
      ));
    }

    final expectedPair = count * (binomial(88, 3) / binomial(90, 5));
    final ranked = pairCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    final topPairs = [
      for (final entry in ranked.take(15))
        PairStat(
          a: entry.key ~/ 100,
          b: entry.key % 100,
          count: entry.value,
          expected: expectedPair,
        ),
    ];

    final expectedEven = [
      for (var k = 0; k <= 5; k++)
        count *
            hypergeometricPmf(
              population: 90,
              successStates: 45,
              drawSize: 5,
              observed: k,
            ),
    ];

    return WheelStatistics(
      drawCount: count,
      numbers: numberStats,
      evenHistogram: evenHistogram,
      expectedEvenHistogram: expectedEven,
      lowHistogram: lowHistogram,
      sumMean: count == 0 ? 0 : sumTotal / count,
      sumMin: count == 0 ? 0 : sumMin,
      sumMax: count == 0 ? 0 : sumMax,
      drawsWithConsecutive: consecutiveDraws,
      decadeCounts: decadeCounts,
      finalDigitCounts: finalDigitCounts,
      positionCounts: positionCounts,
      topPairs: topPairs,
      expectedPairCount: expectedPair,
    );
  }
}

/// Su decine di migliaia di estrazioni il calcolo supera la durata di un frame.
Future<WheelStatistics> summarizeInBackground(List<ArchivedDraw> draws) {
  return Isolate.run(() => const StatisticsEngine().summarize(draws));
}

/// Ultime [window] estrazioni; `null` significa tutto l'archivio.
List<T> lastWindow<T>(List<T> items, int? window) {
  if (window == null || window >= items.length) return items;
  return items.sublist(items.length - window);
}

/// Intervallo di Wilson al 95% sulla frequenza storica.
/// Descrive la variabilità del tasso osservato, non una probabilità futura.
(double, double) wilsonInterval(int successes, int total, {double z = 1.96}) {
  if (total <= 0) return (0, 1);
  final p = successes / total;
  final z2 = z * z;
  final denom = 1 + z2 / total;
  final center = (p + z2 / (2 * total)) / denom;
  final margin = z * math.sqrt((p * (1 - p) + z2 / (4 * total)) / total) / denom;
  return (math.max(0, center - margin), math.min(1, center + margin));
}

/// Correlazione di Pearson fra le serie di presenza (0/1) di due numeri.
/// Con molte coppie confrontate, un valore estremo può emergere per caso.
double? pearsonPresence(List<ArchivedDraw> draws, int first, int second) {
  if (draws.length < 3 || first == second) return null;
  final n = draws.length;
  var sumA = 0.0;
  var sumB = 0.0;
  var sumAB = 0.0;
  var sumA2 = 0.0;
  var sumB2 = 0.0;
  for (final draw in draws) {
    final a = draw.numbers.contains(first) ? 1.0 : 0.0;
    final b = draw.numbers.contains(second) ? 1.0 : 0.0;
    sumA += a;
    sumB += b;
    sumAB += a * b;
    sumA2 += a * a;
    sumB2 += b * b;
  }
  final numerator = n * sumAB - sumA * sumB;
  final left = n * sumA2 - sumA * sumA;
  final right = n * sumB2 - sumB * sumB;
  if (left <= 0 || right <= 0) return null;
  return numerator / math.sqrt(left * right);
}
