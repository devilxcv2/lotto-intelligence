# Build Android

Identificativo: `it.lottointelligence.lotto_intelligence`. Nome visibile: Lotto Intelligence. Minimo SDK: quello predefinito di Flutter 3.41. Java 17.

Dal 0.5.9 la release in `android/app/build.gradle.kts` è solo `arm64-v8a`, con `minifyEnabled` e `shrinkResources`, più `proguard-rules.pro`. Per sideload sui telefoni reali:

```bash
GRADLE_USER_HOME="/media/eriko/dati/gradle-user-home" \
TMPDIR="/media/eriko/dati/tmp-build" \
flutter build apk --release
```

L’APK esce in `build/app/outputs/flutter-apk/app-release.apk`. In debug, se serve un solo ABI:

Debug arm64, comando usato il 2026-10-09:

```bash
GRADLE_USER_HOME="/media/eriko/dati/gradle-user-home" \
TMPDIR="/media/eriko/dati/tmp-build" \
flutter build apk --debug --target-platform android-arm64
```

Risultato: `build/app/outputs/flutter-apk/app-debug.apk`, circa 94 MB, solo ABI `android-arm64`. Gradle 8.14 ha impiegato circa 21 minuti al primo avvio, con cache su disco dati perché la partizione di sistema era piena. Un tentativo precedente, con cache Gradle sotto `/tmp` sulla stessa partizione, si è interrotto con «Spazio esaurito sul device» mentre scaricava gli artifact delle altre ABI.

`flutter build apk --debug` senza `--target-platform` produce anche `armeabi-v7a` e `x86_64` e richiede più spazio. Su questa macchina va tenuto `GRADLE_USER_HOME` e `TMPDIR` fuori dalla partizione di sistema.

## Aggiornamento facoltativo

L'app non è sul Play Store. In Impostazioni si salva l'indirizzo di un file JSON, per esempio `dist/update.json` pubblicato accanto all'APK. All'apertura, se `versionCode` è più alto di quello installato, compare una richiesta con «Più tardi» e «Scarica». Scarica apre l'indirizzo `apkUrl` nel browser. L'installazione resta un gesto dell'utente. «Più tardi» ricorda quel `versionCode` e non lo richiede di nuovo. I telefoni che non hanno ancora questa versione non possono chiedere l'aggiornamento da soli.

```json
{
  "versionName": "0.5.2",
  "versionCode": 10,
  "apkUrl": "https://esempio/app-debug.apk",
  "notes": "Cosa cambia."
}
```

`apkUrl` deve essere `http` o `https`. Un file senza indirizzo non produce la richiesta.

Dal 0.5.5 il JSON può contenere anche `releases`: elenco di versioni con lo stesso schema. L'app propone quelle con `versionCode` più alto di quello installato; l'ultima è in cima e consigliata. Lo scarico avviene in app (barra e tempo restante), non solo aprendo il browser.

La build `release` nel `build.gradle.kts` firma ancora con la chiave di debug, così il progetto compila senza un keystore privato nel repository. Per una pubblicazione:

1. Generare un keystore fuori dal repository: `keytool -genkey -v -keystore lotto-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lotto`.
2. Mettere le password in `android/key.properties`, file già ignorato se si aggiunge a `.gitignore` locale e mai committato.
3. Collegare `signingConfigs.release` in `android/app/build.gradle.kts` e usarlo nel `buildType` release al posto di `signingConfigs.debug`.
4. `flutter build apk --release` oppure `flutter build appbundle --release`.

Non committare il file `.jks` né `key.properties`.

`flutter doctor` su questa macchina segnala licenze Android non accettate. Se Gradle si ferma lì: `flutter doctor --android-licenses`.

## Aggiunte della 0.3.0

- `isCoreLibraryDesugaringEnabled = true` e `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` in `android/app/build.gradle.kts`, richiesti da `flutter_local_notifications` 22.
- Il plugin aggiunge da sé `POST_NOTIFICATIONS` al manifest; il permesso viene chiesto a runtime su Android 13+.
- `workmanager` 0.10.10 non richiede voci nel manifest. Il task sopravvive al riavvio del telefono perché WorkManager è persistente.
- Build del 10 ottobre 2026: `flutter build apk --debug --target-platform android-arm64`, 83 s con cache Gradle su `/media/eriko/dati/gradle-user-home`.
