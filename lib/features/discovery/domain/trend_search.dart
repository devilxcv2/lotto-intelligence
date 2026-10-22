// lib/features/discovery/domain/trend_search.dart

import 'dart:isolate';
import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/combinations.dart';

/// Estrazioni per settimana usate come scala. Il calendario reale è martedì,
/// giovedì, venerdì e sabato: quattro concorsi.
const int drawsPerWeek = 4;

/// Quante estrazioni recenti servono a confrontare le regole fra loro.
const int trendScoreDraws = 80;

const String trendLimitation =
    'Queste regole sono state scelte e misurate sullo stesso archivio. '
    'La migliore di un elenco sta sopra la media anche per caso, e una finestra '
    'di poche settimane esce spesso dalla probabilità equa senza che il gioco sia cambiato. '
    'Se l\'estrazione è uniforme, ogni numero resta a 5/90 al prossimo concorso: '
    'il trend descrive il passato, non il numero che uscirà.';

class NumberTrend {
  const NumberTrend({
    required this.number,
    required this.recentHits,
    required this.previousHits,
    required this.recentDraws,
    required this.observedRate,
    required this.wilsonLow,
    required this.wilsonHigh,
    required this.delay,
  });

  final int number;
  final int recentHits;
  final int previousHits;
  final int recentDraws;
  final double observedRate;
  final double wilsonLow;
  final double wilsonHigh;
  final int delay;

  int get slope => recentHits - previousHits;

  bool get compatibleWithFair => wilsonLow <= singleNumberProbability && singleNumberProbability <= wilsonHigh;
}

class TriedRule {
  const TriedRule({
    required this.id,
    required this.name,
    required this.how,
    required this.proposal,
    required this.pool,
    required this.meanHits,
    required this.scoredDraws,
    required this.zScore,
  });

  final String id;
  final String name;
  final String how;
  final List<int> proposal;
  final List<int> pool;
  final double meanHits;
  final int scoredDraws;

  /// (media − teoria) / errore standard. Sopra 2 in valore assoluto è raro
  /// per una regola sola; fra tante regole provate non basta a dichiararla valida.
  final double zScore;
}

class DiscoveredSystem {
  const DiscoveredSystem({
    required this.pool,
    required this.columns,
    required this.guaranteeVerified,
    required this.coverageClaim,
  });

  final List<int> pool;
  final List<List<int>> columns;
  final bool guaranteeVerified;
  final String coverageClaim;
}

class TrendReport {
  const TrendReport({
    required this.weeks,
    required this.trends,
    required this.rules,
    required this.baselineMeanHits,
    required this.expectedMeanHits,
    required this.system,
    required this.limitation,
  });

  final int weeks;
  final List<NumberTrend> trends;
  final List<TriedRule> rules;
  final double baselineMeanHits;
  final double expectedMeanHits;
  final DiscoveredSystem? system;
  final String limitation;

  TriedRule? get selected => rules.isEmpty ? null : rules.first;
}

/// P(almeno un centro) se si giocano [played] numeri distinti su una ruota,
/// nel modello equo. Non dipende da quanto quei numeri siano «in trend».
double fairChanceOfAtLeastOneHit(int played) {
  if (played <= 0) return 0;
  if (played >= 90) return 1;
  final miss = binomial(90 - played, 5);
  final all = binomial(90, 5);
  if (all == BigInt.zero) return 0;
  return 1 - miss.toDouble() / all.toDouble();
}

/// Varianza del numero di centri di una cinquina fissa su una ruota equa.
double fairHitsVariance() {
  const n = 5.0;
  const k = 5.0;
  const population = 90.0;
  return n * (k / population) * (1 - k / population) * ((population - n) / (population - 1));
}

Future<TrendReport> searchTrendsInBackground({
  required List<ArchivedDraw> draws,
  required int weeks,
  required int seed,
  required int weekday,
}) {
  return Isolate.run(() => searchTrends(draws: draws, weeks: weeks, seed: seed, weekday: weekday));
}

