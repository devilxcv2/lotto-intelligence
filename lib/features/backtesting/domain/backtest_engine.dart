// lib/features/backtesting/domain/backtest_engine.dart

import 'dart:isolate';
import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';
import '../../../core/lotto/scientific_notice.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/combinations.dart';

/// Strategia valutata solo sul passato. L'implementazione non riceve
/// l'estrazione corrente né quelle successive.
abstract class StudyStrategy {
  String get id;
  String get version;

  List<int> propose({
    required List<ArchivedDraw> historyBefore,
    required int contestIndex,
    required int seed,
  });
}

class FixedNumbersStrategy implements StudyStrategy {
  FixedNumbersStrategy(List<int> numbers) : numbers = List<int>.unmodifiable(numbers);

  final List<int> numbers;

  @override
  String get id => 'fixed';

  @override
  String get version => '1';

  @override
  List<int> propose({
    required List<ArchivedDraw> historyBefore,
    required int contestIndex,
    required int seed,
  }) {
    return numbers;
  }
}

class FrequencyTopStrategy implements StudyStrategy {
  const FrequencyTopStrategy();

  @override
  String get id => 'frequency-top';

  @override
  String get version => '1';

  @override
  List<int> propose({
    required List<ArchivedDraw> historyBefore,
    required int contestIndex,
    required int seed,
  }) {
    if (historyBefore.isEmpty) {
      return sampleUniform(5, Random(seed ^ contestIndex));
    }
    final counts = List<int>.filled(91, 0);
    for (final draw in historyBefore) {
      for (final number in draw.numbers) {
        counts[number]++;
      }
    }
    final ranked = [for (var n = 1; n <= 90; n++) n]..sort((a, b) {
        final byCount = counts[b].compareTo(counts[a]);
        if (byCount != 0) return byCount;
        return a.compareTo(b);
      });
    return ranked.take(5).toList()..sort();
  }
}

class RandomBaselineStrategy implements StudyStrategy {
  const RandomBaselineStrategy();

  @override
  String get id => 'random-baseline';

  @override
  String get version => '1';

  @override
  List<int> propose({
    required List<ArchivedDraw> historyBefore,
    required int contestIndex,
    required int seed,
  }) {
    return sampleUniform(5, Random(seed + contestIndex * 9973));
  }
}

class ScoredDraw {
  const ScoredDraw({
    required this.date,
    required this.hits,
    required this.baselineHits,
    required this.proposed,
  });

  final DateTime date;
  final int hits;
  final int baselineHits;
  final List<int> proposed;
}

class MonteCarloSummary {
  const MonteCarloSummary({
    required this.runs,
    required this.seed,
    required this.meanTotalHits,
    required this.minTotalHits,
    required this.maxTotalHits,
    required this.strategyTotalHits,
    required this.runsAtLeastStrategy,
  });

  final int runs;
  final int seed;
  final double meanTotalHits;
  final int minTotalHits;
  final int maxTotalHits;
  final int strategyTotalHits;

  /// Quante simulazioni casuali hanno totalizzato almeno i centri della strategia.
  /// È un rango descrittivo sul campione simulato, non un valore p certificato.
  final int runsAtLeastStrategy;
}

class BacktestReport {
  const BacktestReport({
    required this.strategyId,
    required this.strategyVersion,
    required this.seed,
    required this.scoredDraws,
    required this.warmupDraws,
    required this.strategyHistogram,
    required this.baselineHistogram,
    required this.expectedHistogram,
    required this.strategyMeanHits,
    required this.baselineMeanHits,
    required this.expectedMeanHits,
    required this.drawsWithAtLeastOneHit,
    required this.rows,
    required this.monteCarlo,
    required this.limitation,
  });

  final String strategyId;
  final String strategyVersion;
  final int seed;
  final int scoredDraws;
  final int warmupDraws;
  final List<int> strategyHistogram;
  final List<int> baselineHistogram;
  final List<double> expectedHistogram;
  final double strategyMeanHits;
  final double baselineMeanHits;
  final double expectedMeanHits;
  final int drawsWithAtLeastOneHit;
  final List<ScoredDraw> rows;
  final MonteCarloSummary monteCarlo;
  final String limitation;

  Map<String, Object?> toJson() {
    return {
      'kind': 'historical-simulation',
      'strategyId': strategyId,
      'strategyVersion': strategyVersion,
      'seed': seed,
      'scoredDraws': scoredDraws,
      'warmupDraws': warmupDraws,
      'strategyHistogram': strategyHistogram,
      'baselineHistogram': baselineHistogram,
      'expectedHistogram': expectedHistogram,
      'strategyMeanHits': strategyMeanHits,
      'baselineMeanHits': baselineMeanHits,
      'expectedMeanHits': expectedMeanHits,
      'drawsWithAtLeastOneHit': drawsWithAtLeastOneHit,
      'monteCarlo': {
        'runs': monteCarlo.runs,
        'seed': monteCarlo.seed,
        'meanTotalHits': monteCarlo.meanTotalHits,
        'minTotalHits': monteCarlo.minTotalHits,
        'maxTotalHits': monteCarlo.maxTotalHits,
        'strategyTotalHits': monteCarlo.strategyTotalHits,
        'runsAtLeastStrategy': monteCarlo.runsAtLeastStrategy,
      },
      'monetary': {
        'available': false,
        'grossWins': null,
        'netWins': null,
        'roi': null,
        'maxDrawdown': null,
        'reason': monetaryUnavailableReason,
      },
      'limitation': limitation,
    };
  }
}

