// lib/features/superenalotto/domain/superenalotto_studio.dart

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
  const SeSuggestion({required this.name, required this.how, required this.numbers});

  final String name;
  final String how;
  final List<int> numbers;
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

/// Tre ipotesi descrittive da sei numeri. Non sono una previsione.
List<SeSuggestion> suggestSuperenalotto(List<SuperenalottoDraw> chronological) {
  if (chronological.length < 10) return const [];
  final stats = superenalottoStats(chronological);
  final delayed = [...stats]..sort((a, b) {
      final byDelay = b.delay.compareTo(a.delay);
      if (byDelay != 0) return byDelay;
      return a.number.compareTo(b.number);
    });
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
  final zoppe = _zoppeSix(recent);
  if (zoppe != null) {
    out.add(SeSuggestion(
      name: 'Zoppe da sei',
      how: 'Due numeri fra i più usciti e quattro nella fascia di frequenza 30–45, la stessa idea del sistemone Zoppe del Lotto.',
      numbers: zoppe,
    ));
  }
  return out;
}

List<int>? _zoppeSix(List<SeNumberStat> recent) {
  final order = [...recent]..sort((a, b) {
      final byHits = a.hits.compareTo(b.hits);
      if (byHits != 0) return byHits;
      return a.number.compareTo(b.number);
    });
  final percentile = <int, double>{};
  var index = 0;
  while (index < order.length) {
    var end = index + 1;
    while (end < order.length && order[end].hits == order[index].hits) {
      end++;
    }
    final value = ((index + (end - 1)) / 2) / 89 * 100;
    for (var cursor = index; cursor < end; cursor++) {
      percentile[order[cursor].number] = value;
    }
    index = end;
  }
  final hot = [...recent]..sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      if (byHits != 0) return byHits;
      return a.number.compareTo(b.number);
    });
  final head = hot.take(2).map((stat) => stat.number).toSet();
  final band = [
    for (final stat in recent)
      if (!head.contains(stat.number) && (percentile[stat.number] ?? 0) >= 30 && (percentile[stat.number] ?? 0) <= 45) stat.number,
  ]..sort();
  if (band.length < 4) return null;
  return [...head, ...band.take(4)]..sort();
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
