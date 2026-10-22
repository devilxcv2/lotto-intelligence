// lib/core/lotto/draw_validation.dart

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'wheel_catalog.dart';

/// Esito della validazione di una cinquina. I numeri restano nell'ordine
/// pubblicato: la posizione può coincidere con l'ordine di estrazione,
/// ma l'archivio non lo certifica da solo.
class DrawValidation {
  const DrawValidation._({required this.numbers, this.error});

  final List<int>? numbers;
  final String? error;

  bool get isValid => error == null && numbers != null;
}

DrawValidation validateDrawNumbers(List<int> numbers) {
  if (numbers.length != 5) {
    return DrawValidation._(numbers: null, error: 'Servono esattamente 5 numeri, ricevuti ${numbers.length}.');
  }
  final seen = <int>{};
  for (final number in numbers) {
    if (number < 1 || number > 90) {
      return DrawValidation._(numbers: null, error: 'Numero fuori dal range 1-90: $number.');
    }
    if (!seen.add(number)) {
      return DrawValidation._(numbers: null, error: 'Numero ripetuto nella stessa cinquina: $number.');
    }
  }
  return DrawValidation._(numbers: List<int>.unmodifiable(numbers));
}

/// Data di calendario, senza ora. Accetta yyyy-MM-dd e yyyy/MM/dd.
DateTime? parseDrawDate(String raw) {
  final text = raw.trim().replaceAll('/', '-');
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  if (year < 1939 || year > 2100) return null;
  return date;
}

String contentHashFor({
  required DateTime date,
  required String wheelCode,
  required List<int> numbers,
}) {
  final canonical = '${formatIsoDate(date)}|$wheelCode|${numbers.join(',')}';
  return sha256.convert(utf8.encode(canonical)).toString();
}

/// Buchi in una sequenza di numeri di concorso. Se manca anche un solo
/// valore, il controllo non si applica: l'archivio ufficiale non pubblica
/// il numero di concorso.
List<int> missingContestNumbers(Iterable<int?> contestNumbers) {
  final values = <int>[];
  for (final value in contestNumbers) {
    if (value == null) return const [];
    values.add(value);
  }
  if (values.length < 2) return const [];
  values.sort();
  final missing = <int>[];
  for (var i = 1; i < values.length; i++) {
    for (var n = values[i - 1] + 1; n < values[i]; n++) {
      missing.add(n);
    }
  }
  return missing;
}

class WheelDateGap {
  const WheelDateGap(this.wheelCode, this.missingDates);

  final String wheelCode;
  final List<DateTime> missingDates;
}

/// Una ruota manca su una data solo dopo la sua prima comparsa e non oltre
/// l'ultima. Le ruote introdotte dopo il 1939 non vanno trattate come buchi.
List<WheelDateGap> findWheelDateGaps(Map<String, Set<DateTime>> datesByWheel) {
  final all = <DateTime>{};
  for (final dates in datesByWheel.values) {
    all.addAll(dates);
  }
  final gaps = <WheelDateGap>[];
  for (final entry in datesByWheel.entries) {
    if (entry.value.isEmpty) continue;
    final sorted = entry.value.toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    final missing = all.where((date) => !date.isBefore(first) && !date.isAfter(last) && !entry.value.contains(date)).toList()
      ..sort();
    if (missing.isNotEmpty) {
      gaps.add(WheelDateGap(entry.key, missing));
    }
  }
  gaps.sort((a, b) => a.wheelCode.compareTo(b.wheelCode));
  return gaps;
}
