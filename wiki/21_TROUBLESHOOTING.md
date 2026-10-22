# Problemi

**L'archivio risulta in ritardo di venerdì sera.** Lo ZIP controllato il 9 ottobre 2026 arrivava all'8 ottobre. Dopo le 21:00 di un giorno di estrazione l'app si aspetta la data del giorno. Può essere solo il ritardo del file, non un'estrazione mancante.

**HTTP 404 sul download.** L'indirizzo è quello letto dal markup della pagina ufficiale in quella data. Se il concessionario lo sposta, va aggiornata `OfficialArchiveLocations` dopo aver ricontrollato la pagina. Non va inventato un endpoint.

**Import con conflitti.** Due file danno numeri diversi per la stessa data e ruota. La riga già presente resta. Il campione è nel log di sync.

**Ollama non risponde.** Controllare che il telefono raggiunga l'IP del PC, che Ollama ascolti sull'interfaccia di rete e non solo su localhost del PC, e che l'URL sia `http://192.168.x.x:11434` senza path extra. L'app non abilita il cleartext verso indirizzi pubblici.

**Drift non genera.** Usare `drift` e `drift_dev` 2.31 con questo Flutter. Vedi [04_TECH_STACK](04_TECH_STACK.md). Poi `dart run build_runner build`.

**Licenze Android.** `flutter doctor --android-licenses`.

**Secure storage su Linux desktop.** Il plugin può richiedere il portachiavi di sessione. I test non lo chiamano: usano il database in memoria e non salvano chiavi.
