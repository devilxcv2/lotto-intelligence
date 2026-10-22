# Lotto Intelligence AI

Laboratorio locale per l'archivio del Lotto italiano: estrazioni, statistiche descrittive, sistemi di studio e backtest. Le estrazioni passate non vengono presentate come probabilità future.

Versione 0.5.2. La documentazione è in [`wiki/00_INDEX.md`](wiki/00_INDEX.md).

## Avvio

```bash
flutter pub get
dart run build_runner build
flutter test
flutter run -d linux
GRADLE_USER_HOME="/media/eriko/dati/gradle-user-home" TMPDIR="/media/eriko/dati/tmp-build" \
  flutter build apk --debug --target-platform android-arm64
```

L'APK debug arm64 della 0.5.2 è `build/app/outputs/flutter-apk/app-debug.apk`. Non è stato installato su un telefono in questo ambiente.

Ambiente usato per questa versione: Flutter 3.41.6, Dart 3.11.4, Java 17.

Il primo archivio si scarica dal pulsante «Aggiorna archivio». Il file è lo ZIP collegato dalla pagina ufficiale delle estrazioni. Senza rete restano le analisi sui dati già importati.

## Cosa non fa

Non compra giocate, non calcola premi in euro e non marca una riga come ufficialmente verificata. I limiti sono in [`wiki/27_KNOWN_LIMITATIONS.md`](wiki/27_KNOWN_LIMITATIONS.md).