/// Il walk-forward ricalcola la strategia a ogni estrazione: su archivi
/// lunghi dura secondi, quindi gira fuori dal thread dell'interfaccia.
Future<BacktestReport> runBacktestInBackground({
  required List<ArchivedDraw> draws,
  required StudyStrategy strategy,
  required int seed,
  required int scoreFromIndex,
  required int monteCarloRuns,
}) {
  return Isolate.run(() => const BacktestEngine().run(
        draws: draws,
        strategy: strategy,
        seed: seed,
        scoreFromIndex: scoreFromIndex,
        monteCarloRuns: monteCarloRuns,
      ));
}

class BacktestEngine {
  const BacktestEngine();

  BacktestReport run({
    required List<ArchivedDraw> draws,
    required StudyStrategy strategy,
    required int seed,
    int scoreFromIndex = 0,
    int monteCarloRuns = 30,
  }) {
    if (scoreFromIndex < 0 || scoreFromIndex > draws.length) {
      throw ArgumentError('scoreFromIndex fuori dall\'archivio.');
    }
    final baseline = const RandomBaselineStrategy();
    final strategyHistogram = List<int>.filled(6, 0);
    final baselineHistogram = List<int>.filled(6, 0);
    final rows = <ScoredDraw>[];
    var strategyHitsSum = 0;

    for (var index = scoreFromIndex; index < draws.length; index++) {
      final history = draws.sublist(0, index);
      final proposed = strategy.propose(historyBefore: history, contestIndex: index, seed: seed);
      final baselinePick = baseline.propose(historyBefore: history, contestIndex: index, seed: seed);
      final hits = _hits(proposed, draws[index].numbers);
      final baselineHits = _hits(baselinePick, draws[index].numbers);
      strategyHistogram[hits]++;
      baselineHistogram[baselineHits]++;
      strategyHitsSum += hits;
      rows.add(ScoredDraw(
        date: draws[index].date,
        hits: hits,
        baselineHits: baselineHits,
        proposed: proposed,
      ));
    }

    final scored = rows.length;
    final expectedHistogram = [
      for (var k = 0; k <= 5; k++)
        scored *
            hypergeometricPmf(
              population: 90,
              successStates: 5,
              drawSize: 5,
              observed: k,
            ),
    ];
    final monteCarlo = _monteCarlo(
      draws: draws,
      scoreFromIndex: scoreFromIndex,
      runs: monteCarloRuns,
      seed: seed,
      strategyTotalHits: strategyHitsSum,
    );

    return BacktestReport(
      strategyId: strategy.id,
      strategyVersion: strategy.version,
      seed: seed,
      scoredDraws: scored,
      warmupDraws: scoreFromIndex,
      strategyHistogram: strategyHistogram,
      baselineHistogram: baselineHistogram,
      expectedHistogram: expectedHistogram,
      strategyMeanHits: scored == 0 ? 0 : strategyHitsSum / scored,
      baselineMeanHits: scored == 0 ? 0 : baselineHistogram.indexed.fold<int>(0, (sum, item) => sum + item.$1 * item.$2) / scored,
      expectedMeanHits: 5 * singleNumberProbability,
      drawsWithAtLeastOneHit: scored - strategyHistogram[0],
      rows: rows,
      monteCarlo: monteCarlo,
      limitation:
          'Simulazione storica. Se le estrazioni sono indipendenti e uniformi, ogni regola che sceglie 5 numeri usando solo il passato ha la stessa distribuzione teorica dei centri di un sorteggio casuale. '
          'Uno scostamento su questa finestra non è una garanzia futura. Confrontare molte strategie sullo stesso archivio aumenta la probabilità di osservare un risultato estremo per caso. '
          '$monetaryUnavailableReason $scientificDisclaimer',
    );
  }
}

MonteCarloSummary _monteCarlo({
  required List<ArchivedDraw> draws,
  required int scoreFromIndex,
  required int runs,
  required int seed,
  required int strategyTotalHits,
}) {
  if (runs <= 0 || scoreFromIndex >= draws.length) {
    return MonteCarloSummary(
      runs: 0,
      seed: seed,
      meanTotalHits: 0,
      minTotalHits: 0,
      maxTotalHits: 0,
      strategyTotalHits: strategyTotalHits,
      runsAtLeastStrategy: 0,
    );
  }
  var sum = 0;
  var minHits = 1 << 30;
  var maxHits = 0;
  var atLeast = 0;
  for (var run = 0; run < runs; run++) {
    final random = Random(seed + 10007 * (run + 1));
    var total = 0;
    for (var index = scoreFromIndex; index < draws.length; index++) {
      final ticket = sampleUniform(5, random);
      total += _hits(ticket, draws[index].numbers);
    }
    sum += total;
    if (total < minHits) minHits = total;
    if (total > maxHits) maxHits = total;
    if (total >= strategyTotalHits) atLeast++;
  }
  return MonteCarloSummary(
    runs: runs,
    seed: seed,
    meanTotalHits: sum / runs,
    minTotalHits: minHits,
    maxTotalHits: maxHits,
    strategyTotalHits: strategyTotalHits,
    runsAtLeastStrategy: atLeast,
  );
}

int _hits(List<int> proposed, List<int> drawn) {
  final present = drawn.toSet();
  var hits = 0;
  final seen = <int>{};
  for (final number in proposed) {
    if (number < 1 || number > 90 || !seen.add(number)) continue;
    if (present.contains(number)) hits++;
  }
  return hits > 5 ? 5 : hits;
}
