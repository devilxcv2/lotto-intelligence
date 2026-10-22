// lib/core/lotto/parsed_draw.dart

/// Riga letta da un archivio, prima dell'inserimento nel database.
class ParsedDraw {
  const ParsedDraw({
    required this.date,
    required this.wheelCode,
    required this.numbers,
    required this.lineNumber,
    this.contestNumber,
    this.error,
  });

  final DateTime? date;
  final String? wheelCode;
  final List<int>? numbers;
  final int? contestNumber;
  final int lineNumber;
  final String? error;

  bool get isValid => error == null && date != null && wheelCode != null && numbers != null;
}

class ParseBatch {
  const ParseBatch({required this.draws, required this.emptyLines});

  final List<ParsedDraw> draws;
  final int emptyLines;
}
