// lib/features/superenalotto/domain/superenalotto_studio.dart

import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/zoppe_system.dart';
import '../data/superenalotto_repository.dart';

/// Probabilità equa che un numero compaia fra i sei estratti.
const double superenalottoNumberProbability = 6 / 90;

class SeNumberStat {
  const SeNumberStat({required this.number, required this.hits, required this.delay, required this.neverSeen});

  final int number;
  final int hits;

  /// Estrazioni trascorse dall'ultima presenza nei sei numeri.
  /// Se non è mai uscito, coincide con il numero di concorsi letti.
  final int delay;
  final bool neverSeen;
}

class SeSuggestion {
  const SeSuggestion({
    required this.name,
    required this.how,
    required this.numbers,
    this.jolly,
    this.jollyHow,
    this.superstar,
    this.superstarHow,
  });

  final String name;
  final String how;
  final List<int> numbers;
  final int? jolly;
  final String? jollyHow;
  final int? superstar;
  final String? superstarHow;
}

class SeMatch {
  const SeMatch({
    required this.hits,
    required this.jollyMatched,
    required this.superstarMatched,
    required this.category,
  });

  final int hits;
  final bool jollyMatched;
  final bool superstarMatched;

  /// `sei`, `cinque_jolly`, `cinque`, `quattro`, `tre`, `due`, `nessuna`.
  final String category;

  String get label => switch (category) {
        'sei' => 'Sei',
        'cinque_jolly' => 'Cinque + Jolly',
        'cinque' => 'Cinque',
        'quattro' => 'Quattro',
        'tre' => 'Tre',
        'due' => 'Due',
        _ => 'Nessuna categoria',
      };

  /// Categoria di premio (non un importo): due o più numeri, o cinque + Jolly.
  bool get isCategoryWin => category != 'nessuna';
}

/// Ritardi e frequenze sui soli sei numeri. Jolly e SuperStar non contano nel ritardo.
List<SeNumberStat> superenalottoStats(List<SuperenalottoDraw> chronological) {
  final hits = List<int>.filled(91, 0);
  final last = List<int>.filled(91, -1);
  for (var index = 0; index < chronological.length; index++) {
    for (final number in chronological[index].numbers) {
      if (number < 1 || number > 90) continue;
      hits[number]++;
      last[number] = index;
    }
  }
  final total = chronological.length;
  return [
    for (var number = 1; number <= 90; number++)
      SeNumberStat(
        number: number,
        hits: hits[number],
        delay: last[number] < 0 ? total : total - 1 - last[number],
        neverSeen: last[number] < 0,
      ),
  ];
}

({Map<int, int> hits, Map<int, int> delay}) _extras(List<SuperenalottoDraw> draws, int Function(SuperenalottoDraw) pick) {
  final hits = {for (var number = 1; number <= 90; number++) number: 0};
  final last = {for (var number = 1; number <= 90; number++) number: -1};
  for (var index = 0; index < draws.length; index++) {
    final number = pick(draws[index]);
    if (number < 1 || number > 90) continue;
    hits[number] = hits[number]! + 1;
    last[number] = index;
  }
  final total = draws.length;
  return (
    hits: hits,
    delay: {for (var number = 1; number <= 90; number++) number: last[number]! < 0 ? total : total - 1 - last[number]!},
  );
}

/// Jolly più uscito fra quelli che non stanno nei [exclude]. Descrive il passato.
({int? number, String how}) suggestJolly(List<SuperenalottoDraw> chronological, {required Set<int> exclude}) {
  if (chronological.length < 10) return (number: null, how: 'Servono più concorsi per un suggerimento sul Jolly.');
  final window = chronological.length <= 100 ? chronological : chronological.sublist(chronological.length - 100);
  final stats = _extras(window, (draw) => draw.jolly);
  final ranked = [for (var number = 1; number <= 90; number++) number]
    ..sort((a, b) {
      final byHits = stats.hits[b]!.compareTo(stats.hits[a]!);
      if (byHits != 0) return byHits;
      return a.compareTo(b);
    });
  for (final number in ranked) {
    if (exclude.contains(number)) continue;
    if (stats.hits[number]! <= 0) continue;
    return (
      number: number,
      how: 'Jolly più uscito nelle ultime ${window.length} combinazioni, escluso dai sei. '
          'Il Jolly ufficiale non sta mai nei sei estratti. Non è una previsione.',
    );
  }
  return (number: null, how: 'Nessun Jolly storico fuori dalla sestina in questo periodo.');
}

