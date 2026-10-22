// lib/features/systems/domain/zoppe_system.dart

import '../../../core/lotto/hypergeometric.dart';
import '../../statistics/domain/statistics_engine.dart';

/// Fascia di percentile di frequenza letta sulla maschera negativa.
const double zoppeBandLow = 30;
const double zoppeBandHigh = 45;

/// Quante estrazioni recenti entrano nel conteggio. La valenza è questo
/// conteggio, non la probabilità della prossima estrazione.
const int zoppeWindowDraws = 100;

const int zoppeColumnSize = 5;
const int zoppeMaxColumns = 20000;

class ZoppeScore {
  const ZoppeScore({required this.number, required this.hits, required this.percentile});

  final int number;
  final int hits;

  /// Posto nella classifica di frequenza dei 90 numeri, da 0 (meno uscite)
  /// a 100 (più uscite). I pari merito hanno lo stesso percentile.
  final double percentile;
}

class ZoppeResult {
  const ZoppeResult({
    required this.scores,
    required this.positiveMask,
    required this.negativeMask,
    required this.positiveSlice,
    required this.negativeBand,
    required this.fromPositive,
    required this.fromNegative,
    required this.columns,
    required this.leadColumn,
    required this.leadHits,
    required this.trimmed,
    required this.windowDraws,
    required this.positiveShare,
    this.error,
  });

  final List<ZoppeScore> scores;
  final List<int> positiveMask;
  final List<int> negativeMask;

  /// Il 10–15% con più uscite dentro la maschera positiva.
  final List<int> positiveSlice;

  /// Numeri della maschera negativa il cui percentile sta fra 30 e 45.
  final List<int> negativeBand;
  final int fromPositive;
  final int fromNegative;
  final List<List<int>> columns;
  final List<int> leadColumn;
  final int leadHits;
  final bool trimmed;
  final int windowDraws;
  final double positiveShare;
  final String? error;

  ZoppeScore scoreOf(int number) => scores[number - 1];
}

/// Conteggi sulle ultime [window] estrazioni. [draws] è in ordine cronologico.
Map<int, int> frequencyInWindow(List<ArchivedDraw> draws, {int window = zoppeWindowDraws}) {
  final recent = draws.length <= window ? draws : draws.sublist(draws.length - window);
  final hits = {for (var number = 1; number <= 90; number++) number: 0};
  for (final draw in recent) {
    for (final number in draw.numbers) {
      if (number >= 1 && number <= 90) hits[number] = hits[number]! + 1;
    }
  }
  return hits;
}

/// P(almeno un centro) se si tengono d'occhio [played] numeri, modello equo.
double zoppeFairAtLeastOne(int played) {
  if (played <= 0) return 0;
  if (played >= 90) return 1;
  final miss = binomial(90 - played, 5);
  final all = binomial(90, 5);
  if (all == BigInt.zero) return 0;
  return 1 - miss.toDouble() / all.toDouble();
}

/// Sistemone Zoppe.
///
/// La maschera positiva è il pronostico già scelto. La maschera negativa è
/// il complemento sui 90. Dalla negativa si tengono i numeri il cui
/// percentile di frequenza sta fra 30 e 45. Dalla positiva si tiene il
/// 10–15% con più uscite. Ogni colonna mescola le due gambe, con meno
/// numeri dalla positiva: è la gamba corta, da cui il nome.
///
/// Il percentile non è la probabilità di uscire. Quella, nel modello equo,
/// resta [singleNumberProbability] per ogni numero.
ZoppeResult buildZoppeSystem({
  required Set<int> positiveMask,
  required Map<int, int> hits,
  double positiveShare = 0.12,
  int windowDraws = 0,
}) {
  final share = positiveShare.clamp(0.10, 0.15);
  final scores = _scores(hits);
  final positive = (positiveMask.where((number) => number >= 1 && number <= 90).toSet().toList()..sort());
  final negative = [for (var number = 1; number <= 90; number++) if (!positive.contains(number)) number];
  final empty = ZoppeResult(
    scores: scores,
    positiveMask: positive,
    negativeMask: negative,
    positiveSlice: const [],
    negativeBand: const [],
    fromPositive: 0,
    fromNegative: 0,
    columns: const [],
    leadColumn: const [],
    leadHits: 0,
    trimmed: false,
    windowDraws: windowDraws,
    positiveShare: share,
  );
  if (positive.isEmpty) {
    return _withError(empty, 'Segna prima la maschera positiva: i numeri che vuoi tenere sulla griglia.');
  }
  if (negative.isEmpty) {
    return _withError(empty, 'La maschera positiva copre tutti i 90 numeri: la maschera negativa è vuota.');
  }

  final byHits = [...positive]..sort((a, b) {
      final byCount = scores[b - 1].hits.compareTo(scores[a - 1].hits);
      if (byCount != 0) return byCount;
      return a.compareTo(b);
    });
  final take = (byHits.length * share).ceil().clamp(1, byHits.length);
  final slice = (byHits.take(take).toList()..sort());
  final band = [
    for (final number in negative)
      if (scores[number - 1].percentile >= zoppeBandLow && scores[number - 1].percentile <= zoppeBandHigh) number,
  ];

  final shaped = _shape(slice.length, band.length);
  if (shaped == null) {
    return _withError(
      empty,
      'In questo periodo la fascia 30–45 della maschera negativa non basta, insieme alla fetta positiva, '
      'a comporre una cinquina. Allarga o stringi la maschera positiva e riprova.',
      positiveSlice: slice,
      negativeBand: band,
    );
  }

  var usedBand = [...band];
  var trimmed = false;
  while (_columnCount(slice.length, shaped.$1, usedBand.length, shaped.$2) > BigInt.from(zoppeMaxColumns) &&
      usedBand.length > shaped.$2) {
    trimmed = true;
    usedBand.sort((a, b) {
      final distance = (scores[a - 1].percentile - 37.5).abs().compareTo((scores[b - 1].percentile - 37.5).abs());
      if (distance != 0) return distance;
      return a.compareTo(b);
    });
    usedBand.removeLast();
  }
  usedBand.sort();
  if (_columnCount(slice.length, shaped.$1, usedBand.length, shaped.$2) > BigInt.from(zoppeMaxColumns)) {
    return _withError(
      empty,
      'Le colonne da mescolare superano $zoppeMaxColumns. Stringi la maschera positiva.',
      positiveSlice: slice,
      negativeBand: usedBand,
      fromPositive: shaped.$1,
      fromNegative: shaped.$2,
      trimmed: trimmed,
    );
  }

  final columns = <List<int>>[];
  for (final left in _subsets(slice, shaped.$1)) {
    for (final right in _subsets(usedBand, shaped.$2)) {
      columns.add([...left, ...right]..sort());
    }
  }
  columns.sort((a, b) {
    final byWeight = _weight(b, scores).compareTo(_weight(a, scores));
    if (byWeight != 0) return byWeight;
    for (var i = 0; i < a.length; i++) {
      final order = a[i].compareTo(b[i]);
      if (order != 0) return order;
    }
    return 0;
  });
  final lead = columns.first;
  return ZoppeResult(
    scores: scores,
    positiveMask: positive,
    negativeMask: negative,
    positiveSlice: slice,
    negativeBand: usedBand,
    fromPositive: shaped.$1,
    fromNegative: shaped.$2,
    columns: columns,
    leadColumn: lead,
    leadHits: _weight(lead, scores),
    trimmed: trimmed,
    windowDraws: windowDraws,
    positiveShare: share,
  );
}

