// lib/core/feedback/feedback_outbox.dart
//
// Coda locale delle segnalazioni: oggi apre GitHub Issues; domani si potrà
// sincronizzare verso un database di smistamento senza perdere lo storico.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'feedback_models.dart';

class FeedbackOutboxEntry {
  const FeedbackOutboxEntry({
    required this.id,
    required this.draft,
    required this.sentAt,
    this.issueUrl,
  });

  final String id;
  final FeedbackDraft draft;
  final DateTime sentAt;
  final String? issueUrl;

  Map<String, Object?> toJson() => {
        'id': id,
        'draft': draft.toJson(),
        'sentAt': sentAt.toUtc().toIso8601String(),
        'issueUrl': issueUrl,
      };

  static FeedbackOutboxEntry? fromJson(Map<String, Object?> json) {
    final draftRaw = json['draft'];
    if (draftRaw is! Map) return null;
    final draft = FeedbackDraft.fromJson(Map<String, Object?>.from(draftRaw));
    if (draft == null) return null;
    return FeedbackOutboxEntry(
      id: json['id'] as String? ?? draft.createdAt.millisecondsSinceEpoch.toString(),
      draft: draft,
      sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      issueUrl: json['issueUrl'] as String?,
    );
  }
}

class FeedbackOutbox {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'feedback_outbox.json'));
  }

  Future<List<FeedbackOutboxEntry>> list() async {
    final file = await _file();
    if (!await file.exists()) return const [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map)
            ?FeedbackOutboxEntry.fromJson(Map<String, Object?>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> append(FeedbackOutboxEntry entry) async {
    final current = await list();
    final next = [entry, ...current].take(100).toList();
    final file = await _file();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert([
      for (final e in next) e.toJson(),
    ]));
  }
}

final feedbackOutboxProvider = Provider<FeedbackOutbox>((ref) => FeedbackOutbox());
