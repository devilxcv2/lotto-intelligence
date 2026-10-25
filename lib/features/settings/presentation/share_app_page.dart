// lib/features/settings/presentation/share_app_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/updates/app_update.dart';
import '../../../core/updates/share_links.dart';
import '../../../shared/widgets/common_widgets.dart';

/// Pagina per copiare o inviare il link di download dell'app.
class ShareAppPage extends ConsumerStatefulWidget {
  const ShareAppPage({super.key});

  @override
  ConsumerState<ShareAppPage> createState() => _ShareAppPageState();
}

class _ShareAppPageState extends ConsumerState<ShareAppPage> {
  PublishedUpdate? _latest;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(settingsRepositoryProvider);
      final url = await repo.updateManifestUrl();
      final dio = ref.read(dioProvider);
      final response = await dio.get<String>(
        url.trim().isEmpty ? AppShareLinks.updateManifestUrl : url.trim(),
        options: Options(responseType: ResponseType.plain, receiveTimeout: const Duration(seconds: 12)),
      );
      final catalog = parseUpdateCatalog(response.data ?? '');
      if (!mounted) return;
      setState(() {
        _latest = catalog?.latest;
        _error = catalog == null ? 'File di versione non leggibile.' : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Rete non disponibile. Puoi comunque condividere la pagina di download.';
        _loading = false;
      });
    }
  }

  String get _invite => AppShareLinks.inviteMessage(
        versionName: _latest?.versionName,
        apkUrl: _latest?.apkUrl,
      );

  Future<void> _copy(String value, String okLabel) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(okLabel)));
  }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: _invite, subject: 'Lotto Intelligence'));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Condividi',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4E8C), Color(0xFF2F6EAD), Color(0xFFF0A01A)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invia l\'app', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  'Un link da WhatsApp, SMS o mail. Chi lo apre scarica l\'APK Android.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
          ],
          if (_latest != null) ...[
            Text(
              'Ultima pubblicata: ${_latest!.versionName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            if (_latest!.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_latest!.notes, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
          ],
          SectionCard(
            title: 'Link da condividere',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(AppShareLinks.landingUrl, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Condividi'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(AppShareLinks.landingUrl, 'Link pagina copiato'),
                      icon: const Icon(Icons.link),
                      label: const Text('Copia link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(_invite, 'Messaggio copiato'),
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copia messaggio'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'APK diretto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  _latest?.apkUrl ?? AppShareLinks.releasesLatestUrl,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _copy(
                    _latest?.apkUrl ?? AppShareLinks.releasesLatestUrl,
                    'Indirizzo APK copiato',
                  ),
                  icon: const Icon(Icons.android),
                  label: const Text('Copia indirizzo APK'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'La pagina pubblica legge sempre l\'ultima versione da GitHub. '
            'Chi riceve il link non ha bisogno di avere già l\'app.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Aggiorna versione dal file pubblico'),
          ),
        ],
      ),
    );
  }
}