ZoppeResult _withError(
  ZoppeResult empty,
  String error, {
  List<int> positiveSlice = const [],
  List<int> negativeBand = const [],
  int fromPositive = 0,
  int fromNegative = 0,
  bool trimmed = false,
}) {
  return ZoppeResult(
    scores: empty.scores,
    positiveMask: empty.positiveMask,
    negativeMask: empty.negativeMask,
    positiveSlice: positiveSlice,
    negativeBand: negativeBand,
    fromPositive: fromPositive,
    fromNegative: fromNegative,
    columns: const [],
    leadColumn: const [],
    leadHits: 0,
    trimmed: trimmed,
    windowDraws: empty.windowDraws,
    positiveShare: empty.positiveShare,
    error: error,
  );
}

/// 2+3 quando le due gambe lo permettono, altrimenti 1+4.
(int, int)? _shape(int positiveCount, int negativeCount) {
  if (positiveCount >= 2 && negativeCount >= 3) return (2, 3);
  if (positiveCount >= 1 && negativeCount >= 4) return (1, 4);
  return null;
}

BigInt _columnCount(int positiveCount, int fromPositive, int negativeCount, int fromNegative) {
  return binomial(positiveCount, fromPositive) * binomial(negativeCount, fromNegative);
}

int _weight(List<int> column, List<ZoppeScore> scores) {
  var total = 0;
  for (final number in column) {
    total += scores[number - 1].hits;
  }
  return total;
}

List<ZoppeScore> _scores(Map<int, int> hits) {
  final counts = [for (var number = 1; number <= 90; number++) hits[number] ?? 0];
  final order = [for (var number = 1; number <= 90; number++) number]..sort((a, b) {
      final byCount = counts[a - 1].compareTo(counts[b - 1]);
      if (byCount != 0) return byCount;
      return a.compareTo(b);
    });
  final percentile = List<double>.filled(90, 0);
  var index = 0;
  while (index < 90) {
    var end = index + 1;
    while (end < 90 && counts[order[end] - 1] == counts[order[index] - 1]) {
      end++;
    }
    final average = (index + (end - 1)) / 2;
    final value = average / 89 * 100;
    for (var cursor = index; cursor < end; cursor++) {
      percentile[order[cursor] - 1] = value;
    }
    index = end;
  }
  return [
    for (var number = 1; number <= 90; number++)
      ZoppeScore(number: number, hits: counts[number - 1], percentile: percentile[number - 1]),
  ];
}

List<List<int>> _subsets(List<int> source, int size) {
  final out = <List<int>>[];
  final picked = <int>[];
  void walk(int start) {
    if (picked.length == size) {
      out.add(List<int>.from(picked));
      return;
    }
    for (var index = start; index <= source.length - (size - picked.length); index++) {
      picked.add(source[index]);
      walk(index + 1);
      picked.removeLast();
    }
  }

  if (size >= 0 && size <= source.length) walk(0);
  return out;
}
