// lib/features/systems/domain/combinations.dart

import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';

/// Limite di colonne restituite e di combinazioni esplorate.
/// Oltre queste soglie il laboratorio si ferma e mostra la stima,
/// senza presentare un sistema parziale come copertura integrale.
const int maxReturnedCombinations = 200000;
const int maxScannedCombinations = 10000000;

/// Il ridotto usa maschere di bit su interi a 64 bit e una verifica
/// esaustiva su tutti i casi: oltre queste soglie il tempo non è gestibile.
const int maxReducedPool = 60;
const int maxReducedCases = 600000;

const int minColumnSize = 2;
const int maxColumnSize = 10;

class CombinationFilter {
  const CombinationFilter({
    this.minEven = 0,
    this.maxEven = maxColumnSize,
    this.minSum = 0,
    this.maxSum = 1000,
    this.maxConsecutiveRun = maxColumnSize,
    this.maxPerDecade = maxColumnSize,
    this.allowedFinalDigits,
  });

  final int minEven;
  final int maxEven;
  final int minSum;
  final int maxSum;
  final int maxConsecutiveRun;
  final int maxPerDecade;
  final Set<int>? allowedFinalDigits;

  bool accepts(List<int> sorted) {
    var even = 0;
    var sum = 0;
    var run = 1;
    var longest = 1;
    final decades = List<int>.filled(9, 0);
    for (var i = 0; i < sorted.length; i++) {
      final number = sorted[i];
      sum += number;
      if (number.isEven) even++;
      decades[(number - 1) ~/ 10]++;
      if (allowedFinalDigits != null && !allowedFinalDigits!.contains(number % 10)) {
        return false;
      }
      if (i > 0 && number == sorted[i - 1] + 1) {
        run++;
        if (run > longest) longest = run;
      } else if (i > 0) {
        run = 1;
      }
    }
    if (even < minEven || even > maxEven) return false;
    if (sum < minSum || sum > maxSum) return false;
    if (longest > maxConsecutiveRun) return false;
    for (final count in decades) {
      if (count > maxPerDecade) return false;
    }
    return true;
  }

  /// Vero solo se nessuna colonna da 2 a 10 numeri può essere scartata.
  bool get isNeutral =>
      minEven <= 0 &&
      maxEven >= maxColumnSize &&
      minSum <= 3 &&
      maxSum >= 855 &&
      maxConsecutiveRun >= maxColumnSize &&
      maxPerDecade >= maxColumnSize &&
      (allowedFinalDigits == null || allowedFinalDigits!.length == 10);
}

enum GenerationMode { integral, reduced, parametric }

class GenerationEstimate {
  const GenerationEstimate({
    required this.poolSize,
    required this.combinationSize,
    required this.total,
    required this.returnedLimit,
    required this.scanLimit,
    required this.canBuildIntegral,
    required this.canScan,
  });

  final int poolSize;
  final int combinationSize;
  final BigInt total;
  final int returnedLimit;
  final int scanLimit;
  final bool canBuildIntegral;
  final bool canScan;

  /// Ordine di grandezza della memoria per tenere tutte le colonne:
  /// una lista Dart di k interi più l'intestazione dell'oggetto.
  int bytesFor(int columns) => columns * (combinationSize * 8 + 32);
}

class GenerationResult {
  const GenerationResult({
    required this.combinations,
    required this.estimate,
    required this.scanned,
    required this.complete,
    required this.coverageClaim,
    required this.cancelled,
    this.guaranteeVerified = false,
  });

  final List<List<int>> combinations;
  final GenerationEstimate estimate;
  final int scanned;
  final bool complete;
  final String coverageClaim;
  final bool cancelled;

  /// Vero solo per un ridotto la cui garanzia è stata ricontrollata
  /// su tutti i casi possibili dopo la costruzione.
  final bool guaranteeVerified;
}

GenerationEstimate estimateCombinations({
  required int poolSize,
  required int combinationSize,
  int returnedLimit = maxReturnedCombinations,
  int scanLimit = maxScannedCombinations,
}) {
  final total = binomial(poolSize, combinationSize);
  return GenerationEstimate(
    poolSize: poolSize,
    combinationSize: combinationSize,
    total: total,
    returnedLimit: returnedLimit,
    scanLimit: scanLimit,
    canBuildIntegral: total <= BigInt.from(returnedLimit),
    canScan: total <= BigInt.from(scanLimit),
  );
}