TrendReport searchTrends({
  required List<ArchivedDraw> draws,
  required int weeks,
  required int seed,
  required int weekday,
}) {
  final span = weeks.clamp(2, 12);
  final rules = _rules(span);
  final scored = draws.length <= 24 ? 0 : min(trendScoreDraws, draws.length - 12);
  final start = draws.length - scored;
  final hits = {for (final rule in rules) rule.id: 0};
  var baselineHits = 0;
  for (var i = start; i < draws.length; i++) {
    final drawn = draws[i].numbers.toSet();
    final day = draws[i].date.toUtc().weekday;
    for (final rule in rules) {
      final proposal = rule.rank(draws, i, day).take(5);
      hits[rule.id] = hits[rule.id]! + proposal.where(drawn.contains).length;
    }
    baselineHits += sampleUniform(5, Random(seed + i * 9973)).where(drawn.contains).length;
  }
  final expected = 5 * singleNumberProbability;
  final stderr = scored == 0 ? 1.0 : sqrt(fairHitsVariance() / scored);
  final tried = [
    for (final rule in rules)
      TriedRule(
        id: rule.id,
        name: rule.name,
        how: rule.how,
        proposal: (rule.rank(draws, draws.length, weekday).take(5).toList()..sort()),
        pool: rule.rank(draws, draws.length, weekday).take(15).toList()..sort(),
        meanHits: scored == 0 ? 0 : hits[rule.id]! / scored,
        scoredDraws: scored,
        zScore: scored == 0 ? 0 : ((hits[rule.id]! / scored) - expected) / stderr,
      ),
  ]..sort((a, b) {
      final byMean = b.meanHits.compareTo(a.meanHits);
      if (byMean != 0) return byMean;
      return a.id.compareTo(b.id);
    });

  final selected = tried.isEmpty ? null : tried.first;
  DiscoveredSystem? system;
  if (selected != null && selected.pool.length >= 8) {
    final reduced = generateReduced(
      pool: selected.pool,
      combinationSize: 5,
      assumedHits: 3,
      guaranteedHits: 2,
      seed: seed,
    );
    if (reduced.combinations.isNotEmpty) {
      system = DiscoveredSystem(
        pool: selected.pool,
        columns: reduced.combinations,
        guaranteeVerified: reduced.guaranteeVerified,
        coverageClaim: reduced.coverageClaim,
      );
    }
  }

  return TrendReport(
    weeks: span,
    trends: _trends(draws, span),
    rules: tried,
    baselineMeanHits: scored == 0 ? 0 : baselineHits / scored,
    expectedMeanHits: expected,
    system: system,
    limitation: trendLimitation,
  );
}

class _Rule {
  const _Rule(this.id, this.name, this.how, this.rank);

  final String id;
  final String name;
  final String how;
  final List<int> Function(List<ArchivedDraw> draws, int end, int weekday) rank;
}

