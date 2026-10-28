// lib/features/superenalotto/domain/se_bacheca.dart
//
// Tipologie della Bacheca sistemi SuperEnalotto
// (https://www.superenalotto.it/come-si-gioca/bacheca-dei-sistemi),
// in versione di studio: colonne + costo simulato, nessun acquisto reale.

import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';
import '../../systems/domain/combinations.dart';
import '../../systems/domain/sisal_guarantee.dart';

enum SeBachecaKind {
  integrale,
  ridotto,
  basiVarianti,
  cruciverba,
  minicruciverba,
  multistella,
}

extension SeBachecaKindLabel on SeBachecaKind {
  String get label => switch (this) {
        SeBachecaKind.integrale => 'Integrale',
        SeBachecaKind.ridotto => 'Ridotto G5/G4/G3',
        SeBachecaKind.basiVarianti => 'Basi e Varianti',
        SeBachecaKind.cruciverba => 'Cruciverba',
        SeBachecaKind.minicruciverba => 'Minicruciverba',
        SeBachecaKind.multistella => 'Multistella',
      };

  String get blurb => switch (this) {
        SeBachecaKind.integrale => 'Tutte le sestine da 7–19 numeri (C(n,6)).',
        SeBachecaKind.ridotto => 'Meno colonne dell’integrale, garanzia G5/G4/G3; ruotanti opzionali.',
        SeBachecaKind.basiVarianti => 'Basi fisse + varianti a rotazione (B1…B5).',
        SeBachecaKind.cruciverba => 'Griglia N×N: righe, colonne e diagonali → sestine.',
        SeBachecaKind.minicruciverba => '3×3 con 9 numeri: 8 sestine (complemento di ogni linea).',
        SeBachecaKind.multistella => 'Più integrali casuali da 7/8/9, ciascuno con SuperStar.',
      };
}

class SeBachecaResult {
  const SeBachecaResult({
    required this.kind,
    required this.columns,
    required this.coverageClaim,
    required this.costCents,
    required this.guaranteeVerified,
    this.grid,
    this.superstars = const [],
    this.catalogColumns,
  });

  final SeBachecaKind kind;
  final List<List<int>> columns;
  final String coverageClaim;
  final int costCents;
  final bool guaranteeVerified;
  /// Griglia cruciverba / minicruciverba (righe di celle).
  final List<List<int>>? grid;
  /// Una SuperStar per blocco Multistella (allineata agli integrali, non alle sestine).
  final List<int> superstars;
  /// Colonne attese dalla tabella Sisal (se nota), per confronto.
  final int? catalogColumns;

  int get columnCount => columns.length;
}

/// Tabella ufficiale riduzioni Sisal (0 ruotanti): numeri → (G, combinazioni).
const Map<int, ({int g, int columns})> seOfficialReducedCatalog = {
  10: (g: 5, columns: 14),
  11: (g: 5, columns: 22),
  12: (g: 5, columns: 38),
  13: (g: 4, columns: 10),
  14: (g: 4, columns: 14),
  15: (g: 4, columns: 19),
  16: (g: 4, columns: 25),
  17: (g: 4, columns: 34),
  20: (g: 3, columns: 10),
  21: (g: 3, columns: 10),
  22: (g: 3, columns: 15),
  23: (g: 3, columns: 17),
  24: (g: 3, columns: 20),
  25: (g: 3, columns: 22),
  26: (g: 3, columns: 25),
  27: (g: 3, columns: 27),
  28: (g: 3, columns: 31),
  29: (g: 3, columns: 35),
  30: (g: 3, columns: 39),
};

/// Costo integrale SE (€1 a sestina) da 6 a 19.
int seIntegralCombinations(int numbers) {
  if (numbers < 6 || numbers > 19) return 0;
  return binomial(numbers, 6).toInt();
}

int seIntegralCostCents(int numbers, {bool withSuperStar = false}) {
  final n = seIntegralCombinations(numbers);
  return withSuperStar ? (n * 150) : (n * seUnitCostCents);
}

String? seIntegraleProblem(List<int> pool) {
  final n = {...pool}.length;
  if (n < 7) return 'L’integrale SE parte da 7 numeri (6 = una sola schedina).';
  if (n > 19) return 'Sisal ferma l’integrale a 19 numeri (27.132 combinazioni).';
  return null;
}

