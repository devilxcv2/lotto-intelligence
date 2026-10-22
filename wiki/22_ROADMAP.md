# Roadmap

## Fatto in 0.1.0

- Audit dell'ambiente e progetto Flutter Android e Linux.
- Tema, navigazione a cinque rami, onboarding, impostazioni.
- Schema SQLite e archivio reale dallo ZIP pubblicato, più import manuale.
- Statistiche descrittive, heatmap, coppie, correlazione su due numeri.
- System builder integrale e parametrico, strategie, schedina ipotetica con tetti.
- Backtest walk-forward, baseline, Monte Carlo, export JSON CSV PDF.
- Motori locali A–C e provider remoto opzionale.
- Wiki allineata a questo codice. `flutter analyze` pulito e `flutter test` verdi.
- APK debug arm64 in `build/app/outputs/flutter-apk/app-debug.apk`.

## Fatto in 0.2.0

- Import, statistiche e backtest fuori dal thread UI, banner di avanzamento globale.
- System builder con colonne da 2 a 10, integrali grandi e ridotti verificati, annullabili.

## Fatto in 0.3.0

- Tabella premi con fonti ADM e lotto-italia.it, schedine da 1 a 10 numeri con poste per sorte, ruota singola o TUTTE.
- Valutazione automatica delle schedine al concorso di riferimento, lordo, ritenuta 8%, netto, «e se avessi puntato».
- Aggiornamento serale a app chiusa con WorkManager e notifica locale; schema 2 con migrazione testata.
- Catalogo dei metodi classici misurato su Bari; home, portafoglio e schedine ridisegnati.

## Aperto

- Confronto fra due fonti prima di alzare `officiallyVerified`.
- ROI e drawdown in euro nel backtest: la tabella premi c'è, manca il profilo di posta per estrazione simulata.
- Estratto determinato e ambetto nella tabella premi.
- Verifica su telefono del task WorkManager con Doze e dei tempi reali di pubblicazione dello ZIP serale.
- Ridotti con meno colonne (ricerca locale dopo il greedy), sempre con la stessa verifica esaustiva.
- Finestra personalizzata oltre ai preset, oggi coperta da «Tutte» e dai preset.
- Modello ML classico solo come servizio opzionale, con lo stesso vincolo anti-leakage del backtest.
- Firma di release con keystore dell'utente.
- APK universale (oltre arm64) e installazione su dispositivo Android fisico o emulatore, assente in questo ambiente.
