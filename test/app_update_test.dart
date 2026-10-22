// test/app_update_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/updates/app_update.dart';

void main() {
  const body = '''
{
  "versionName": "0.5.5",
  "versionCode": 13,
  "apkUrl": "https://example.invalid/lotto-13.apk",
  "notes": "Ultima",
  "releases": [
    {
      "versionName": "0.5.5",
      "versionCode": 13,
      "apkUrl": "https://example.invalid/lotto-13.apk",
      "notes": "Ultima"
    },
    {
      "versionName": "0.5.4",
      "versionCode": 12,
      "apkUrl": "https://example.invalid/lotto-12.apk",
      "notes": "Intermedia"
    },
    {
      "versionName": "0.5.2",
      "versionCode": 10,
      "apkUrl": "https://example.invalid/lotto-10.apk",
      "notes": "Vecchia"
    }
  ]
}
''';

  test('una versione con versionCode più alto è un aggiornamento', () {
    final published = parseUpdateManifest(body);
    expect(published, isNotNull);
    expect(published!.versionName, '0.5.5');
    expect(isNewerRelease(installedCode: 12, publishedCode: published.versionCode), isTrue);
    expect(isNewerRelease(installedCode: 13, publishedCode: published.versionCode), isFalse);
  });

  test('se si è rimasti indietro si vedono tutte le versioni più nuove', () {
    final catalog = parseUpdateCatalog(body)!;
    final available = catalog.newerThan(10);
    expect(available.map((item) => item.versionCode), [13, 12]);
    expect(available.first.versionName, '0.5.5');
    expect(catalog.newerThan(13), isEmpty);
  });

  test('senza un indirizzo http dell\'APK il file non è una pubblicazione', () {
    expect(parseUpdateManifest(body.replaceAll('https://example.invalid/lotto-13.apk', '')), isNull);
    expect(parseUpdateManifest('''{"versionName":"1","versionCode":1,"apkUrl":"file:///tmp/a.apk"}'''), isNull);
  });

  test('il tempo restante e le dimensioni sono leggibili', () {
    expect(formatByteSize(1536), contains('KB'));
    expect(formatRemaining(const Duration(seconds: 45)), '45 s');
    expect(formatRemaining(const Duration(minutes: 2, seconds: 5)), '2 min 5 s');
  });
}
