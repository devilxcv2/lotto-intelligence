// lib/features/draws/data/import_preparation.dart

import '../../../core/lotto/draw_validation.dart';
import '../../../core/lotto/parsed_draw.dart';
import '../../../core/lotto/wheel_catalog.dart';

class PreparedDraw {
  const PreparedDraw({
    required this.date,
    required this.wheelCode,
    required this.numbers,
    required this.hash,
    required this.contestNumber,
  });

  final DateTime date;
  final String wheelCode;
  final List<int> numbers;
  final String hash;
  final int? contestNumber;
}

/// Righe valide e già deduplicate all'interno del file, con gli hash calcolati.
/// Il confronto con l'archivio locale avviene poi dentro SQLite.
class PreparedImport {
  const PreparedImport({
    required this.parsed,
    required this.rows,
    required this.invalid,
    required this.duplicatesInFile,
    required this.conflictsInFile,
    required this.samples,
    required this.earliest,
    required this.latest,
  });

  final int parsed;
  final List<PreparedDraw> rows;
  final int invalid;
  final int duplicatesInFile;
  final int conflictsInFile;
  final List<String> samples;
  final DateTime? earliest;
  final DateTime? latest;
}

/// Funzione pura, pensata per `Isolate.run`: su un archivio completo
/// valida e calcola SHA-256 per decine di migliaia di righe.
PreparedImport prepareImport(List<ParsedDraw> draws) {
  final byKey = <String, String>{};
  final rows = <PreparedDraw>[];
  final samples = <String>[];
  var invalid = 0;
  var duplicates = 0;
  var conflicts = 0;
  DateTime? earliest;
  DateTime? latest;
  for (final draw in draws) {
    if (!draw.isValid) {
      invalid++;
      if (samples.length < 8) samples.add('Riga ${draw.lineNumber}: ${draw.error}');
      continue;
    }
    final date = draw.date!;
    final hash = contentHashFor(date: date, wheelCode: draw.wheelCode!, numbers: draw.numbers!);
    final key = '${formatIsoDate(date)}|${draw.wheelCode}';
    final previous = byKey[key];
    if (previous == hash) {
      duplicates++;
      continue;
    }
    if (previous != null) {
      conflicts++;
      if (samples.length < 8) {
        samples.add('${formatItalianDate(date)} ${draw.wheelCode}: il file contiene due cinquine diverse, tenuta la prima.');
      }
      continue;
    }
    byKey[key] = hash;
    rows.add(PreparedDraw(
      date: date,
      wheelCode: draw.wheelCode!,
      numbers: draw.numbers!,
      hash: hash,
      contestNumber: draw.contestNumber,
    ));
    if (earliest == null || date.isBefore(earliest)) earliest = date;
    if (latest == null || date.isAfter(latest)) latest = date;
  }
  return PreparedImport(
    parsed: draws.length,
    rows: rows,
    invalid: invalid,
    duplicatesInFile: duplicates,
    conflictsInFile: conflicts,
    samples: samples,
    earliest: earliest,
    latest: latest,
  );
}
