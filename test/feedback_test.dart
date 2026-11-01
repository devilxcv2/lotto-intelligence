import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/feedback/feedback_models.dart';

void main() {
  test('bozza segnalazione: titolo issue e corpo con diagnostica', () {
    final draft = FeedbackDraft(
      kind: FeedbackKind.bug,
      title: 'Sync fallisce la sera',
      body: 'Dopo le 20:30 l\'archivio resta in ritardo anche con rete.',
      includeDiagnostics: true,
      versionName: '0.5.22',
      versionCode: '30',
      createdAt: DateTime.utc(2026, 11, 1, 15),
      contact: 'utente@example.com',
    );
    expect(draft.issueTitle, '[Bug] Sync fallisce la sera');
    final body = draft.buildIssueBody(platformLine: 'android 14');
    expect(body, contains('## Bug'));
    expect(body, contains('20:30'));
    expect(body, contains('0.5.22'));
    expect(body, contains('utente@example.com'));
    expect(body, contains('android 14'));

    final roundtrip = FeedbackDraft.fromJson(draft.toJson());
    expect(roundtrip?.kind, FeedbackKind.bug);
    expect(roundtrip?.title, draft.title);
  });
}
