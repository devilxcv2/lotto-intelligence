// lib/features/backtesting/domain/study_strategies.dart

import 'dart:math';

import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/combinations.dart';
import 'backtest_engine.dart';

/// Metodo classico della lottologia, scritto come strategia di studio.
/// Ogni metodo riceve solo le estrazioni precedenti al concorso valutato.
/// Nessuno di questi criteri cambia la probabilità di un numero, che nel
/// modello equo resta 5/90: servono a essere messi alla prova nel backtest.
class StrategyInfo {
  const StrategyInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.build,
    this.usesWindow = false,
  });

  final String id;
  final String name;
  final String description;
  final StudyStrategy Function(int window) build;

  /// Vero se il metodo guarda solo le ultime N estrazioni.
  final bool usesWindow;
}

const int defaultStrategyWindow = 100;

final List<StrategyInfo> studyStrategyCatalog = List.unmodifiable([
  StrategyInfo(
    id: 'frequency-top',
    name: 'Più frequenti (tutta la storia)',
    description: 'I 5 numeri usciti più volte in tutte le estrazioni precedenti.',
    build: (_) => const FrequencyTopStrategy(),
  ),
  StrategyInfo(
    id: 'frequency-window',
    name: 'Più frequenti (finestra)',
    description: 'I 5 numeri usciti più volte nelle ultime N estrazioni.',
    usesWindow: true,
    build: (window) => WindowFrequencyStrategy(window),
  ),
  StrategyInfo(
    id: 'delay-top',
    name: 'Ritardatari',
    description: 'I 5 numeri con il ritardo corrente più lungo. Il ritardo non aumenta la probabilità di uscita.',
    build: (_) => const DelayTopStrategy(),
  ),
  StrategyInfo(
    id: 'hot-cold-mix',
    name: 'Caldi e freddi',
    description: '3 numeri più frequenti nella finestra più 2 ritardatari.',
    usesWindow: true,
    build: (window) => HotColdMixStrategy(window),
  ),
  StrategyInfo(
    id: 'spy-followers',
    name: 'Numeri spia',
    description: 'Prende i numeri dell\'ultima estrazione come spie e propone i 5 numeri che più spesso sono comparsi nell\'estrazione successiva a una spia.',
    build: (_) => const SpyFollowersStrategy(),
  ),
  StrategyInfo(
    id: 'pairs-top',
    name: 'Coppie frequenti',
    description: 'Unisce le coppie uscite più volte insieme nella finestra fino ad avere 5 numeri.',
    usesWindow: true,
    build: (window) => TopPairsStrategy(window),
  ),
  StrategyInfo(
    id: 'diametral-of-last',
    name: 'Diametrali dell\'ultima',
    description: 'A ogni numero dell\'ultima estrazione aggiunge 45 (modulo 90): il «diametrale» della tradizione.',
    build: (_) => const DiametralStrategy(),
  ),
  StrategyInfo(
    id: 'balanced-decades',
    name: 'Decine bilanciate',
    description: 'Un numero casuale da ciascuna di 5 decine diverse, scelte con il seed. È quasi una baseline con un vincolo di forma.',
    build: (_) => const BalancedDecadesStrategy(),
  ),
  StrategyInfo(
    id: 'random-baseline',
    name: 'Baseline casuale',
    description: '5 numeri uniformi con seed riproducibile. È il riferimento.',
    build: (_) => const RandomBaselineStrategy(),
  ),
]);

StrategyInfo? strategyInfoById(String id) {
  for (final info in studyStrategyCatalog) {
    if (info.id == id) return info;
  }
  return null;
}

List<ArchivedDraw> _tail(List<ArchivedDraw> history, int window) {
  if (window <= 0 || window >= history.length) return history;
  return history.sublist(history.length - window);
}

List<int> _rankedBy(List<int> score, {bool descending = true}) {
  return [for (var n = 1; n <= 90; n++) n]..sort((a, b) {
      final byScore = descending ? score[b].compareTo(score[a]) : score[a].compareTo(score[b]);
      if (byScore != 0) return byScore;
      return a.compareTo(b);
    });
}

List<int> _frequencies(List<ArchivedDraw> draws) {
  final counts = List<int>.filled(91, 0);
  for (final draw in draws) {
    for (final number in draw.numbers) {
      counts[number]++;
    }
  }
  return counts;
}

List<int> _currentDelays(List<ArchivedDraw> history) {
  final delay = List<int>.filled(91, history.length);
  for (var i = history.length - 1; i >= 0; i--) {
    for (final number in history[i].numbers) {
      final age = history.length - 1 - i;
      if (delay[number] == history.length) delay[number] = age;
    }
  }
  return delay;
}

class WindowFrequencyStrategy implements StudyStrategy {
  const WindowFrequencyStrategy(this.window);

  final int window;

  @override
  String get id => 'frequency-window-$window';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.isEmpty) return sampleUniform(5, Random(seed ^ contestIndex));
    return _rankedBy(_frequencies(_tail(historyBefore, window))).take(5).toList()..sort();
  }
}

