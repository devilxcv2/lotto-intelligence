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