/// SuperStar più uscita. Può coincidere con un numero della sestina.
({int? number, String how}) suggestSuperstar(List<SuperenalottoDraw> chronological) {
  if (chronological.length < 10) return (number: null, how: 'Servono più concorsi per un suggerimento sulla SuperStar.');
  final window = chronological.length <= 100 ? chronological : chronological.sublist(chronological.length - 100);
  final stats = _extras(window, (draw) => draw.superstar);
  final ranked = [for (var number = 1; number <= 90; number++) number]
    ..sort((a, b) {
      final byHits = stats.hits[b]!.compareTo(stats.hits[a]!);
      if (byHits != 0) return byHits;
      return a.compareTo(b);
    });
  final number = ranked.first;
  if (stats.hits[number]! <= 0) {
    return (number: null, how: 'Nessuna SuperStar storica in questo periodo.');
  }
  return (
    number: number,
    how: 'SuperStar più uscita nelle ultime ${window.length} combinazioni. '
        'Può coincidere con uno dei sei. Non è una previsione.',
  );
}

/// Ipotesi descrittive: ritardo, frequenza, Zoppe da sei con Jolly e SuperStar.
List<SeSuggestion> suggestSuperenalotto(List<SuperenalottoDraw> chronological, {int seed = 42}) {
  if (chronological.length < 10) return const [];
  final stats = superenalottoStats(chronological);
  final delayed = [...stats]..sort((a, b) {
      final byDelay = b.delay.compareTo(a.delay);
      if (byDelay != 0) return byDelay;
      return a.number.compareTo(b.number);
    });
  final asDraws = [
    for (final draw in chronological)
      ArchivedDraw(date: draw.date, numbers: draw.numbers),
  ];
  final windowDraws = asDraws.length <= 100 ? asDraws : asDraws.sublist(asDraws.length - 100);
  final window = chronological.length <= 100 ? chronological : chronological.sublist(chronological.length - 100);
  final recent = superenalottoStats(window);
  final frequent = [...recent]..sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      if (byHits != 0) return byHits;
      return a.number.compareTo(b.number);
    });
  final out = <SeSuggestion>[
    SeSuggestion(
      name: 'Sei ritardatari',
      how: 'I sei numeri con più concorsi di assenza nei sei estratti. Il ritardo non li rende più probabili.',
      numbers: [for (final stat in delayed.take(6)) stat.number]..sort(),
    ),
    SeSuggestion(
      name: 'Sei più usciti',
      how: 'I sei numeri con più presenze nelle ultime ${window.length} combinazioni.',
      numbers: [for (final stat in frequent.take(6)) stat.number]..sort(),
    ),
  ];

  final counted = frequencyAndDelay(windowDraws);
  final zoppe = buildZoppeSystem(
    hits: counted.hits,
    delays: counted.delay,
    columnSize: 6,
    seed: seed,
    windowDraws: windowDraws.length,
  );
  if (zoppe.columns.isNotEmpty) {
    final six = zoppe.leadColumn;
    final jolly = suggestJolly(chronological, exclude: six.toSet());
    final star = suggestSuperstar(chronological);
    out.add(SeSuggestion(
      name: 'Sistemone Zoppe',
      how: zoppeLegendSix,
      numbers: six,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }
  return out;
}

/// Algoritmi personalizzati: leggono l'archivio (giorno, somma, pari/dispari, mix,
/// decadi, coppie) e propongono sestina. Restano descrizioni del passato, non previsioni.
List<SeSuggestion> personalizedSuperenalotto(
  List<SuperenalottoDraw> chronological, {
  DateTime? forDrawDay,
  int seed = 42,
}) {
  if (chronological.length < 20) return const [];
  final window = chronological.length <= 120 ? chronological : chronological.sublist(chronological.length - 120);
  final statsAll = superenalottoStats(chronological);
  final delayed = [...statsAll]..sort((a, b) {
      final byDelay = b.delay.compareTo(a.delay);
      return byDelay != 0 ? byDelay : a.number.compareTo(b.number);
    });
  final recentStats = superenalottoStats(window);
  final frequent = [...recentStats]..sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      return byHits != 0 ? byHits : a.number.compareTo(b.number);
    });
  final star = suggestSuperstar(chronological);
  final out = <SeSuggestion>[];

  // 1) Mix caldo-freddo: 3 ritardatari + 3 frequenti.
  final mix = <int>{};
  for (final s in delayed) {
    if (mix.length >= 3) break;
    mix.add(s.number);
  }
  for (final s in frequent) {
    if (mix.length >= 6) break;
    mix.add(s.number);
  }
  if (mix.length == 6) {
    final six = mix.toList()..sort();
    final jolly = suggestJolly(chronological, exclude: six.toSet());
    out.add(SeSuggestion(
      name: 'Mix caldo-freddo',
      how: 'Tre numeri tra i più assenti e tre tra i più usciti nelle ultime ${window.length} combinazioni. '
          'Non è una previsione: mescola due letture del passato.',
      numbers: six,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }

  // 2) Pari/dispari vicino alla media storica dei sei.
  final evenCounts = [for (final d in window) d.numbers.where((n) => n.isEven).length];
  evenCounts.sort();
  final targetEven = evenCounts[evenCounts.length ~/ 2];
  final byDelay = delayed.map((s) => s.number).toList();
  final evenOdd = _pickEvenOdd(byDelay, targetEven: targetEven, size: 6);
  if (evenOdd.length == 6) {
    final jolly = suggestJolly(chronological, exclude: evenOdd.toSet());
    out.add(SeSuggestion(
      name: 'Equilibrio pari/dispari',
      how: 'Nelle ultime ${window.length} sestina tipiche ci sono circa $targetEven pari. '
          'Questa colonna ripete quel equilibrio sui ritardatari. Non alza la probabilità.',
      numbers: evenOdd,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }

  // 3) Somma vicina alla mediana storica.
  final sums = [for (final d in window) d.numbers.fold<int>(0, (a, b) => a + b)]..sort();
  final medianSum = sums[sums.length ~/ 2];
  final sumSix = _pickNearSum(byDelay, targetSum: medianSum, size: 6);
  if (sumSix.length == 6) {
    final jolly = suggestJolly(chronological, exclude: sumSix.toSet());
    out.add(SeSuggestion(
      name: 'Somma tipica ($medianSum)',
      how: 'La mediana della somma dei sei nelle ultime ${window.length} combinazioni è $medianSum. '
          'Si scelgono ritardatari la cui somma si avvicina. Descrizione, non previsione.',
      numbers: sumSix,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }

  // 4) Giorno della settimana del prossimo concorso.
  final day = forDrawDay ?? DateTime.now();
  final sameWeekday = [
    for (final d in chronological)
      if (d.date.toLocal().weekday == day.weekday) d,
  ];
  if (sameWeekday.length >= 15) {
    final dayStats = superenalottoStats(sameWeekday);
    final dayFreq = [...dayStats]..sort((a, b) {
        final byHits = b.hits.compareTo(a.hits);
        return byHits != 0 ? byHits : a.number.compareTo(b.number);
      });
    final six = [for (final s in dayFreq.take(6)) s.number]..sort();
    final jolly = suggestJolly(chronological, exclude: six.toSet());
    const weekdayNames = {1: 'lunedì', 2: 'martedì', 3: 'mercoledì', 4: 'giovedì', 5: 'venerdì', 6: 'sabato', 7: 'domenica'};
    out.add(SeSuggestion(
      name: 'Giorno · ${weekdayNames[day.weekday] ?? '?'}',
      how: 'I sei più usciti nei ${sameWeekday.length} concorsi dello stesso giorno della settimana. '
          'Il giorno non cambia la probabilità equa 6/90.',
      numbers: six,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }

  // 5) Una gamba per fascia di decade (1–9 … 80–90).
  final decadeSix = _pickDecades(frequent.map((s) => s.number).followedBy(delayed.map((s) => s.number)));
  if (decadeSix.length == 6) {
    final sorted = decadeSix.toList()..sort();
    final jolly = suggestJolly(chronological, exclude: sorted.toSet());
    out.add(SeSuggestion(
      name: 'Copertura decadi',
      how: 'Un numero per fascia (1–15, 16–30, …) preso dai frequenti/ritardatari. '
          'Bilancia le zone, non prevede l\'estratto.',
      numbers: sorted,
      jolly: jolly.number,
      jollyHow: jolly.how,
      superstar: star.number,
      superstarHow: star.how,
    ));
  }

  // 6) Coppia più ricorrente + riempimento.
  final pair = _topPair(window);
  if (pair != null) {
    final pool = [
      pair.$1,
      pair.$2,
      ...frequent.map((s) => s.number).where((n) => n != pair.$1 && n != pair.$2),
    ];
    final six = <int>{};
    for (final n in pool) {
      if (six.length >= 6) break;
      six.add(n);
    }
    if (six.length == 6) {
      final sorted = six.toList()..sort();
      final jolly = suggestJolly(chronological, exclude: sorted.toSet());
      out.add(SeSuggestion(
        name: 'Coppia ricorrente ${pair.$1}-${pair.$2}',
        how: 'La coppia uscita insieme più spesso nelle ultime ${window.length} combinazioni, '
            'completata con i più frequenti. Co-occorrenza passata ≠ probabilità futura.',
        numbers: sorted,
        jolly: jolly.number,
        jollyHow: jolly.how,
        superstar: star.number,
        superstarHow: star.how,
      ));
    }
  }

  // Seed solo per variare leggermente l'ordine se servisse in futuro.
  assert(seed >= 0);
  return out;
}

List<int> _pickEvenOdd(List<int> ranked, {required int targetEven, required int size}) {
  final even = <int>[];
  final odd = <int>[];
  for (final n in ranked) {
    if (n.isEven) {
      even.add(n);
    } else {
      odd.add(n);
    }
  }
  final needEven = targetEven.clamp(0, size);
  final needOdd = size - needEven;
  final out = <int>[
    ...even.take(needEven),
    ...odd.take(needOdd),
  ];
  for (final n in ranked) {
    if (out.length >= size) break;
    if (!out.contains(n)) out.add(n);
  }
  return out.length == size ? (out..sort()) : const [];
}

List<int> _pickNearSum(List<int> ranked, {required int targetSum, required int size}) {
  final chosen = <int>[];
  var sum = 0;
  for (final n in ranked) {
    if (chosen.length >= size) break;
    final remaining = size - chosen.length - 1;
    final minRest = remaining * 1;
    final maxRest = remaining * 90;
    final nextSum = sum + n;
    if (nextSum + minRest > targetSum + 40 && chosen.isNotEmpty) continue;
    if (nextSum + maxRest < targetSum - 40 && remaining > 0) {
      // troppo basso: prendi comunque i primi se siamo all'inizio
    }
    chosen.add(n);
    sum += n;
  }
  for (final n in ranked) {
    if (chosen.length >= size) break;
    if (!chosen.contains(n)) {
      chosen.add(n);
      sum += n;
    }
  }
  if (chosen.length != size) return const [];
  // Micro-aggiusto scambiando l'ultimo se la somma è lontana.
  var best = List<int>.from(chosen)..sort();
  var bestDiff = (best.fold<int>(0, (a, b) => a + b) - targetSum).abs();
  for (final cand in ranked.take(40)) {
    if (best.contains(cand)) continue;
    for (var i = 0; i < best.length; i++) {
      final trial = [...best]..[i] = cand;
      if (trial.toSet().length != size) continue;
      trial.sort();
      final diff = (trial.fold<int>(0, (a, b) => a + b) - targetSum).abs();
      if (diff < bestDiff) {
        best = trial;
        bestDiff = diff;
      }
    }
  }
  return best;
}

Set<int> _pickDecades(Iterable<int> ranked) {
  const bands = [
    (1, 15),
    (16, 30),
    (31, 45),
    (46, 60),
    (61, 75),
    (76, 90),
  ];
  final out = <int>{};
  final used = <int>{};
  for (final band in bands) {
    for (final n in ranked) {
      if (used.contains(n)) continue;
      if (n >= band.$1 && n <= band.$2) {
        out.add(n);
        used.add(n);
        break;
      }
    }
  }
  return out;
}

(int, int)? _topPair(List<SuperenalottoDraw> window) {
  final counts = <String, int>{};
  final parse = <String, (int, int)>{};
  for (final draw in window) {
    final nums = [...draw.numbers]..sort();
    for (var i = 0; i < nums.length; i++) {
      for (var j = i + 1; j < nums.length; j++) {
        final key = '${nums[i]}-${nums[j]}';
        counts[key] = (counts[key] ?? 0) + 1;
        parse[key] = (nums[i], nums[j]);
      }
    }
  }
  if (counts.isEmpty) return null;
  final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  if (best.value < 2) return null;
  return parse[best.key];
}

/// Riepilogo delle strategie Auto già valutate (per confrontare i trend).
List<String> seAutoTrendLines(Iterable<({String origin, SeMatch? match})> tickets) {
  final byMethod = <String, ({int total, int wins, int hits})>{};
  for (final ticket in tickets) {
    if (!ticket.origin.startsWith('Auto ·')) continue;
    final key = ticket.origin;
    final cur = byMethod[key] ?? (total: 0, wins: 0, hits: 0);
    final match = ticket.match;
    byMethod[key] = (
      total: cur.total + 1,
      wins: cur.wins + (match?.isCategoryWin == true ? 1 : 0),
      hits: cur.hits + (match?.hits ?? 0),
    );
  }
  if (byMethod.isEmpty) {
    return const ['Ancora nessuna schedina Auto valutata: attiva l\'auto SE e attendi un concorso.'];
  }
  final lines = <String>[];
  final ranked = byMethod.entries.toList()
    ..sort((a, b) {
      final byWins = b.value.wins.compareTo(a.value.wins);
      if (byWins != 0) return byWins;
      return b.value.hits.compareTo(a.value.hits);
    });
  for (final entry in ranked) {
    final v = entry.value;
    final avg = v.total == 0 ? 0.0 : v.hits / v.total;
    lines.add(
      '${entry.key}: ${v.wins} categorie su ${v.total} · media ${avg.toStringAsFixed(1)} numeri nei sei. '
      'Confronto descrittivo, non ranking predittivo.',
    );
  }
  return lines;
}

/// Categoria della schedina rispetto a un concorso. Nessun importo.
SeMatch matchSuperenalotto({
  required List<int> played,
  int? superstar,
  required List<int> drawn,
  required int jolly,
  required int drawnSuperstar,
}) {
  final drawnSet = drawn.toSet();
  final hits = played.where(drawnSet.contains).length;
  final jollyMatched = hits == 5 && played.contains(jolly);
  final superstarMatched = superstar != null && superstar == drawnSuperstar;
  final category = switch (hits) {
    6 => 'sei',
    5 when jollyMatched => 'cinque_jolly',
    5 => 'cinque',
    4 => 'quattro',
    3 => 'tre',
    2 => 'due',
    _ => 'nessuna',
  };
  return SeMatch(hits: hits, jollyMatched: jollyMatched, superstarMatched: superstarMatched, category: category);
}

String? seTicketProblem(List<int> numbers, {int? superstar}) {
  if (numbers.length != 6) return 'La schedina del SuperEnalotto ha 6 numeri.';
  if (numbers.toSet().length != 6) return 'I sei numeri devono essere distinti.';
  for (final number in numbers) {
    if (number < 1 || number > 90) return 'I numeri stanno fra 1 e 90.';
  }
  if (superstar != null && (superstar < 1 || superstar > 90)) return 'La SuperStar sta fra 1 e 90.';
  return null;
}
