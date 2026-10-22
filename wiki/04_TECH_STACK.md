# Stack

Verificato su questa macchina il 9 ottobre 2026:

- Ubuntu 24.04.5, kernel 6.8
- Flutter 3.41.6 stable, Dart 3.11.4
- OpenJDK 17.0.20
- Android SDK in `/home/eriko/android-sdk`, compile platform android-36, build-tools 35.0.0
- `flutter doctor` segnala licenze Android non accettate

Dipendenze dell'app:

- flutter_riverpod 2.6.1
- go_router 17.5.0
- drift 2.31.0 e drift_dev 2.31.0
- sqlite3_flutter_libs 0.5.40
- dio 5.11.1, archive 4.0.9, crypto 3.0.7
- fl_chart 1.2.0
- flutter_secure_storage 11.2.0
- file_picker 13.1.0
- pdf 3.12.0 con DejaVu Sans, licenza in `assets/fonts/DejaVu-copyright.txt`

Drift 2.35 non è usato. Il `drift_dev` abbinato richiede un analyzer che dipende da `meta` ^1.18, mentre Flutter 3.41.6 fissa `meta` 1.17.0. La 2.31 è l'ultima serie che risolve su questo SDK.

Freezed e json_serializable non sono dipendenze: i modelli sono classi Dart chiuse e il JSON dell'import e dei report è poco e validato a mano. WorkManager non è una dipendenza: la sincronizzazione in primo piano è quella provata; il motivo è in [27_KNOWN_LIMITATIONS](27_KNOWN_LIMITATIONS.md).

Non c'è un backend Python. I conti stanno in Dart.