/// Sistema integrale: tutte le combinazioni k del pronostico, in ordine
/// lessicografico. La copertura «ogni k-upla compare una volta» vale solo
/// se il risultato è completo e senza filtri.
GenerationResult generateIntegral({
  required List<int> pool,
  required int combinationSize,
  CombinationFilter filter = const CombinationFilter(),
  int returnedLimit = maxReturnedCombinations,
  int scanLimit = maxScannedCombinations,
  bool Function()? isCancelled,
  void Function(int scanned, int kept)? onProgress,
}) {
  final unique = {...pool}.toList()..sort();
  final estimate = estimateCombinations(
    poolSize: unique.length,
    combinationSize: combinationSize,
    returnedLimit: returnedLimit,
    scanLimit: scanLimit,
  );
  if (combinationSize < 1 || combinationSize > unique.length) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: 0,
      complete: false,
      coverageClaim: 'Parametri non validi: la combinazione non può essere più lunga del pronostico.',
      cancelled: false,
    );
  }
  if (!estimate.canScan) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: 0,
      complete: false,
      coverageClaim: 'Generazione non avviata: le combinazioni teoriche sono ${estimate.total} e superano il limite di scansione $scanLimit.',
      cancelled: false,
    );
  }
  if (filter.isNeutral && !estimate.canBuildIntegral) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: 0,
      complete: false,
      coverageClaim:
          'Sistema integrale non generato: servono ${estimate.total} combinazioni e il limite è $returnedLimit. Riduci il pronostico o usa un ridotto. Un elenco parziale non è una copertura integrale.',
      cancelled: false,
    );
  }

  final kept = <List<int>>[];
  var scanned = 0;
  var cancelled = false;
  final chosen = List<int>.filled(combinationSize, 0);

  void walk(int start, int depth) {
    if (cancelled || kept.length >= returnedLimit) return;
    if (depth == combinationSize) {
      scanned++;
      final row = [for (final index in chosen) unique[index]];
      if (filter.accepts(row)) kept.add(row);
      if (scanned % 16384 == 0) {
        onProgress?.call(scanned, kept.length);
        if (isCancelled?.call() == true) cancelled = true;
      }
      return;
    }
    final last = unique.length - (combinationSize - depth);
    for (var i = start; i <= last; i++) {
      chosen[depth] = i;
      walk(i + 1, depth + 1);
      if (cancelled || kept.length >= returnedLimit) return;
    }
  }

  if (isCancelled?.call() == true) cancelled = true;
  walk(0, 0);
  onProgress?.call(scanned, kept.length);
  final neutral = filter.isNeutral;
  final finishedFullScan = !cancelled && scanned == estimate.total.toInt();
  final hitCap = kept.length >= returnedLimit && !finishedFullScan;
  final String claim;
  if (cancelled) {
    claim = 'Generazione annullata. Nessuna copertura è garantita.';
  } else if (neutral && finishedFullScan) {
    claim = 'Sistema integrale completo: ogni combinazione di $combinationSize numeri del pronostico compare esattamente una volta.';
  } else if (!neutral && finishedFullScan && !hitCap) {
    claim = 'Elenco filtrato completo rispetto al pronostico. Non è un sistema ridotto a copertura garantita: sono state tenute solo le combinazioni che passano i filtri.';
  } else {
    claim = 'Elenco incompleto. Non va letto come copertura integrale né come sistema ridotto.';
  }
  return GenerationResult(
    combinations: kept,
    estimate: estimate,
    scanned: scanned,
    complete: finishedFullScan && !cancelled && !hitCap,
    coverageClaim: claim,
    cancelled: cancelled,
  );
}

/// Generazione casuale uniforme senza copertura combinatoria.
GenerationResult generateParametric({
  required List<int> pool,
  required int combinationSize,
  required int count,
  required Random random,
  CombinationFilter filter = const CombinationFilter(),
  bool Function()? isCancelled,
  void Function(int kept, int target)? onProgress,
}) {
  final unique = {...pool}.toList()..sort();
  final estimate = estimateCombinations(poolSize: unique.length, combinationSize: combinationSize);
  if (combinationSize < 1 || combinationSize > unique.length) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: 0,
      complete: false,
      coverageClaim: 'Parametri non validi: la combinazione non può essere più lunga del pronostico.',
      cancelled: false,
    );
  }
  var target = min(count, maxReturnedCombinations);
  if (estimate.total < BigInt.from(target)) target = estimate.total.toInt();
  final kept = <List<int>>[];
  final seen = <String>{};
  final attemptCap = max(target * 80, target);
  var attempts = 0;
  var cancelled = false;
  while (kept.length < target && attempts < attemptCap) {
    attempts++;
    if (attempts % 4096 == 0) {
      onProgress?.call(kept.length, target);
      if (isCancelled?.call() == true) {
        cancelled = true;
        break;
      }
    }
    final row = _sample(unique, combinationSize, random)..sort();
    if (!filter.accepts(row)) continue;
    if (seen.add(row.join(','))) kept.add(row);
  }
  onProgress?.call(kept.length, target);
  return GenerationResult(
    combinations: kept,
    estimate: estimate,
    scanned: attempts,
    complete: false,
    coverageClaim: kept.length < target && !cancelled
        ? 'Generazione parametrica uniforme, senza copertura garantita. Trovate ${kept.length} colonne distinte su $target richieste: i filtri ne scartano molte.'
        : 'Generazione parametrica uniforme, senza copertura garantita. I duplicati sono stati scartati.',
    cancelled: cancelled,
  );
}

