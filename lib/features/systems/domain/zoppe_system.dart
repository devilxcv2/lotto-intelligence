// lib/features/systems/domain/zoppe_system.dart

import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';
import '../../statistics/domain/statistics_engine.dart';

/// Quante estrazioni recenti entrano nei conteggi. Descrivono il passato,
/// non la probabilità della prossima estrazione.
const int zoppeWindowDraws = 100;

const int zoppeHotPool = 12;
const int zoppeDelayPool = 12;
const int zoppeSampleColumns = 40;

/// Testo fisso della legenda: cosa fa ogni gamba della cinquina (o sestina).
const String zoppeLegendFive =
    'Il Sistemone Zoppe compone ogni cinquina con cinque gambe diverse: '
    '(1) un numero a caso fra i più gettonati (i più usciti nel periodo); '
    '(2) un numero fra i più ritardatari (i più assenti di recente); '
    '(3) uno nella fascia di frequenza 30–45; '
    '(4) uno nella fascia 50–65; '
    '(5) uno nella fascia 70–85. '
    'Le fasce e i ritardi descrivono l\'archivio. La probabilità equa di ogni numero resta 5/90.';

const String zoppeLegendSix =
    'Sul SuperEnalotto lo Zoppe usa sei gambe: le cinque del Lotto più una sesta '
    'nella fascia 15–30. Il Jolly e la SuperStar hanno suggerimenti separati, '
    'letti solo dalle serie storiche di Jolly e SuperStar. '
    'La probabilità equa di un numero nei sei estratti resta 6/90.';

class ZoppeScore {
  const ZoppeScore({required this.number, required this.hits, required this.delay, required this.percentile});

  final int number;
  final int hits;
  final int delay;

  /// Posto nella classifica di frequenza, da 0 (meno uscite) a 100 (più uscite).
  final double percentile;
}

class ZoppeLeg {
  const ZoppeLeg({required this.id, required this.label, required this.how, required this.pool});

  final String id;
  final String label;
  final String how;
  final List<int> pool;
}

class ZoppeResult {
  const ZoppeResult({
    required this.scores,
    required this.universe,
    required this.legs,
    required this.columns,
    required this.leadColumn,
    required this.leadHits,
    required this.windowDraws,
    required this.columnSize,
    required this.legend,
    required this.seed,
    this.error,
  });

  final List<ZoppeScore> scores;
  final List<int> universe;
  final List<ZoppeLeg> legs;
  final List<List<int>> columns;
  final List<int> leadColumn;
  final int leadHits;
  final int windowDraws;
  final int columnSize;
  final String legend;
  final int seed;
  final String? error;

  /// Id della gamba che ha fornito [number] nella colonna guida, se presente.
  String? roleOf(int number) {
    if (leadColumn.isEmpty || !leadColumn.contains(number)) return null;
    for (final leg in legs) {
      if (leg.pool.contains(number)) return leg.id;
    }
    return null;
  }

  Set<int> get allPoolNumbers => {for (final leg in legs) ...leg.pool};
}

/// Conteggi sulle ultime [window] estrazioni. [draws] è in ordine cronologico.
({Map<int, int> hits, Map<int, int> delay}) frequencyAndDelay(
  List<ArchivedDraw> draws, {
  int window = zoppeWindowDraws,
}) {
  final recent = draws.length <= window ? draws : draws.sublist(draws.length - window);
  final hits = {for (var number = 1; number <= 90; number++) number: 0};
  final last = {for (var number = 1; number <= 90; number++) number: -1};
  for (var index = 0; index < recent.length; index++) {
    for (final number in recent[index].numbers) {
      if (number < 1 || number > 90) continue;
      hits[number] = hits[number]! + 1;
      last[number] = index;
    }
  }
  final total = recent.length;
  final delay = {
    for (var number = 1; number <= 90; number++) number: last[number]! < 0 ? total : total - 1 - last[number]!,
  };
  return (hits: hits, delay: delay);
}

