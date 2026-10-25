import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/updates/share_links.dart';

void main() {
  test('messaggio di invito contiene landing e versione', () {
    final text = AppShareLinks.inviteMessage(versionName: '0.5.16', apkUrl: 'https://example.com/a.apk');
    expect(text, contains(AppShareLinks.landingUrl));
    expect(text, contains('0.5.16'));
    expect(text, contains('https://example.com/a.apk'));
  });
}