/// Problemi che impediscono un ridotto; `null` se i parametri sono validi.
String? reducedParametersProblem({
  required int poolSize,
  required int combinationSize,
  required int assumedHits,
  required int guaranteedHits,
}) {
  if (poolSize > maxReducedPool) return 'Il ridotto accetta al massimo $maxReducedPool numeri nel pronostico.';
  if (combinationSize < minColumnSize || combinationSize > maxColumnSize) {
    return 'Le colonne devono avere da $minColumnSize a $maxColumnSize numeri.';
  }
  if (combinationSize >= poolSize) return 'Il pronostico deve avere più numeri della colonna.';
  if (assumedHits < 2 || assumedHits > 5) return 'Si possono ipotizzare da 2 a 5 estratti nel pronostico.';
  if (assumedHits > poolSize) return 'Il pronostico ha meno numeri degli estratti ipotizzati.';
  if (guaranteedHits < 2 || guaranteedHits > assumedHits || guaranteedHits > combinationSize) {
    return 'La garanzia deve essere fra 2 e il minimo fra estratti ipotizzati e numeri per colonna.';
  }
  final cases = binomial(poolSize, assumedHits);
  if (cases > BigInt.from(maxReducedCases)) {
    return 'I casi da verificare sono $cases, oltre il limite di $maxReducedCases. Riduci il pronostico o gli estratti ipotizzati.';
  }
  return null;
}

/// Sistema ridotto: se almeno [assumedHits] dei 5 estratti cadono nel
/// pronostico, almeno una colonna ne contiene [guaranteedHits] o più.
///
/// Costruzione greedy (ogni colonna scelta fra candidati casuali con seed
/// riproducibile, prendendo quella che copre più casi ancora scoperti),
/// poi verifica esaustiva indipendente su tutti i C(n, assumedHits) casi.
/// La garanzia è dichiarata solo se la verifica passa. Il numero di colonne
/// non è dimostrato minimo.
GenerationResult generateReduced({
  required List<int> pool,
  required int combinationSize,
  required int assumedHits,
  required int guaranteedHits,
  required int seed,
  bool Function()? isCancelled,
  void Function(double fraction)? onProgress,
}) {
  final unique = {...pool}.toList()..sort();
  final v = unique.length;
  final estimate = estimateCombinations(poolSize: v, combinationSize: combinationSize);
  final problem = reducedParametersProblem(
    poolSize: v,
    combinationSize: combinationSize,
    assumedHits: assumedHits,
    guaranteedHits: guaranteedHits,
  );
  if (problem != null) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: 0,
      complete: false,
      coverageClaim: 'Ridotto non generato. $problem',
      cancelled: false,
    );
  }

  final cases = _subsetMasks(v, assumedHits);
  var uncovered = List<int>.of(cases);
  final random = Random(seed);
  final blocks = <int>[];
  var cancelled = false;

  while (uncovered.isNotEmpty) {
    if (isCancelled?.call() == true) {
      cancelled = true;
      break;
    }
    final target = uncovered[random.nextInt(uncovered.length)];
    final targetIndexes = _indexesOf(target);
    final candidates = (4000000 ~/ uncovered.length).clamp(6, 64);
    var best = 0;
    var bestCovered = -1;
    for (var c = 0; c < candidates; c++) {
      final block = _candidateBlock(targetIndexes, v, combinationSize, guaranteedHits, random);
      var covered = 0;
      for (final item in uncovered) {
        if (popCount(item & block) >= guaranteedHits) covered++;
      }
      if (covered > bestCovered) {
        bestCovered = covered;
        best = block;
      }
    }
    blocks.add(best);
    final remaining = <int>[];
    for (final item in uncovered) {
      if (popCount(item & best) < guaranteedHits) remaining.add(item);
    }
    uncovered = remaining;
    onProgress?.call(0.9 * (1 - uncovered.length / cases.length));
  }

  if (cancelled) {
    return GenerationResult(
      combinations: const [],
      estimate: estimate,
      scanned: cases.length - uncovered.length,
      complete: false,
      coverageClaim: 'Generazione annullata. Nessuna garanzia.',
      cancelled: true,
    );
  }

  final verified = verifyReducedGuarantee(
    blocks: blocks,
    poolSize: v,
    assumedHits: assumedHits,
    guaranteedHits: guaranteedHits,
  );
  onProgress?.call(1);
  final columns = [
    for (final block in blocks) [for (final index in _indexesOf(block)) unique[index]],
  ]..sort(_compareRows);
  return GenerationResult(
    combinations: columns,
    estimate: estimate,
    scanned: cases.length,
    complete: verified,
    cancelled: false,
    guaranteeVerified: verified,
    coverageClaim: verified
        ? 'Ridotto verificato: se almeno $assumedHits dei 5 estratti sono fra i $v numeri del pronostico, '
            'almeno una delle ${columns.length} colonne ne contiene $guaranteedHits o più. '
            'Controllati tutti i ${cases.length} casi. L\'integrale in colonne da $combinationSize avrebbe ${estimate.total} colonne. '
            'La garanzia è combinatoria: non rende più probabile che i numeri del pronostico escano.'
        : 'La verifica esaustiva non ha confermato la garanzia. Le colonne non vanno lette come ridotto garantito.',
  );
}