class DelayTopStrategy implements StudyStrategy {
  const DelayTopStrategy();

  @override
  String get id => 'delay-top';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.isEmpty) return sampleUniform(5, Random(seed ^ contestIndex));
    return _rankedBy(_currentDelays(historyBefore)).take(5).toList()..sort();
  }
}

class HotColdMixStrategy implements StudyStrategy {
  const HotColdMixStrategy(this.window);

  final int window;

  @override
  String get id => 'hot-cold-mix-$window';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.isEmpty) return sampleUniform(5, Random(seed ^ contestIndex));
    final hot = _rankedBy(_frequencies(_tail(historyBefore, window))).take(3).toList();
    final cold = _rankedBy(_currentDelays(historyBefore)).where((n) => !hot.contains(n)).take(2);
    return [...hot, ...cold]..sort();
  }
}

/// Per ogni estrazione i che contiene una spia, conta i numeri dell'estrazione i+1.
/// Usa solo coppie (i, i+1) entrambe precedenti al concorso valutato.
class SpyFollowersStrategy implements StudyStrategy {
  const SpyFollowersStrategy();

  @override
  String get id => 'spy-followers';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.length < 2) return sampleUniform(5, Random(seed ^ contestIndex));
    final spies = historyBefore.last.numbers.toSet();
    final counts = List<int>.filled(91, 0);
    for (var i = 0; i < historyBefore.length - 1; i++) {
      if (!historyBefore[i].numbers.any(spies.contains)) continue;
      for (final number in historyBefore[i + 1].numbers) {
        counts[number]++;
      }
    }
    return _rankedBy(counts).take(5).toList()..sort();
  }
}

class TopPairsStrategy implements StudyStrategy {
  const TopPairsStrategy(this.window);

  final int window;

  @override
  String get id => 'pairs-top-$window';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.isEmpty) return sampleUniform(5, Random(seed ^ contestIndex));
    final counts = <int, int>{};
    for (final draw in _tail(historyBefore, window)) {
      final sorted = [...draw.numbers]..sort();
      for (var i = 0; i < sorted.length; i++) {
        for (var j = i + 1; j < sorted.length; j++) {
          final key = sorted[i] * 100 + sorted[j];
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    final chosen = <int>{};
    for (final entry in ranked) {
      if (chosen.length >= 5) break;
      chosen.add(entry.key ~/ 100);
      if (chosen.length >= 5) break;
      chosen.add(entry.key % 100);
    }
    if (chosen.length < 5) {
      for (final n in _rankedBy(_frequencies(historyBefore))) {
        if (chosen.length >= 5) break;
        chosen.add(n);
      }
    }
    return chosen.toList()..sort();
  }
}

class DiametralStrategy implements StudyStrategy {
  const DiametralStrategy();

  @override
  String get id => 'diametral-of-last';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    if (historyBefore.isEmpty) return sampleUniform(5, Random(seed ^ contestIndex));
    final out = <int>{for (final n in historyBefore.last.numbers) (n + 45 - 1) % 90 + 1};
    final random = Random(seed ^ contestIndex);
    while (out.length < 5) {
      out.add(random.nextInt(90) + 1);
    }
    return out.toList()..sort();
  }
}

class BalancedDecadesStrategy implements StudyStrategy {
  const BalancedDecadesStrategy();

  @override
  String get id => 'balanced-decades';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    final random = Random(seed + contestIndex * 7919);
    final decades = [for (var d = 0; d < 9; d++) d]..shuffle(random);
    return [for (final d in decades.take(5)) d * 10 + 1 + random.nextInt(10)]..sort();
  }
}

/// Backtest di tutti i metodi del catalogo sulla stessa finestra e lo stesso seed.
class StrategyComparisonRow {
  const StrategyComparisonRow({required this.info, required this.report});

  final StrategyInfo info;
  final BacktestReport report;
}

List<StrategyComparisonRow> compareStrategies({
  required List<ArchivedDraw> draws,
  required int seed,
  required int scoreFromIndex,
  required int window,
  int monteCarloRuns = 0,
}) {
  const engine = BacktestEngine();
  final rows = [
    for (final info in studyStrategyCatalog)
      StrategyComparisonRow(
        info: info,
        report: engine.run(
          draws: draws,
          strategy: info.build(window),
          seed: seed,
          scoreFromIndex: scoreFromIndex,
          monteCarloRuns: monteCarloRuns,
        ),
      ),
  ]..sort((a, b) => b.report.strategyMeanHits.compareTo(a.report.strategyMeanHits));
  return rows;
}

/// Avvertenza da mostrare sempre accanto a una classifica di metodi.
String multipleComparisonWarning(int methods) =>
    'Classifica di $methods metodi sugli stessi concorsi: il migliore di una lista sembra buono anche quando tutti sono equivalenti al caso. '
    'Una differenza va riprovata su un periodo diverso (out-of-sample) prima di prenderla sul serio, e anche allora non è una garanzia futura.';
