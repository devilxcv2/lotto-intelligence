// test/app_update_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/updates/app_update.dart';

void main() {
  const body = '''
{
  "versionName": "0.5.2",
  "versionCode": 10,
  "apkUrl": "https://example.invalid/lotto.apk",
  "notes": "Studio"
}
''';

  test('una versione con versionCode più alto è un aggiornamento', () {
    final published = parseUpdateManifest(body);
    expect(published, isNotNull);
    expect(published!.versionName, '0.5.2');
    expect(isNewerRelease(installedCode: 9, publishedCode: published.versionCode), isTrue);
    expect(isNewerRelease(installedCode: 10, publishedCode: published.versionCode), isFalse);
  });

  test('senza un indirizzo http dell\'APK il file non è una pubblicazione', () {
    expect(parseUpdateManifest(body.replaceAll('https://example.invalid/lotto.apk', '')), isNull);
    expect(parseUpdateManifest(body.replaceAll('https://example.invalid/lotto.apk', 'file:///tmp/a.apk')), isNull);
  });
}
