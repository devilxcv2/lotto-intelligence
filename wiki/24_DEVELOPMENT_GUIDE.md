# Sviluppo

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run -d linux
GRADLE_USER_HOME="/media/eriko/dati/gradle-user-home" TMPDIR="/media/eriko/dati/tmp-build" \
  flutter build apk --debug --target-platform android-arm64
```

Il codice generato è `lib/core/database/app_database.g.dart`. Non si modifica a mano.

La prima riga dei file scritti a mano è il percorso, così si ritrova il modulo. I file generati non seguono questa convenzione.

I motori in `domain/` si testano senza dispositivo. Il database di test è in memoria e semina le ruote da solo.

Non inserire estrazioni casuali nel database dell'app per riempire i buchi. Le fixture dei test sono stringhe piccole, fra cui la prima riga reale dell'archivio pubblico del 1939-01-07 sulla ruota di Bari.
