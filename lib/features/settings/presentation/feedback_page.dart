// lib/features/settings/presentation/feedback_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/feedback/feedback_models.dart';
import '../../../core/feedback/feedback_outbox.dart';
import '../../../core/updates/share_links.dart';
import '../../../shared/widgets/common_widgets.dart';

/// Segnalazioni bug e richieste funzionalità → Issues GitHub (+ copia locale).
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _contact = TextEditingController();
  var _kind = FeedbackKind.bug;
  var _diagnostics = true;
  var _busy = false;
  String? _message;
  PackageInfo? _info;
  List<FeedbackOutboxEntry> _sent = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final sent = await ref.read(feedbackOutboxProvider).list();
    if (!mounted) return;
    setState(() {
      _info = info;
      _sent = sent;
    });
  }

  FeedbackDraft _draft() {
    final info = _info;
    return FeedbackDraft(
      kind: _kind,
      title: _title.text,
      body: _body.text,
      includeDiagnostics: _diagnostics,
      versionName: info?.version ?? '?',
      versionCode: info?.buildNumber ?? '?',
      createdAt: DateTime.now().toUtc(),
      contact: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
    );
  }

  Uri _githubIssueUri(FeedbackDraft draft) {
    final platform = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'.trim();
    return Uri.parse(AppShareLinks.feedbackNewIssueBase).replace(
      queryParameters: {
        'title': draft.issueTitle,
        'body': draft.buildIssueBody(platformLine: platform),
      },
    );
  }

  Future<void> _send() async {
    final draft = _draft();
    if (draft.title.trim().isEmpty || draft.body.trim().length < 12) {
      setState(() => _message = 'Scrivi un titolo e almeno un paio di frasi sul problema o sulla richiesta.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final uri = _githubIssueUri(draft);
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    await ref.read(feedbackOutboxProvider).append(
          FeedbackOutboxEntry(
            id: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
            draft: draft,
            sentAt: DateTime.now().toUtc(),
            issueUrl: uri.toString(),
          ),
        );
    if (!opened) {
      await SharePlus.instance.share(
        ShareParams(
          text: '${draft.issueTitle}\n\n${draft.buildIssueBody()}\n\nApri anche: ${AppShareLinks.feedbackIssuesUrl}',
          subject: draft.issueTitle,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = opened
          ? 'Apro GitHub: completa l\'invio lì (serve un account). Copia salvata anche in app.'
          : 'GitHub non si è aperto: usa la condivisione. Copia salvata in app per dopo.';
      _title.clear();
      _body.clear();
    });
    await _load();
  }

  Future<void> _copyDraft() async {
    final draft = _draft();
    await Clipboard.setData(ClipboardData(text: '${draft.issueTitle}\n\n${draft.buildIssueBody()}'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Testo copiato')));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Segnalazioni',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          const Text(
            'Bug, richieste e idee arrivano sulle Issues del progetto GitHub. '
            'Più avanti le smisteremo in un database dedicato.',
            style: TextStyle(height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              for (final kind in FeedbackKind.values)
                ChoiceChip(
                  label: Text(kind.label),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Titolo',
              hintText: 'Es. La maschera G4 non registra le sestine',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: 5,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Dettagli',
              hintText: 'Cosa succede, cosa ti aspettavi, su che schermata…',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contact,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Contatto (facoltativo)',
              hintText: 'Email o handle, se vuoi una risposta',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Includi versione app e sistema'),
            subtitle: Text(
              _info == null ? '…' : '${_info!.version}+${_info!.buildNumber} · ${Platform.operatingSystem}',
            ),
            value: _diagnostics,
            onChanged: (v) => setState(() => _diagnostics = v),
          ),
          if (_message != null) ...[
            Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
          FilledButton.icon(
            onPressed: _busy ? null : _send,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: Text(_busy ? 'Apro…' : 'Invia su GitHub'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _copyDraft,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copia testo'),
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(AppShareLinks.feedbackIssuesUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('Apri elenco segnalazioni'),
          ),
          const SizedBox(height: 20),
          const ResultsBanner('In studio (dopo)'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: const Text(
              'Obiettivo successivo: un modellino AI che legge le schedine di studio '
              '(con consenso) insieme allo ZIP delle estrazioni, per capire pattern '
              'descrittivi — non per prevedere i numeri. Prima arriverà un database '
              'per smistare queste segnalazioni.',
              style: TextStyle(height: 1.4),
            ),
          ),
          if (_sent.isNotEmpty) ...[
            const SizedBox(height: 20),
            const ResultsBanner('Inviate da questo telefono'),
            const SizedBox(height: 8),
            for (final entry in _sent.take(8))
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(entry.draft.issueTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${entry.draft.kind.label} · ${entry.sentAt.toLocal()}'),
                  dense: true,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
