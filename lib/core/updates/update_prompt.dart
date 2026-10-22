// lib/core/updates/update_prompt.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/dio_provider.dart';
import '../settings/settings_controller.dart';
import 'app_update.dart';

/// All'apertura dell'app, se il file di versione pubblicato è più nuovo,
/// chiede se scaricare. «Più tardi» lascia l'app com'è e non riproponi
/// la stessa versione.
class UpdatePrompt extends ConsumerStatefulWidget {
  const UpdatePrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends ConsumerState<UpdatePrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) offerAppUpdate(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> offerAppUpdate(BuildContext context, WidgetRef ref, {bool ignoreDismiss = false}) async {
  final repository = ref.read(settingsRepositoryProvider);
  final manifestUrl = await repository.updateManifestUrl();
  if (!context.mounted) return;
  if (!_httpUrl(manifestUrl)) {
    if (ignoreDismiss) {
      _snack(context, 'In Impostazioni manca l\'indirizzo del file di versione.');
    }
    return;
  }
  final published = await _fetch(ref.read(dioProvider), manifestUrl);
  if (!context.mounted) return;
  if (published == null) {
    if (ignoreDismiss) _snack(context, 'Il file di versione non è leggibile.');
    return;
  }
  final info = await PackageInfo.fromPlatform();
  final installed = int.tryParse(info.buildNumber) ?? 0;
  if (!isNewerRelease(installedCode: installed, publishedCode: published.versionCode)) {
    if (ignoreDismiss && context.mounted) {
      _snack(context, 'È installata la versione ${info.version}. Non ce n\'è una più nuova nel file pubblicato.');
    }
    return;
  }
  if (!ignoreDismiss && published.versionCode <= await repository.dismissedUpdateCode()) return;
  if (!context.mounted) return;
  final download = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Versione ${published.versionName} disponibile'),
      content: Text(
        published.notes.isEmpty
            ? 'Puoi scaricare l\'aggiornamento quando vuoi. L\'app continua a funzionare anche se rimandi.'
            : '${published.notes}\n\nPuoi scaricare l\'aggiornamento quando vuoi. L\'app continua a funzionare anche se rimandi.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Più tardi')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Scarica')),
      ],
    ),
  );
  if (download == null) return;
  await repository.dismissUpdate(published.versionCode);
  if (download != true || !context.mounted) return;
  final opened = await launchUrl(Uri.parse(published.apkUrl), mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _snack(context, 'Il telefono non ha aperto il file. L\'indirizzo è ${published.apkUrl}.');
  }
}

Future<PublishedUpdate?> _fetch(Dio dio, String url) async {
  try {
    final response = await dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        headers: {'User-Agent': 'LottoIntelligenceAI/0.5 (controllo versione)'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    if ((response.statusCode ?? 500) >= 400) return null;
    final body = response.data;
    if (body == null || body.isEmpty) return null;
    return parseUpdateManifest(body);
  } catch (_) {
    return null;
  }
}

bool _httpUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}
