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

/// Avviso «sta per estrarre»: 30 minuti prima della chiusura raccolta.
const int preDrawReminderHour = 19;
const int preDrawReminderMinute = 0;

/// Fascia tipica in cui i bollettini pubblici iniziano a essere visibili.
/// Non è immediata dopo le 19:30: di solito verso le 20:30.
const int typicalResultsHour = 20;
const int typicalResultsMinute = 30;

/// Primo controllo automatico dello ZIP ufficiale.
const int archiveCheckHour = 20;
const int archiveCheckMinute = 15;

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
  return DateTime(utc.year, utc.month, utc.day, archiveCheckHour, archiveCheckMinute);
}

/// Fase della serata di estrazione, per popup e testi in app.
enum DrawEveningPhase {
  /// Nessun avviso.
  none,

  /// Tra le 18:30 e le 19:30: raccolta in chiusura, estrazione imminente.
  closingSoon,

  /// Dopo le 19:30: risultati non subito online, attesa ZIP.
  waitingResults,
}

DrawEveningPhase drawEveningPhase(DateTime now) {
  final local = now.toLocal();
  if (!isDrawWeekday(local)) return DrawEveningPhase.none;
  final minutes = local.hour * 60 + local.minute;
  if (minutes >= 18 * 60 + 30 && minutes < salesCloseHour * 60 + salesCloseMinute) {
    return DrawEveningPhase.closingSoon;
  }
  if (minutes >= salesCloseHour * 60 + salesCloseMinute && minutes < 23 * 60) {
    return DrawEveningPhase.waitingResults;
  }
  return DrawEveningPhase.none;
}

/// Testo fisso sulla timeline serale (chiusura → esiti → ZIP).
const String drawEveningTimeline =
    'Nei giorni di estrazione (mar · gio · ven · sab):\n'
    '• 19:30 — chiude la raccolta.\n'
    '• Verso le 20:30 — di solito i risultati diventano visibili (non subito dopo le 19:30).\n'
    '• Dalle 20:15 — l\'app scarica lo ZIP ufficiale e riprova ogni 20 minuti fino alle 23, poi ti notifica.';

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
