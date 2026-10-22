// lib/core/lotto/wheel_catalog.dart

/// Ruota del Lotto. Il codice è quello pubblicato nell'archivio testuale
/// collegato da lotto-italia.it (RN = Nazionale).
class WheelInfo {
  const WheelInfo(this.code, this.name, this.sortOrder);

  final String code;
  final String name;
  final int sortOrder;
}

const List<WheelInfo> officialWheels = [
  WheelInfo('BA', 'Bari', 1),
  WheelInfo('CA', 'Cagliari', 2),
  WheelInfo('FI', 'Firenze', 3),
  WheelInfo('GE', 'Genova', 4),
  WheelInfo('MI', 'Milano', 5),
  WheelInfo('NA', 'Napoli', 6),
  WheelInfo('PA', 'Palermo', 7),
  WheelInfo('RM', 'Roma', 8),
  WheelInfo('TO', 'Torino', 9),
  WheelInfo('VE', 'Venezia', 10),
  WheelInfo('RN', 'Nazionale', 11),
];

const Map<String, String> _wheelAliases = {
  'NAZ': 'RN',
  'NZ': 'RN',
  'NAZIONALE': 'RN',
};

WheelInfo? wheelByCode(String raw) {
  final code = normalizeWheelCode(raw);
  for (final wheel in officialWheels) {
    if (wheel.code == code) return wheel;
  }
  return null;
}

String normalizeWheelCode(String raw) {
  final upper = raw.trim().toUpperCase();
  return _wheelAliases[upper] ?? upper;
}

String formatIsoDate(DateTime date) {
  final utc = date.toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String formatItalianDate(DateTime date) {
  final utc = date.toUtc();
  final d = utc.day.toString().padLeft(2, '0');
  final m = utc.month.toString().padLeft(2, '0');
  return '$d/$m/${utc.year}';
}

DateTime dateOnlyUtc(DateTime date) => DateTime.utc(date.toUtc().year, date.toUtc().month, date.toUtc().day);
