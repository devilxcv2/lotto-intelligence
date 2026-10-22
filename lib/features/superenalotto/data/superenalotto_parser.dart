// lib/features/superenalotto/data/superenalotto_parser.dart

import '../../../core/lotto/wheel_catalog.dart';

/// Pagine lette il 22 ottobre 2026 su https://www.superenalotto.it/archivio-estrazioni
/// Il sito ufficiale non offre uno ZIP dell'archivio: pubblica la tabella
/// degli ultimi concorsi e una pagina per mese.
class SuperenalottoArchiveLocations {
  const SuperenalottoArchiveLocations._();

  static const pageUrl = 'https://www.superenalotto.it/archivio-estrazioni';
  static const userAgent = 'LottoIntelligenceAI/0.4 (archivio pubblico superenalotto.it)';

  static const months = <String>[
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];

  static String monthUrl(int year, int month) {
    return '$pageUrl/$year/${months[month - 1]}';
  }
}

class ParsedSuperenalottoDraw {
  const ParsedSuperenalottoDraw({
    required this.date,
    required this.contestNumber,
    required this.numbers,
    required this.jolly,
    required this.superstar,
    this.error,
  });

  final DateTime? date;
  final int? contestNumber;
  final List<int>? numbers;
  final int? jolly;
  final int? superstar;
  final String? error;

  bool get isValid => error == null && date != null && contestNumber != null && numbers != null && jolly != null && superstar != null;
}

const _italianMonths = <String, int>{
  'gennaio': 1,
  'febbraio': 2,
  'marzo': 3,
  'aprile': 4,
  'maggio': 5,
  'giugno': 6,
  'luglio': 7,
  'agosto': 8,
  'settembre': 9,
  'ottobre': 10,
  'novembre': 11,
  'dicembre': 12,
};

/// Estrae le righe della tabella ufficiale. Le righe malformate tornano
/// con [ParsedSuperenalottoDraw.error] e non vengono scritte.
List<ParsedSuperenalottoDraw> parseSuperenalottoArchiveHtml(String html) {
  final rows = RegExp(
    r'<tr class="superenalotto-extraction-archive__details__table__row[\s\S]*?</tr>',
    caseSensitive: false,
  ).allMatches(html);
  return [for (final row in rows) _parseRow(row.group(0)!)];
}

ParsedSuperenalottoDraw _parseRow(String row) {
  final contest = RegExp(r'N[ºo°]\s*(\d+)', caseSensitive: false).firstMatch(row);
  final date = RegExp(r'del\s*(?:<strong>)?\s*(\d{1,2})\s+([A-Za-zÀ-ú]+)\s+(\d{4})', caseSensitive: false).firstMatch(row);
  final numbers = [
    for (final match in RegExp(r'combination__text">\s*(\d{1,2})\s*<').allMatches(row)) int.parse(match.group(1)!),
  ];
  final jolly = RegExp(r'jolly__text">\s*(\d{1,2})\s*<', caseSensitive: false).firstMatch(row);
  final star = RegExp(r'superstar__text">\s*(\d{1,2})\s*<', caseSensitive: false).firstMatch(row);
  if (contest == null || date == null || jolly == null || star == null) {
    return const ParsedSuperenalottoDraw(date: null, contestNumber: null, numbers: null, jolly: null, superstar: null, error: 'Riga senza concorso, data, Jolly o SuperStar.');
  }
  final month = _italianMonths[date.group(2)!.toLowerCase()];
  final day = int.parse(date.group(1)!);
  final year = int.parse(date.group(3)!);
  if (month == null) {
    return ParsedSuperenalottoDraw(
      date: null,
      contestNumber: int.parse(contest.group(1)!),
      numbers: null,
      jolly: null,
      superstar: null,
      error: 'Mese non riconosciuto: ${date.group(2)}.',
    );
  }
  final parsedDate = DateTime.utc(year, month, day);
  if (parsedDate.month != month || parsedDate.day != day) {
    return ParsedSuperenalottoDraw(
      date: null,
      contestNumber: int.parse(contest.group(1)!),
      numbers: null,
      jolly: null,
      superstar: null,
      error: 'Data non valida.',
    );
  }
  final jollyNumber = int.parse(jolly.group(1)!);
  final starNumber = int.parse(star.group(1)!);
  final problem = _numbersProblem(numbers, jollyNumber, starNumber);
  if (problem != null) {
    return ParsedSuperenalottoDraw(
      date: parsedDate,
      contestNumber: int.parse(contest.group(1)!),
      numbers: null,
      jolly: null,
      superstar: null,
      error: problem,
    );
  }
  return ParsedSuperenalottoDraw(
    date: parsedDate,
    contestNumber: int.parse(contest.group(1)!),
    numbers: List<int>.unmodifiable(numbers),
    jolly: jollyNumber,
    superstar: starNumber,
  );
}

String? _numbersProblem(List<int> numbers, int jolly, int superstar) {
  if (numbers.length != 6) return 'Attesi 6 numeri, trovati ${numbers.length}.';
  if (numbers.toSet().length != 6) return 'Numeri ripetuti nella sestina.';
  for (final number in [...numbers, jolly, superstar]) {
    if (number < 1 || number > 90) return 'Numero fuori da 1-90: $number.';
  }
  if (numbers.contains(jolly)) return 'Il Jolly compare anche nella sestina.';
  return null;
}

String superenalottoHash({
  required DateTime date,
  required int contestNumber,
  required List<int> numbers,
  required int jolly,
  required int superstar,
}) {
  return '${formatIsoDate(date)}|$contestNumber|${numbers.join(',')}|$jolly|$superstar';
}
