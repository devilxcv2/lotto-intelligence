// lib/core/lotto/freshness.dart

/// Stato di freschezza della fonte. È una stima sul calendario di estrazione
/// pubblicato (martedì, giovedì, venerdì, sabato, esiti circa alle 20:30),
/// non una certificazione che il file sia il bollettino ufficiale firmato.
enum SourceFreshness {
  updated,
  delayed,
  unavailable,
  unverified,
}

bool isDrawWeekday(DateTime date) {
  return date.weekday == DateTime.tuesday ||
      date.weekday == DateTime.thursday ||
      date.weekday == DateTime.friday ||
      date.weekday == DateTime.saturday;
}

/// Data di estrazione che ci si aspetta già pubblicata.
/// Dopo le 21:00 locali di un giorno di estrazione si attende la data odierna;
/// prima, l'ultimo giorno di estrazione precedente. La soglia delle 21:00
/// lascia margine rispetto alle 20:30 indicate sul sito.
DateTime expectedPublishedDrawDate(DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  if (isDrawWeekday(day) && now.hour >= 21) return day;
  do {
    day = day.subtract(const Duration(days: 1));
  } while (!isDrawWeekday(day));
  return day;
}

/// Chiusura della raccolta nei giorni di estrazione (ADM: ore 19:30).
const int salesCloseHour = 19;
const int salesCloseMinute = 30;

/// Prossimo concorso a cui parteciperebbe una giocata registrata adesso,
/// come data di calendario a mezzanotte UTC, coerente con `draws.draw_date`.
DateTime nextOpenDrawDate(DateTime now) {
  final local = now.toLocal();
  var day = DateTime(local.year, local.month, local.day);
  final beforeClose = local.hour < salesCloseHour || (local.hour == salesCloseHour && local.minute < salesCloseMinute);
  if (isDrawWeekday(day) && beforeClose) return DateTime.utc(day.year, day.month, day.day);
  do {
    day = day.add(const Duration(days: 1));
  } while (!isDrawWeekday(day));
  return DateTime.utc(day.year, day.month, day.day);
}

/// Istante locale in cui conviene cercare l'esito di [drawDate]:
/// le 20:15 del giorno di estrazione.
DateTime resultCheckTime(DateTime drawDate) {
  final utc = drawDate.toUtc();
  return DateTime(utc.year, utc.month, utc.day, 20, 15);
}

SourceFreshness evaluateFreshness({
  required DateTime? latestDrawDate,
  required DateTime now,
  required bool hasSuccessfulSync,
  required bool lastAttemptFailed,
}) {
  if (!hasSuccessfulSync || latestDrawDate == null) {
    return lastAttemptFailed ? SourceFreshness.unavailable : SourceFreshness.unverified;
  }
  final expected = expectedPublishedDrawDate(now);
  final latest = DateTime(latestDrawDate.toUtc().year, latestDrawDate.toUtc().month, latestDrawDate.toUtc().day);
  if (!latest.isBefore(expected)) return SourceFreshness.updated;
  return SourceFreshness.delayed;
}

String freshnessLabel(SourceFreshness freshness) {
  return switch (freshness) {
    SourceFreshness.updated => 'Aggiornata',
    SourceFreshness.delayed => 'In ritardo',
    SourceFreshness.unavailable => 'Non disponibile',
    SourceFreshness.unverified => 'Non verificata',
  };
}