/// Compatibilità con le chiamate che contavano solo le uscite.
Map<int, int> frequencyInWindow(List<ArchivedDraw> draws, {int window = zoppeWindowDraws}) {
  return frequencyAndDelay(draws, window: window).hits;
}

double zoppeFairAtLeastOne(int played, {int drawSize = 5}) {
  if (played <= 0) return 0;
  if (played >= 90) return 1;
  final miss = binomial(90 - played, drawSize);
  final all = binomial(90, drawSize);
  if (all == BigInt.zero) return 0;
  return 1 - miss.toDouble() / all.toDouble();
}

/// Sistemone Zoppe: una gamba a caso fra i gettonati, una fra i ritardatari,
/// poi una per ogni fascia di frequenza (30–45, 50–65, 70–85; se [columnSize]
/// è 6 anche 15–30). [universe] vuoto = tutti i 90.
ZoppeResult buildZoppeSystem({
  required Map<int, int> hits,
  required Map<int, int> delays,
  Set<int> universe = const {},
  int columnSize = 5,
  int seed = 42,
  int windowDraws = 0,
  int sampleColumns = zoppeSampleColumns,
}) {
  final scores = _scores(hits, delays);
  final allowed = universe.isEmpty
      ? [for (var number = 1; number <= 90; number++) number]
      : (universe.where((number) => number >= 1 && number <= 90).toSet().toList()..sort());
  final legend = columnSize >= 6 ? zoppeLegendSix : zoppeLegendFive;
  final empty = ZoppeResult(
    scores: scores,
    universe: allowed,
    legs: const [],
    columns: const [],
    leadColumn: const [],
    leadHits: 0,
    windowDraws: windowDraws,
    columnSize: columnSize,
    legend: legend,
    seed: seed,
  );
  if (allowed.length < columnSize) {
    return _fail(empty, 'Servono almeno $columnSize numeri nell\'universo (maschera o tutti i 90).');
  }
  if (columnSize < 5 || columnSize > 6) {
    return _fail(empty, 'Lo Zoppe costruisce colonne da 5 (Lotto) o da 6 (SuperEnalotto).');
  }

  final legs = _legs(scores, allowed, columnSize);
  final missing = [for (final leg in legs) if (leg.pool.isEmpty) leg.label];
  if (missing.isNotEmpty) {
    return _fail(empty, 'Queste gambe sono vuote in questo periodo: ${missing.join(', ')}. Allarga la maschera o attendi più estrazioni.');
  }

  final columns = _sampleColumns(legs: legs, columnSize: columnSize, seed: seed, count: sampleColumns, scores: scores);
  if (columns.isEmpty) {
    return _fail(empty, 'Non è stato possibile mescolare le gambe senza ripetere un numero. Allarga la maschera.');
  }
  final lead = columns.first;
  return ZoppeResult(
    scores: scores,
    universe: allowed,
    legs: legs,
    columns: columns,
    leadColumn: lead,
    leadHits: _weight(lead, scores),
    windowDraws: windowDraws,
    columnSize: columnSize,
    legend: legend,
    seed: seed,
  );
}

ZoppeResult _fail(ZoppeResult empty, String error) {
  return ZoppeResult(
    scores: empty.scores,
    universe: empty.universe,
    legs: const [],
    columns: const [],
    leadColumn: const [],
    leadHits: 0,
    windowDraws: empty.windowDraws,
    columnSize: empty.columnSize,
    legend: empty.legend,
    seed: empty.seed,
    error: error,
  );
}

