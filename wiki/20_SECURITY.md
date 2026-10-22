# Sicurezza

- Nessuna chiave nel codice.
- Le chiavi dei provider stanno in `flutter_secure_storage`. I log di esecuzione riportano l'esito e il percorso (`/models`, `/api/tags`, generazione), non l'header Authorization e non il corpo.
- Gli errori Dio mostrati all'utente non includono l'URL con query né la richiesta.
- HTTP verso host pubblici è rifiutato. HTTP verso LAN e localhost è ammesso per Ollama.
- Il database non contiene credenziali.
- L'app non avvia pagamenti e non apre una ricevitoria.
- Il permesso Android `INTERNET` serve al download dell'archivio e ai provider opzionali. `POST_NOTIFICATIONS` (Android 13+) serve all'avviso locale e viene chiesto solo quando l'utente attiva l'opzione.
- I plugin aggiungono al manifest finale (verificato con `aapt2 dump permissions` sull'APK 0.3.0): `POST_NOTIFICATIONS`, `VIBRATE` da flutter_local_notifications; `WAKE_LOCK`, `ACCESS_NETWORK_STATE`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SHORT_SERVICE` da workmanager. L'app non avvia servizi in primo piano: la dichiarazione è del plugin.
- Le notifiche sono locali: nessun servizio push, nessun token, nessun dato inviato. Il corpo contiene data, numero di schedine e importi simulati.
- Il task serale usa la stessa URL pubblica e lo stesso parser dell'app. Non apre altri endpoint.
- Il font DejaVu Sans è ridistribuito con la nota in `assets/fonts/DejaVu-copyright.txt`. Il file non è stato modificato.
