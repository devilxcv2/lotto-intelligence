# Test

```bash
flutter analyze
flutter test
```

`flutter test` copre, con esiti deterministici:

- cinquine invalide, date, buchi di concorso solo se i numeri ci sono tutti, buchi di ruota solo dopo la prima comparsa;
- parser ufficiale, CSV con alias `NAZ` e JSON di schema;
- freschezza al 9 ottobre 2026 alle 22:17 e alle 18:00;
- frequenze e ritardi su tre estrazioni costruite;
- sistema integrale di 6 combinazioni e rifiuto oltre il limite (40 numeri in cinquine);
- colonne da 2 e da 10 numeri con filtro neutro;
- ridotto su 12 numeri verificato in modo indipendente, riproducibile col seed, e rifiuto di una colonna singola e di parametri invalidi;
- job in background che completa 15.504 colonne e si annulla terminando l'isolate;
- import con conflitto non sovrascritto, date lette in UTC, duplicato nello stesso file;
- backtest che registra la lunghezza della storia e non fa vedere il 90 a una strategia di frequenza;
- baseline riproducibile a parità di seed;
- JSON monetario marcato non disponibile;
- policy degli endpoint;
- seed delle 11 ruote, import doppio, flag non verificato;
- blocco del portafoglio;
- tabella premi: coefficienti per 1 €, divisione per le combinazioni (3,74 / 83,33 su 3 numeri, 2,25 / 25 / 450 / 24.000 su 5), più centri che pagano più combinazioni, TUTTE ÷10, ritenuta 8%, tetto e passi di posta;
- valutazione di una schedina su una ruota e su tutte, «e se avessi puntato» solo sulle sorti giocabili;
- prossimo concorso aperto con chiusura alle 19:30 e ora del controllo serale;
- registrazione, attesa delle dieci ruote per TUTTE, valutazione unica, riepilogo con serie del saldo, rifiuto delle bozze fuori regola;
- migrazione dello schema 1 → 2 sulla fixture `test/fixtures/schema_v1.sqlite`;
- task serale con Dio finto che restituisce uno ZIP: nuova estrazione segnalata e schedina valutata, attesa se l'archivio è vecchio, nulla se l'opzione è spenta;
- onboarding fino alla dashboard vuota;
- ricerca trend: probabilità equa indipendente dal passato, frequenza del blocco recente, filtro sul giorno della settimana, walk-forward che non legge l'estrazione valutata, ridotto verificato sul pronostico.

`flutter analyze` del 2026-10-22: nessun problema. `flutter test`: 47 test verdi, incluso il confronto del versionCode per l'aggiornamento facoltativo.

Misure fuori dalla suite, in `tools/`:

```bash
LOTTO_ZIP=/percorso/storico.zip flutter test tools/import_benchmark_test.dart
flutter test tools/systems_benchmark_test.dart
LOTTO_ZIP=/percorso/storico.zip flutter test tools/strategies_benchmark_test.dart
```

Il primo importa l'archivio reale in un file SQLite temporaneo e misura il blocco massimo del thread principale per fase. Il secondo misura i generatori grandi. Il terzo confronta i metodi classici sulla ruota di Bari. I risultati sono in [08_DRAW_SYNC_ENGINE](08_DRAW_SYNC_ENGINE.md), [11_SYSTEM_BUILDER](11_SYSTEM_BUILDER.md) e [17_STRATEGY_EVALUATION](17_STRATEGY_EVALUATION.md).

Non è stato eseguito un test su dispositivo Android: `flutter doctor` non vede un emulatore utilizzabile e non c'è un telefono collegato. La compilazione Android è verificata dall'APK debug arm64 in `build/app/outputs/flutter-apk/app-debug.apk`. L'APK non è stato installato.

L'integration test su device non è stato aggiunto come percorso obbligatorio finché non c'è un emulatore: il widget test copre l'avvio senza rete.