List<_Rule> _rules(int weeks) {
  final window = weeks * drawsPerWeek;
  return [
    _Rule(
      'freq-$weeks',
      'Frequenza delle ultime $weeks settimane',
      'I numeri usciti più volte nelle ultime $window estrazioni, circa $weeks settimane.',
      (draws, end, _) => _order(_counts(draws, _from(end, window), end)),
    ),
    _Rule(
      'slope-$weeks',
      'Pendenza sulle $weeks settimane',
      'Quelli cresciuti di più rispetto alle $weeks settimane precedenti.',
      (draws, end, _) => _order(_slope(draws, end, window)),
    ),
    _Rule(
      'weekday',
      'Stesso giorno della settimana',
      'Solo le estrazioni dello stesso giorno del concorso che si vuole guardare (martedì con i martedì, e così via).',
      (draws, end, weekday) => _order(_weekdayCounts(draws, end, weekday)),
    ),
    _Rule(
      'echo',
      'Eco a una e due settimane',
      'Privilegia i numeri usciti circa 4 e 8 estrazioni fa, l\'«eco» settimanale.',
      (draws, end, _) => _order(_echo(draws, end)),
    ),
    _Rule(
      'laterali',
      'Laterali dell\'ultima estrazione',
      'I vicini (n−1 e n+1) dei numeri appena usciti, poi la frequenza recente a spareggio.',
      (draws, end, _) => _order(_neighbors(draws, end, window)),
    ),
    _Rule(
      'rhythm',
      'Ritmo proprio del numero',
      'Numeri il cui ritardo attuale è vicino alla distanza media fra le loro uscite passate. È la versione misurata del «è in scadenza».',
      (draws, end, _) => _order(_rhythm(draws, end)),
    ),
    _Rule(
      'decades',
      'Decine in salita',
      'Prima la decina la cui frequenza è cresciuta, poi i numeri più presenti dentro quella decina.',
      (draws, end, _) => _order(_groupSlope(draws, end, window, (n) => (n - 1) ~/ 10)),
    ),
    _Rule(
      'finals',
      'Cifre finali in salita',
      'Come le decine, ma sulla cifra finale (0–9).',
      (draws, end, _) => _order(_groupSlope(draws, end, window, (n) => n % 10)),
    ),
    _Rule(
      'repeat',
      'Ripetizione breve',
      'Numeri dell\'ultima estrazione e di quella prima, l\'idea che un numero «ripetta» a breve.',
      (draws, end, _) => _order(_repeat(draws, end)),
    ),
    _Rule(
      'pairs',
      'Coppie della finestra',
      'Numeri che stanno nelle coppie uscite più spesso nelle ultime $window estrazioni.',
      (draws, end, _) => _order(_pairScore(draws, end, window)),
    ),
  ];
}

List<NumberTrend> _trends(List<ArchivedDraw> draws, int weeks) {
  final window = weeks * drawsPerWeek;
  final end = draws.length;
  final recentFrom = _from(end, window);
  final previousFrom = _from(recentFrom, window);
  final recent = _counts(draws, recentFrom, end);
  final previous = _counts(draws, previousFrom, recentFrom);
  final recentDraws = end - recentFrom;
  final delay = List<int>.filled(91, end);
  for (var i = end - 1; i >= 0; i--) {
    for (final number in draws[i].numbers) {
      if (delay[number] == end) delay[number] = end - 1 - i;
    }
  }
  final trends = <NumberTrend>[];
  for (var n = 1; n <= 90; n++) {
    final wilson = wilsonInterval(recent[n].round(), recentDraws == 0 ? 1 : recentDraws);
    trends.add(NumberTrend(
      number: n,
      recentHits: recent[n].round(),
      previousHits: previous[n].round(),
      recentDraws: recentDraws,
      observedRate: recentDraws == 0 ? 0 : recent[n] / recentDraws,
      wilsonLow: recentDraws == 0 ? 0 : wilson.$1,
      wilsonHigh: recentDraws == 0 ? 1 : wilson.$2,
      delay: delay[n],
    ));
  }
  trends.sort((a, b) {
    final bySlope = b.slope.abs().compareTo(a.slope.abs());
    if (bySlope != 0) return bySlope;
    return a.number.compareTo(b.number);
  });
  return trends;
}

int _from(int end, int length) => max(0, end - length);

List<double> _counts(List<ArchivedDraw> draws, int from, int end) {
  final score = List<double>.filled(91, 0);
  for (var i = max(0, from); i < end && i < draws.length; i++) {
    for (final number in draws[i].numbers) {
      score[number]++;
    }
  }
  return score;
}

List<double> _slope(List<ArchivedDraw> draws, int end, int window) {
  final recentFrom = _from(end, window);
  final recent = _counts(draws, recentFrom, end);
  final previous = _counts(draws, _from(recentFrom, window), recentFrom);
  return [for (var n = 0; n < 91; n++) recent[n] - previous[n]];
}