List<ZoppeLeg> _legs(List<ZoppeScore> scores, List<int> allowed, int columnSize) {
  final hot = [...allowed]
    ..sort((a, b) {
      final byHits = scores[b - 1].hits.compareTo(scores[a - 1].hits);
      if (byHits != 0) return byHits;
      return a.compareTo(b);
    });
  final delayed = [...allowed]
    ..sort((a, b) {
      final byDelay = scores[b - 1].delay.compareTo(scores[a - 1].delay);
      if (byDelay != 0) return byDelay;
      return a.compareTo(b);
    });

  final legs = <ZoppeLeg>[
    ZoppeLeg(
      id: 'gettonato',
      label: 'Gettonato',
      how: 'Un numero a caso fra i $zoppeHotPool più usciti.',
      pool: hot.take(min(zoppeHotPool, hot.length)).toList()..sort(),
    ),
    ZoppeLeg(
      id: 'ritardatario',
      label: 'Ritardatario',
      how: 'Un numero fra i $zoppeDelayPool più assenti di recente.',
      pool: delayed.take(min(zoppeDelayPool, delayed.length)).toList()..sort(),
    ),
    ZoppeLeg(
      id: 'fascia_30_45',
      label: 'Fascia 30–45',
      how: 'Percentile di frequenza fra 30 e 45.',
      pool: _band(scores, allowed, 30, 45),
    ),
    ZoppeLeg(
      id: 'fascia_50_65',
      label: 'Fascia 50–65',
      how: 'Percentile di frequenza fra 50 e 65.',
      pool: _band(scores, allowed, 50, 65),
    ),
    ZoppeLeg(
      id: 'fascia_70_85',
      label: 'Fascia 70–85',
      how: 'Percentile di frequenza fra 70 e 85.',
      pool: _band(scores, allowed, 70, 85),
    ),
  ];
  if (columnSize >= 6) {
    legs.add(ZoppeLeg(
      id: 'fascia_15_30',
      label: 'Fascia 15–30',
      how: 'Sesta gamba: percentile di frequenza fra 15 e 30.',
      pool: _band(scores, allowed, 15, 30),
    ));
  }
  return legs;
}

List<int> _band(List<ZoppeScore> scores, List<int> allowed, double low, double high) {
  final exact = [
    for (final number in allowed)
      if (scores[number - 1].percentile >= low && scores[number - 1].percentile <= high) number,
  ];
  if (exact.isNotEmpty) return exact;
  // Pari merito o finestre corte: si prendono i più vicini al centro della fascia.
  final mid = (low + high) / 2;
  final ranked = [...allowed]
    ..sort((a, b) {
      final byDistance = (scores[a - 1].percentile - mid).abs().compareTo((scores[b - 1].percentile - mid).abs());
      if (byDistance != 0) return byDistance;
      return a.compareTo(b);
    });
  return ranked.take(min(12, ranked.length)).toList()..sort();
}

List<List<int>> _sampleColumns({
  required List<ZoppeLeg> legs,
  required int columnSize,
  required int seed,
  required int count,
  required List<ZoppeScore> scores,
}) {
  final out = <List<int>>[];
  final seen = <String>{};
  final random = Random(seed);
  for (var attempt = 0; attempt < count * 8 && out.length < count; attempt++) {
    final picked = <int>{};
    final column = <int>[];
    var ok = true;
    for (final leg in legs) {
      final candidates = [for (final number in leg.pool) if (!picked.contains(number)) number];
      if (candidates.isEmpty) {
        ok = false;
        break;
      }
      final choice = candidates[random.nextInt(candidates.length)];
      picked.add(choice);
      column.add(choice);
    }
    if (!ok || column.length != columnSize) continue;
    column.sort();
    if (seen.add(column.join(','))) out.add(List<int>.unmodifiable(column));
  }
  out.sort((a, b) {
    final byWeight = _weight(b, scores).compareTo(_weight(a, scores));
    if (byWeight != 0) return byWeight;
    for (var i = 0; i < a.length; i++) {
      final order = a[i].compareTo(b[i]);
      if (order != 0) return order;
    }
    return 0;
  });
  return out;
}

int _weight(List<int> column, List<ZoppeScore> scores) {
  var total = 0;
  for (final number in column) {
    total += scores[number - 1].hits;
  }
  return total;
}

List<ZoppeScore> _scores(Map<int, int> hits, Map<int, int> delays) {
  final counts = [for (var number = 1; number <= 90; number++) hits[number] ?? 0];
  final order = [for (var number = 1; number <= 90; number++) number]
    ..sort((a, b) {
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
      ZoppeScore(
        number: number,
        hits: counts[number - 1],
        delay: delays[number] ?? 0,
        percentile: percentile[number - 1],
      ),
  ];
}
