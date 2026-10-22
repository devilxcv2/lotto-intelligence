# Changelog

## 0.5.3 — 2026-10-22

Indirizzo di aggiornamento già impostato.

- Se in Impostazioni il campo del file di versione è vuoto, l'app legge da sola `dist/update.json` sul repository pubblico GitHub. Non serve più copiare l'indirizzo a mano.

## 0.5.2 — 2026-10-22

Zoppe a gambe e SuperEnalotto.

- Il Sistemone Zoppe prende un gettonato a caso, un ritardatario e un numero dalle fasce 30–45, 50–65 e 70–85. La legenda in pagina spiega ogni gamba. Sul SuperEnalotto la stessa costruzione ha sei numeri (più la fascia 15–30) e suggerisce Jolly e SuperStar dalle loro storie, senza inventare importi.

## 0.5.1 — 2026-10-22

Richiesta di aggiornamento, non obbligatoria.

- In Impostazioni si indica l'indirizzo di `update.json`. Se il `versionCode` pubblicato è più alto, all'apertura l'app chiede se scaricare. «Più tardi» continua con la versione installata e non ripete quella stessa richiesta. «Scarica» apre l'APK nel browser.

## 0.5.0 — 2026-10-22

Studio SuperEnalotto.

- Da Altro, da Estrazioni e dalle schedine del Lotto si apre uno studio dedicato: ultime combinazioni, dieci ritardatari, tre suggerimenti (ritardo, frequenza, Zoppe da sei) e una griglia per la schedina.
- La schedina ha sei numeri e una SuperStar facoltativa. Il sistemone riusa il ridotto già verificato, con colonne da 6: dal system builder, una colonna da 6 si porta nello studio.
- Dopo lo scarico le schedine del concorso si chiudono sulla categoria (sei, cinque + Jolly, cinque, quattro, tre, due). Non c'è un importo: il premio è a montepremi. Le schedine del Lotto restano nel portafoglio, con le poste in euro.

## 0.4.1 — 2026-10-22

Sistemone Zoppe.

- Nel Laboratorio, e dal pronostico del system builder, si apre lo Zoppe: maschera positiva scelta a mano, maschera negativa come complemento dei 90.
- Dalla negativa entra la fascia di frequenza fra il 30° e il 45° posto delle ultime 100 estrazioni. Dalla positiva entra il 10–15% con più uscite. Le colonne mescolano le due gambe, con meno numeri dalla positiva.
- In pagina resta la probabilità equa, 5 su 90. La fascia non è una previsione.

## 0.4.0 — 2026-10-22

SuperEnalotto e avviso a schermo.

- In Estrazioni si passa da Lotto a SuperEnalotto. Le combinazioni (sei numeri, Jolly, SuperStar) si scaricano dalle pagine dell'archivio ufficiale: il sito non pubblica uno ZIP unico. «Ultimi concorsi» legge la pagina corrente, «Dal 2023» le pagine mensili. Lo ZIP del Lotto resta quello di lotto-italia.it.
- A scarico finito compare un avviso a tutto schermo con l'esito del controllo delle schedine ipotetiche. La notifica di sistema, la sera, cita anche i concorsi SuperEnalotto nuovi.
- I premi in euro del SuperEnalotto non sono calcolati: sono a montepremi e non stanno nella tabella scaricata.

## 0.3.2 — 2026-10-10

Ricerca trend.

- Laboratorio → Ricerca trend: legge le ultime 2–12 settimane della ruota e prova dieci regole (frequenza, pendenza, giorno della settimana, eco, laterali, ritmo proprio, decine, cifre finali, ripetizione breve, coppie).
- Accanto a ogni numero mette la quota osservata e la probabilità equa 5/90. La regola in testa propone 5 numeri e un ridotto da 15, con la garanzia verificata. Il testo dice che la scelta della regola migliore sullo stesso archivio non è una previsione.

## 0.3.1 — 2026-10-10

Bacheca estrazioni.

- Tema chiaro di default nello stile della bacheca classica: titolo blu, fascia arancione, ruote arancioni, numeri blu, palline blu con cifra gialla. Il tema scuro tiene gli stessi colori su fondo blu notte.
- Pagina Estrazioni e giorno di estrazione a tabella, come l'elenco delle undici ruote. Ritardi e frequenze con intestazione arancione e righe alternate.
- Chi aveva il tema scuro predefinito delle versioni precedenti passa una volta al chiaro. Si può tornare a Scuro dalle impostazioni.

## 0.3.0 — 2026-10-10

Studio in tempo reale.

- Tabella premi del Lotto con fonti ADM e lotto-italia.it verificate il 10 ottobre 2026: coefficienti per sorte, divisione per le combinazioni, TUTTE ÷10, ritenuta 8%, tetto 6.000.000 €, posta 1–200 € a passi di 0,50.
- Schedine ipotetiche da 1 a 10 numeri, poste per sorte, ruota singola o TUTTE, concorso di riferimento calcolato con la chiusura delle 19:30. Le pagine Backtest e Sistemi aprono la nuova schedina precompilata.
- Valutazione automatica dopo ogni importazione, al ritorno in primo piano e all'apertura dell'elenco: centri, lordo, netto, dettaglio per ruota e per sorte. Analisi «e se avessi puntato…» e ritorno atteso.
- Portafoglio con saldo, giocato, lordo, netto, ritorno, capitale residuo, grafico del saldo e limiti. Home con scheda «Studio in tempo reale».
- Aggiornamento serale a app chiusa con WorkManager (20:15, tentativi ogni 20 minuti fino alle 23) e notifica locale con apertura dell'elenco schedine. Interruttore separato per le notifiche, permesso chiesto a runtime.
- `ArchiveSyncService` condiviso fra app e task; `busy_timeout` sul database.
- Schema 2 con migrazione da 1 testata su fixture; `ticket_numbers` fino a 10 posizioni.
- Metodi classici misurati su Bari (`tools/strategies_benchmark_test.dart`): nessuno distinguibile dal caso su 1.000 estrazioni.
- Nuovi test: 29 verdi. Gradle con desugaring. APK debug arm64 ricompilato.

## 0.2.0 — 2026-10-09

Fluidità e sistemi grandi.

- SQLite su isolate di background. Unzip, parsing e hash dell'archivio su `Isolate.run`. Deduplica e conflitti in SQL tramite tabella temporanea. Banner di avanzamento con «Annulla» su ogni scheda.
- Statistiche e backtest fuori dal thread UI, statistiche in cache per ruota e finestra.
- Lettura di una ruota compattata: blocco UI da 73 a 19 ms sull'archivio reale.
- System builder: colonne da 2 a 10, integrali fino a 200.000 colonne, ridotto (v, k, m, t) con verifica esaustiva, generazione annullabile con avanzamento reale, filtri regolabili, riempimento da frequenti, ritardatari, casuali o testo, lista completa scorrevole, export JSON.
- Nuovi test: ridotto verificato e rifiutato, colonne da 2 e 10, job annullabile, conflitti e duplicati nello stesso file.
- Strumenti di misura in `tools/`.

## 0.1.0 — 2026-10-09

Prima versione eseguibile.

- Progetto Flutter 3.41.6, Riverpod, GoRouter, Drift 2.31.
- Import dell'archivio ZIP collegato da lotto-italia.it e import CSV/JSON.
- Statistiche, sistemi, backtest senza vincite inventate, portafoglio con tetti, wiki offline.
- Le estrazioni importate restano non marcate come ufficialmente verificate.
- APK debug arm64 compilato. Non installato su dispositivo.
