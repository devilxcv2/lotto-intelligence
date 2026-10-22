// lib/core/lotto/archive_parser.dart

import 'dart:convert';

import 'draw_validation.dart';
import 'parsed_draw.dart';
import 'wheel_catalog.dart';

/// URL letti il 9 ottobre 2026 dal markup di
/// https://www.lotto-italia.it/lotto/estratti-ruote
/// Non sono un'API documentata: sono i file ZIP che la pagina ufficiale
/// offre in download. `storico.zip` contiene l'archivio dal 1939.
class OfficialArchiveLocations {
  const OfficialArchiveLocations._();

  static const pageUrl = 'https://www.lotto-italia.it/lotto/estratti-ruote';
  static const archiveUrl = 'https://www.brightstarlottery.it/STORICO_ESTRAZIONI_LOTTO/storico.zip';
  static const userAgent = 'LottoIntelligenceAI/0.1 (download archivio pubblico collegato da lotto-italia.it)';
}

/// Formato osservato in storico.txt: `YYYY/MM/DD<TAB>RUOTA<TAB>n1..n5`.
ParseBatch parseOfficialArchiveText(String text) {
  final lines = const LineSplitter().convert(text);
  final draws = <ParsedDraw>[];
  var empty = 0;
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i].trim();
    if (raw.isEmpty) {
      empty++;
      continue;
    }
    draws.add(_parseOfficialLine(raw, i + 1));
  }
  return ParseBatch(draws: draws, emptyLines: empty);
}

ParsedDraw _parseOfficialLine(String raw, int lineNumber) {
  final parts = raw.split('\t');
  if (parts.length != 7) {
    return ParsedDraw(
      date: null,
      wheelCode: null,
      numbers: null,
      lineNumber: lineNumber,
      error: 'Attese 7 colonne separate da tabulazione, trovate ${parts.length}.',
    );
  }
  return _assemble(
    dateRaw: parts[0],
    wheelRaw: parts[1],
    numberRaws: parts.sublist(2),
    lineNumber: lineNumber,
    contestNumber: null,
  );
}

/// CSV manuale: `date,wheel,n1,n2,n3,n4,n5` con intestazione opzionale.
/// La data accetta yyyy-MM-dd oppure yyyy/MM/dd.
ParseBatch parseManualCsv(String text) {
  final lines = const LineSplitter().convert(text);
  final draws = <ParsedDraw>[];
  var empty = 0;
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i].trim();
    if (raw.isEmpty) {
      empty++;
      continue;
    }
    if (i == 0 && raw.toLowerCase().startsWith('date')) continue;
    final parts = raw.split(RegExp(r'[;,]'));
    if (parts.length != 7) {
      draws.add(ParsedDraw(
        date: null,
        wheelCode: null,
        numbers: null,
        lineNumber: i + 1,
        error: 'Attese 7 colonne CSV, trovate ${parts.length}.',
      ));
      continue;
    }
    draws.add(_assemble(
      dateRaw: parts[0],
      wheelRaw: parts[1],
      numberRaws: parts.sublist(2),
      lineNumber: i + 1,
      contestNumber: null,
    ));
  }
  return ParseBatch(draws: draws, emptyLines: empty);
}

/// JSON manuale, schema `lotto-intelligence.draws/v1`.
ParseBatch parseManualJson(String text) {
  Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (error) {
    return ParseBatch(
      draws: [
        ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: 1, error: 'JSON non valido: ${error.message}.'),
      ],
      emptyLines: 0,
    );
  }
  if (decoded is! Map) {
    return ParseBatch(
      draws: [
        const ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: 1, error: 'Il JSON deve essere un oggetto.'),
      ],
      emptyLines: 0,
    );
  }
  final schema = decoded['schema'];
  if (schema != 'lotto-intelligence.draws/v1') {
    return ParseBatch(
      draws: [
        ParsedDraw(
          date: null,
          wheelCode: null,
          numbers: null,
          lineNumber: 1,
          error: 'Schema non riconosciuto: $schema.',
        ),
      ],
      emptyLines: 0,
    );
  }
  final rows = decoded['draws'];
  if (rows is! List) {
    return ParseBatch(
      draws: [
        const ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: 1, error: 'Manca l\'elenco draws.'),
      ],
      emptyLines: 0,
    );
  }
  final draws = <ParsedDraw>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (row is! Map) {
      draws.add(ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: i + 1, error: 'Riga non oggetto.'));
      continue;
    }
    final numbers = row['numbers'];
    if (numbers is! List) {
      draws.add(ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: i + 1, error: 'numbers deve essere un elenco.'));
      continue;
    }
    final parsedNumbers = <String>[];
    for (final value in numbers) {
      parsedNumbers.add('$value');
    }
    draws.add(_assemble(
      dateRaw: '${row['date']}',
      wheelRaw: '${row['wheel']}',
      numberRaws: parsedNumbers,
      lineNumber: i + 1,
      contestNumber: row['contestNumber'] is int ? row['contestNumber'] as int : null,
    ));
  }
  return ParseBatch(draws: draws, emptyLines: 0);
}

ParsedDraw _assemble({
  required String dateRaw,
  required String wheelRaw,
  required List<String> numberRaws,
  required int lineNumber,
  required int? contestNumber,
}) {
  final date = parseDrawDate(dateRaw);
  if (date == null) {
    return ParsedDraw(date: null, wheelCode: null, numbers: null, lineNumber: lineNumber, error: 'Data non valida: $dateRaw.');
  }
  final wheel = wheelByCode(wheelRaw);
  if (wheel == null) {
    return ParsedDraw(date: date, wheelCode: null, numbers: null, lineNumber: lineNumber, error: 'Ruota sconosciuta: $wheelRaw.');
  }
  final numbers = <int>[];
  for (final raw in numberRaws) {
    final value = int.tryParse(raw.trim());
    if (value == null) {
      return ParsedDraw(
        date: date,
        wheelCode: wheel.code,
        numbers: null,
        lineNumber: lineNumber,
        error: 'Numero non intero: $raw.',
      );
    }
    numbers.add(value);
  }
  final validation = validateDrawNumbers(numbers);
  if (!validation.isValid) {
    return ParsedDraw(
      date: date,
      wheelCode: wheel.code,
      numbers: null,
      lineNumber: lineNumber,
      error: validation.error,
    );
  }
  return ParsedDraw(
    date: date,
    wheelCode: wheel.code,
    numbers: validation.numbers,
    lineNumber: lineNumber,
    contestNumber: contestNumber,
  );
}