SeBachecaResult developIntegrale(List<int> pool) {
  final unique = {...pool}.toList()..sort();
  final problem = seIntegraleProblem(unique);
  if (problem != null) {
    return SeBachecaResult(
      kind: SeBachecaKind.integrale,
      columns: const [],
      coverageClaim: problem,
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final result = generateIntegral(pool: unique, combinationSize: 6);
  return SeBachecaResult(
    kind: SeBachecaKind.integrale,
    columns: result.combinations,
    coverageClaim: result.coverageClaim,
    costCents: result.combinations.length * seUnitCostCents,
    guaranteeVerified: result.complete,
    catalogColumns: seIntegralCombinations(unique.length),
  );
}

/// Ridotto G + eventuali ruotanti (pannello B): ogni sestina + ruotanti → integrale C(6+r,6).
SeBachecaResult developRidotto({
  required List<int> panelA,
  required SisalGuarantee guarantee,
  List<int> ruotanti = const [],
  int seed = 42,
}) {
  final a = {...panelA}.toList()..sort();
  final r = {...ruotanti}.where((n) => !a.contains(n)).toList()..sort();
  if (r.length > 5) {
    return const SeBachecaResult(
      kind: SeBachecaKind.ridotto,
      columns: [],
      coverageClaim: 'I ruotanti Sisal sono al massimo 5 (pannello B).',
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final range = sisalSePoolRange(guarantee);
  if (a.length < range.min || a.length > range.max) {
    return SeBachecaResult(
      kind: SeBachecaKind.ridotto,
      columns: const [],
      coverageClaim: 'Per ${guarantee.label} il pannello A prevede ${range.min}–${range.max} numeri.',
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final params = sisalReducedParams(
    guarantee: guarantee,
    drawnSize: superenalottoDrawnSize,
    combinationSize: 6,
  );
  final reduced = generateReduced(
    pool: a,
    combinationSize: 6,
    assumedHits: params.assumedHits,
    guaranteedHits: params.guaranteedHits,
    seed: seed,
  );
  if (reduced.combinations.isEmpty) {
    return SeBachecaResult(
      kind: SeBachecaKind.ridotto,
      columns: const [],
      coverageClaim: reduced.coverageClaim,
      costCents: 0,
      guaranteeVerified: false,
      catalogColumns: seOfficialReducedCatalog[a.length]?.columns,
    );
  }

  List<List<int>> columns;
  String claim;
  if (r.isEmpty) {
    columns = reduced.combinations;
    claim = reduced.coverageClaim;
  } else {
    columns = [];
    final seen = <String>{};
    for (final sestina in reduced.combinations) {
      final pool = [...sestina, ...r]..sort();
      final expanded = generateIntegral(pool: pool, combinationSize: 6);
      for (final row in expanded.combinations) {
        final key = row.join(',');
        if (seen.add(key)) columns.add(row);
      }
    }
    columns.sort(_compareRows);
    claim = '${reduced.coverageClaim} '
        'Con ${r.length} ruotanti ogni sestina diventa un integrale da ${6 + r.length} numeri '
        '(C(${6 + r.length},6)=${binomial(6 + r.length, 6)} per colonna ridotta).';
  }

  return SeBachecaResult(
    kind: SeBachecaKind.ridotto,
    columns: columns,
    coverageClaim: claim,
    costCents: columns.length * seUnitCostCents,
    guaranteeVerified: reduced.guaranteeVerified && r.isEmpty
        ? true
        : reduced.guaranteeVerified, // con ruotanti la G resta sulla riduzione di A
    catalogColumns: seOfficialReducedCatalog[a.length]?.columns,
  );
}

/// B1…B5: C(basi,k)×C(varianti,6−k).
String? basiVariantiProblem({
  required List<int> basi,
  required List<int> varianti,
  required int k,
}) {
  if (k < 1 || k > 5) return 'Scegli B1…B5.';
  final b = {...basi};
  final v = {...varianti};
  if (b.intersection(v).isNotEmpty) return 'Basi e Varianti non possono condividere numeri.';
  if (b.length + v.length > 80) return 'Al massimo 80 numeri tra Basi e Varianti (Sisal).';
  if (b.length < k) return 'Servono almeno $k basi per B$k.';
  final needV = 6 - k;
  if (v.length < needV) return 'Servono almeno $needV varianti per B$k.';
  final total = binomial(b.length, k) * binomial(v.length, needV);
  if (total > BigInt.from(maxReturnedCombinations)) {
    return 'Troppe colonne ($total). Riduci basi o varianti.';
  }
  return null;
}

SeBachecaResult developBasiVarianti({
  required List<int> basi,
  required List<int> varianti,
  required int k,
}) {
  final b = {...basi}.toList()..sort();
  final v = {...varianti}.toList()..sort();
  final problem = basiVariantiProblem(basi: b, varianti: v, k: k);
  if (problem != null) {
    return SeBachecaResult(
      kind: SeBachecaKind.basiVarianti,
      columns: const [],
      coverageClaim: problem,
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final needV = 6 - k;
  final columns = <List<int>>[];
  for (final basePick in _combinationsOf(b, k)) {
    for (final varPick in _combinationsOf(v, needV)) {
      final row = [...basePick, ...varPick]..sort();
      columns.add(row);
    }
  }
  columns.sort(_compareRows);
  return SeBachecaResult(
    kind: SeBachecaKind.basiVarianti,
    columns: columns,
    coverageClaim: 'B$k: ogni gruppo di $k basi con ogni gruppo di $needV varianti. '
        '${columns.length} sestine. Non è una garanzia G5/G4/G3: le basi compaiono in tutte le colonne del loro gruppo.',
    costCents: columns.length * seUnitCostCents,
    guaranteeVerified: false,
  );
}

/// Cruciverba N×N: N² numeri, linee = N righe + N colonne + 2 diagonali.
/// Ogni linea di N numeri → integrale C(N,6) se N>6, altrimenti la sestina stessa.
const List<int> seCruciverbaSizes = [6, 7, 8, 9]; // 10/11 oltre i 90 numeri

int seCruciverbaLineCount(int n) => n + n + 2;

int seCruciverbaCatalogCombinations(int n) {
  final lines = seCruciverbaLineCount(n);
  final per = n <= 6 ? 1 : binomial(n, 6).toInt();
  return lines * per;
}

SeBachecaResult developCruciverba(List<int> numbers, int n) {
  if (!seCruciverbaSizes.contains(n)) {
    return SeBachecaResult(
      kind: SeBachecaKind.cruciverba,
      columns: const [],
      coverageClaim: n >= 10
          ? 'Cruciverba ${n}×$n (Sisal esclusiva ricevitoria): servirebbero ${n * n} numeri, oltre i 90.'
          : 'Dimensioni supportate: 6×6 … 9×9.',
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final need = n * n;
  final unique = {...numbers}.toList()..sort();
  if (unique.length != need) {
    return SeBachecaResult(
      kind: SeBachecaKind.cruciverba,
      columns: const [],
      coverageClaim: 'Per un Cruciverba ${n}×$n servono esattamente $need numeri distinti (ne hai ${unique.length}).',
      costCents: 0,
      guaranteeVerified: false,
      catalogColumns: seCruciverbaCatalogCombinations(n),
    );
  }
  final grid = [
    for (var r = 0; r < n; r++) [for (var c = 0; c < n; c++) unique[r * n + c]],
  ];
  final lines = <List<int>>[];
  for (var r = 0; r < n; r++) {
    lines.add([for (var c = 0; c < n; c++) grid[r][c]]);
  }
  for (var c = 0; c < n; c++) {
    lines.add([for (var r = 0; r < n; r++) grid[r][c]]);
  }
  lines.add([for (var i = 0; i < n; i++) grid[i][i]]);
  lines.add([for (var i = 0; i < n; i++) grid[i][n - 1 - i]]);

  final columns = <List<int>>[];
  final seen = <String>{};
  for (final line in lines) {
    final sorted = [...line]..sort();
    if (n == 6) {
      final key = sorted.join(',');
      if (seen.add(key)) columns.add(sorted);
    } else {
      final part = generateIntegral(pool: sorted, combinationSize: 6);
      for (final row in part.combinations) {
        final key = row.join(',');
        if (seen.add(key)) columns.add(row);
      }
    }
  }
  columns.sort(_compareRows);
  return SeBachecaResult(
    kind: SeBachecaKind.cruciverba,
    columns: columns,
    coverageClaim: 'Cruciverba ${n}×$n: ${seCruciverbaLineCount(n)} linee (righe+colonne+2 diagonali) → '
        '${columns.length} sestine (catalogo Sisal: ${seCruciverbaCatalogCombinations(n)}).',
    costCents: columns.length * seUnitCostCents,
    guaranteeVerified: true,
    grid: grid,
    catalogColumns: seCruciverbaCatalogCombinations(n),
  );
}

/// Minicruciverba: 3×3, 9 numeri; ogni linea di 3 → sestina = gli altri 6.
SeBachecaResult developMinicruciverba(List<int> numbers) {
  final unique = {...numbers}.toList()..sort();
  if (unique.length != 9) {
    return SeBachecaResult(
      kind: SeBachecaKind.minicruciverba,
      columns: const [],
      coverageClaim: 'Il Minicruciverba usa esattamente 9 numeri (ne hai ${unique.length}).',
      costCents: 0,
      guaranteeVerified: false,
      catalogColumns: 8,
    );
  }
  final grid = [
    [unique[0], unique[1], unique[2]],
    [unique[3], unique[4], unique[5]],
    [unique[6], unique[7], unique[8]],
  ];
  final lines = <List<int>>[
    grid[0],
    grid[1],
    grid[2],
    [grid[0][0], grid[1][0], grid[2][0]],
    [grid[0][1], grid[1][1], grid[2][1]],
    [grid[0][2], grid[1][2], grid[2][2]],
    [grid[0][0], grid[1][1], grid[2][2]],
    [grid[0][2], grid[1][1], grid[2][0]],
  ];
  final all = unique.toSet();
  final columns = [
    for (final line in lines) ([...all.difference(line.toSet())]..sort()),
  ];
  return SeBachecaResult(
    kind: SeBachecaKind.minicruciverba,
    columns: columns,
    coverageClaim: 'Minicruciverba 3×3: 8 sestine = complemento (6 numeri) di ogni riga, colonna e diagonale.',
    costCents: 8 * seUnitCostCents,
    guaranteeVerified: true,
    grid: grid,
    catalogColumns: 8,
  );
}

/// Multistella: [packs] integrali casuali da [size] numeri (7/8/9), ciascuno con SuperStar.
SeBachecaResult developMultistella({
  required int size,
  required int packs,
  int seed = 42,
}) {
  if (size < 7 || size > 9) {
    return const SeBachecaResult(
      kind: SeBachecaKind.multistella,
      columns: [],
      coverageClaim: 'Multistella Sisal: settine (7), ottine (8) o novine (9).',
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  if (packs < 1 || packs > 20) {
    return const SeBachecaResult(
      kind: SeBachecaKind.multistella,
      columns: [],
      coverageClaim: 'Scegli da 1 a 20 pacchetti Multistella.',
      costCents: 0,
      guaranteeVerified: false,
    );
  }
  final random = Random(seed);
  final columns = <List<int>>[];
  final stars = <int>[];
  final seenPack = <String>{};
  var guard = 0;
  while (stars.length < packs && guard < packs * 50) {
    guard++;
    final bag = [for (var n = 1; n <= 90; n++) n]..shuffle(random);
    final pack = bag.take(size).toList()..sort();
    final key = pack.join(',');
    if (!seenPack.add(key)) continue;
    var star = random.nextInt(90) + 1;
    final developed = generateIntegral(pool: pack, combinationSize: 6);
    columns.addAll(developed.combinations);
    stars.add(star);
  }
  final per = seIntegralCombinations(size);
  return SeBachecaResult(
    kind: SeBachecaKind.multistella,
    columns: columns,
    coverageClaim: 'Multistella $size: ${stars.length} integrali da $size numeri '
        '($per sestine ciascuno) con SuperStar dedicata. Costo studio come Sisal senza carature.',
    costCents: columns.length * seUnitCostCents,
    guaranteeVerified: false,
    superstars: stars,
    catalogColumns: packs * per,
  );
}

/// Tagli Multistella tipici Sisal (solo informativi).
const List<({String name, int size, int packs, int costEuro})> seMultistellaCuts = [
  (name: 'Multistella 7 · 105 €', size: 7, packs: 10, costEuro: 105),
  (name: 'Multistella 8 · 210 €', size: 8, packs: 5, costEuro: 210),
  (name: 'Multistella 8 · 420 €', size: 8, packs: 10, costEuro: 420),
  (name: 'Multistella 8 · 630 €', size: 8, packs: 15, costEuro: 630),
  (name: 'Multistella 9 · 630 €', size: 9, packs: 5, costEuro: 630),
  (name: 'Multistella 9 · 1.260 €', size: 9, packs: 10, costEuro: 1260),
];

int _compareRows(List<int> a, List<int> b) {
  final n = min(a.length, b.length);
  for (var i = 0; i < n; i++) {
    final c = a[i].compareTo(b[i]);
    if (c != 0) return c;
  }
  return a.length.compareTo(b.length);
}

Iterable<List<int>> _combinationsOf(List<int> items, int k) sync* {
  if (k == 0) {
    yield const [];
    return;
  }
  if (k > items.length) return;
  final idx = List<int>.generate(k, (i) => i);
  while (true) {
    yield [for (final i in idx) items[i]];
    var t = k - 1;
    while (t >= 0 && idx[t] == items.length - k + t) {
      t--;
    }
    if (t < 0) return;
    idx[t]++;
    for (var i = t + 1; i < k; i++) {
      idx[i] = idx[i - 1] + 1;
    }
  }
}