List<double> _weekdayCounts(List<ArchivedDraw> draws, int end, int weekday) {
  final score = List<double>.filled(91, 0);
  var seen = 0;
  for (var i = end - 1; i >= 0 && seen < 40; i--) {
    if (draws[i].date.toUtc().weekday != weekday) continue;
    seen++;
    for (final number in draws[i].numbers) {
      score[number]++;
    }
  }
  return score;
}

List<double> _echo(List<ArchivedDraw> draws, int end) {
  final score = List<double>.filled(91, 0);
  void add(int index, double weight) {
    if (index < 0 || index >= end) return;
    for (final number in draws[index].numbers) {
      score[number] += weight;
    }
  }

  for (var back = 3; back <= 5; back++) {
    add(end - 1 - back, 2);
  }
  for (var back = 7; back <= 9; back++) {
    add(end - 1 - back, 1);
  }
  return score;
}

List<double> _neighbors(List<ArchivedDraw> draws, int end, int window) {
  final score = _counts(draws, _from(end, window), end);
  if (end <= 0) return score;
  for (final number in draws[end - 1].numbers) {
    if (number > 1) score[number - 1] += 20;
    if (number < 90) score[number + 1] += 20;
  }
  return score;
}

List<double> _rhythm(List<ArchivedDraw> draws, int end) {
  final lastSeen = List<int>.filled(91, -1);
  final gapSum = List<int>.filled(91, 0);
  final gapCount = List<int>.filled(91, 0);
  for (var i = 0; i < end; i++) {
    for (final number in draws[i].numbers) {
      if (lastSeen[number] >= 0) {
        gapSum[number] += i - lastSeen[number];
        gapCount[number]++;
      }
      lastSeen[number] = i;
    }
  }
  final score = List<double>.filled(91, -100000);
  for (var n = 1; n <= 90; n++) {
    if (gapCount[n] < 2 || lastSeen[n] < 0) continue;
    final mean = gapSum[n] / gapCount[n];
    final delay = (end - 1) - lastSeen[n];
    score[n] = -(delay - mean).abs();
  }
  return score;
}

List<double> _groupSlope(List<ArchivedDraw> draws, int end, int window, int Function(int number) group) {
  final recentFrom = _from(end, window);
  final recent = _counts(draws, recentFrom, end);
  final previous = _counts(draws, _from(recentFrom, window), recentFrom);
  final slope = List<double>.filled(10, 0);
  for (var n = 1; n <= 90; n++) {
    slope[group(n)] += recent[n] - previous[n];
  }
  return [for (var n = 0; n < 91; n++) n == 0 ? 0.0 : slope[group(n)] * 100 + recent[n]];
}

List<double> _repeat(List<ArchivedDraw> draws, int end) {
  final score = List<double>.filled(91, 0);
  if (end >= 1) {
    for (final number in draws[end - 1].numbers) {
      score[number] += 10;
    }
  }
  if (end >= 2) {
    for (final number in draws[end - 2].numbers) {
      score[number] += 4;
    }
  }
  return score;
}

List<double> _pairScore(List<ArchivedDraw> draws, int end, int window) {
  final score = List<double>.filled(91, 0);
  for (var i = _from(end, window); i < end && i < draws.length; i++) {
    final numbers = draws[i].numbers;
    for (var a = 0; a < numbers.length; a++) {
      for (var b = a + 1; b < numbers.length; b++) {
        score[numbers[a]]++;
        score[numbers[b]]++;
      }
    }
  }
  return score;
}

List<int> _order(List<double> score) {
  return [for (var n = 1; n <= 90; n++) n]..sort((a, b) {
      final byScore = score[b].compareTo(score[a]);
      if (byScore != 0) return byScore;
      return a.compareTo(b);
    });
}
