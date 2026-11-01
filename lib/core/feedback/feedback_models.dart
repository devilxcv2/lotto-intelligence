// lib/core/feedback/feedback_models.dart

enum FeedbackKind {
  bug('Bug', 'bug'),
  request('Richiesta', 'richiesta'),
  idea('Idea', 'idea');

  const FeedbackKind(this.label, this.slug);

  final String label;
  final String slug;
}

class FeedbackDraft {
  const FeedbackDraft({
    required this.kind,
    required this.title,
    required this.body,
    required this.includeDiagnostics,
    required this.versionName,
    required this.versionCode,
    required this.createdAt,
    this.contact,
  });

  final FeedbackKind kind;
  final String title;
  final String body;
  final bool includeDiagnostics;
  final String versionName;
  final String versionCode;
  final DateTime createdAt;
  final String? contact;

  String get issueTitle {
    final clean = title.trim().isEmpty ? '(senza titolo)' : title.trim();
    return '[${kind.label}] $clean';
  }

  String buildIssueBody({String? platformLine}) {
    final buffer = StringBuffer()
      ..writeln('## ${kind.label}')
      ..writeln()
      ..writeln(body.trim())
      ..writeln();
    if (contact != null && contact!.trim().isNotEmpty) {
      buffer
        ..writeln('### Contatto')
        ..writeln(contact!.trim())
        ..writeln();
    }
    if (includeDiagnostics) {
      buffer
        ..writeln('### Ambiente')
        ..writeln('- App: $versionName ($versionCode)')
        ..writeln('- Inviata: ${createdAt.toUtc().toIso8601String()}');
      if (platformLine != null && platformLine.isNotEmpty) {
        buffer.writeln('- $platformLine');
      }
      buffer.writeln();
    }
    buffer
      ..writeln('---')
      ..writeln('_Inviata dall\'app Lotto Intelligence. Studio, non gioco online._');
    return buffer.toString().trim();
  }

  Map<String, Object?> toJson() => {
        'kind': kind.slug,
        'title': title,
        'body': body,
        'includeDiagnostics': includeDiagnostics,
        'versionName': versionName,
        'versionCode': versionCode,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'contact': contact,
      };

  static FeedbackDraft? fromJson(Map<String, Object?> json) {
    final kindSlug = json['kind'] as String?;
    final kind = FeedbackKind.values.where((k) => k.slug == kindSlug).firstOrNull;
    if (kind == null) return null;
    final title = json['title'] as String? ?? '';
    final body = json['body'] as String? ?? '';
    if (title.trim().isEmpty && body.trim().isEmpty) return null;
    return FeedbackDraft(
      kind: kind,
      title: title,
      body: body,
      includeDiagnostics: json['includeDiagnostics'] as bool? ?? true,
      versionName: json['versionName'] as String? ?? '?',
      versionCode: json['versionCode'] as String? ?? '?',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      contact: json['contact'] as String?,
    );
  }
}