/// Ricontrolla da zero ogni sottoinsieme di [assumedHits] indici del pronostico.
bool verifyReducedGuarantee({
  required List<int> blocks,
  required int poolSize,
  required int assumedHits,
  required int guaranteedHits,
}) {
  for (final item in _subsetMasks(poolSize, assumedHits)) {
    var ok = false;
    for (final block in blocks) {
      if (popCount(item & block) >= guaranteedHits) {
        ok = true;
        break;
      }
    }
    if (!ok) return false;
  }
  return true;
}

/// Versione su numeri reali, usata dai test e dall'interfaccia.
bool verifyReducedColumns({
  required List<int> pool,
  required List<List<int>> columns,
  required int assumedHits,
  required int guaranteedHits,
}) {
  final unique = {...pool}.toList()..sort();
  if (unique.length > maxReducedPool) return false;
  final indexOf = {for (var i = 0; i < unique.length; i++) unique[i]: i};
  final blocks = <int>[];
  for (final column in columns) {
    var mask = 0;
    for (final number in column) {
      final index = indexOf[number];
      if (index == null) return false;
      mask |= 1 << index;
    }
    blocks.add(mask);
  }
  return verifyReducedGuarantee(
    blocks: blocks,
    poolSize: unique.length,
    assumedHits: assumedHits,
    guaranteedHits: guaranteedHits,
  );
}

int popCount(int x) {
  x = x - ((x >>> 1) & 0x5555555555555555);
  x = (x & 0x3333333333333333) + ((x >>> 2) & 0x3333333333333333);
  x = (x + (x >>> 4)) & 0x0F0F0F0F0F0F0F0F;
  return (x * 0x0101010101010101) >>> 56;
}

/// La colonna include [guaranteedHits] numeri del caso scelto, così ogni
/// iterazione copre almeno quel caso e la costruzione termina sempre.
int _candidateBlock(List<int> targetIndexes, int v, int k, int t, Random random) {
  final picked = [...targetIndexes]..shuffle(random);
  var mask = 0;
  for (var i = 0; i < t; i++) {
    mask |= 1 << picked[i];
  }
  var size = t;
  while (size < k) {
    final index = random.nextInt(v);
    final bit = 1 << index;
    if (mask & bit != 0) continue;
    mask |= bit;
    size++;
  }
  return mask;
}

List<int> _subsetMasks(int n, int k) {
  final out = <int>[];
  void walk(int start, int depth, int mask) {
    if (depth == k) {
      out.add(mask);
      return;
    }
    for (var i = start; i <= n - (k - depth); i++) {
      walk(i + 1, depth + 1, mask | (1 << i));
    }
  }

  walk(0, 0, 0);
  return out;
}

List<int> _indexesOf(int mask) {
  final out = <int>[];
  var index = 0;
  while (mask != 0) {
    if (mask & 1 == 1) out.add(index);
    mask >>>= 1;
    index++;
  }
  return out;
}

int _compareRows(List<int> a, List<int> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    final diff = a[i] - b[i];
    if (diff != 0) return diff;
  }
  return a.length - b.length;
}

List<int> sampleUniform(int combinationSize, Random random, {List<int>? pool}) {
  final source = pool == null ? [for (var n = 1; n <= 90; n++) n] : ([...pool]..sort());
  return _sample(source, combinationSize, random)..sort();
}

List<int> _sample(List<int> source, int combinationSize, Random random) {
  final bag = [...source];
  final size = min(combinationSize, bag.length);
  for (var i = 0; i < size; i++) {
    final j = i + random.nextInt(bag.length - i);
    final tmp = bag[i];
    bag[i] = bag[j];
    bag[j] = tmp;
  }
  return bag.sublist(0, size);
}

int hypotheticalCostCents(int combinations, int unitCostCents) {
  if (combinations < 0 || unitCostCents < 0) {
    throw ArgumentError('Costo e numero di combinazioni non possono essere negativi.');
  }
  return combinations * unitCostCents;
}
