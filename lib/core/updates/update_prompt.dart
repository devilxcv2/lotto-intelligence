// lib/core/updates/update_prompt.dart

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/theme/app_theme.dart';
import '../network/dio_provider.dart';
import '../settings/settings_controller.dart';
import 'apk_downloader.dart';
import 'app_update.dart';

/// All'apertura (e al ritorno in primo piano) propone lo scarico se c'è una
/// versione più nuova. «Più tardi» ricorda solo quella versione; Scarica no.
class UpdatePrompt extends ConsumerStatefulWidget {
  const UpdatePrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends ConsumerState<UpdatePrompt> with WidgetsBindingObserver {
  DateTime? _lastAutoCheck;
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ritardo breve: lascia partire splash/rete e non si sovrappone al popup serale.
    _startupTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _autoCheck();
    });
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _autoCheck();
  }

  Future<void> _autoCheck() async {
    final now = DateTime.now();
    if (_lastAutoCheck != null && now.difference(_lastAutoCheck!) < const Duration(minutes: 2)) {
      return;
    }
    _lastAutoCheck = now;
    await offerAppUpdate(context, ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> offerAppUpdate(BuildContext context, WidgetRef ref, {bool ignoreDismiss = false}) async {
  final repository = ref.read(settingsRepositoryProvider);
  final manifestUrl = await repository.updateManifestUrl();
  if (!context.mounted) return;
  if (!_httpUrl(manifestUrl)) {
    if (ignoreDismiss) _snack(context, 'In Impostazioni manca l\'indirizzo del file di versione.');
    return;
  }
  final catalog = await _fetchCatalog(ref.read(dioProvider), manifestUrl, retries: ignoreDismiss ? 1 : 3);
  if (!context.mounted) return;
  if (catalog == null) {
    if (ignoreDismiss) _snack(context, 'Il file di versione non è leggibile. Controlla la rete e l\'indirizzo.');
    return;
  }
  final info = await PackageInfo.fromPlatform();
  final installed = int.tryParse(info.buildNumber) ?? 0;
  final available = catalog.newerThan(installed);
  if (available.isEmpty) {
    if (ignoreDismiss && context.mounted) {
      _snack(context, 'È installata la versione ${info.version}. Non ce n\'è una più nuova.');
    }
    return;
  }
  final latest = available.first;
  if (!ignoreDismiss && latest.versionCode <= await repository.dismissedUpdateCode()) return;
  if (!context.mounted) return;

  final chosen = await showDialog<PublishedUpdate>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) => _VersionPickerDialog(
      installedName: info.version,
      installedCode: installed,
      available: available,
    ),
  );
  // Solo «Più tardi» silenzia quella versione. Scarica può fallire: ripropone.
  if (chosen == null) {
    await repository.dismissUpdate(latest.versionCode);
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) => _DownloadDialog(release: chosen, dio: ref.read(dioProvider)),
  );
}

class _VersionPickerDialog extends StatefulWidget {
  const _VersionPickerDialog({
    required this.installedName,
    required this.installedCode,
    required this.available,
  });

  final String installedName;
  final int installedCode;
  final List<PublishedUpdate> available;

  @override
  State<_VersionPickerDialog> createState() => _VersionPickerDialogState();
}

class _VersionPickerDialogState extends State<_VersionPickerDialog> {
  late PublishedUpdate _selected = widget.available.first;

  @override
  Widget build(BuildContext context) {
    final many = widget.available.length > 1;
    return AlertDialog(
      title: Text(many ? 'Aggiornamento disponibile' : 'Versione ${_selected.versionName} disponibile'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Installata: ${widget.installedName} (${widget.installedCode}). '
              '${many ? 'Puoi prendere l\'ultima oppure una versione intermedia.' : 'È l\'ultima pubblicata.'} '
              'Scaricare non è obbligatorio.',
            ),
            const SizedBox(height: 12),
            Container(height: 8, color: AppColors.banner),
            const SizedBox(height: 12),
            if (many)
              RadioGroup<PublishedUpdate>(
                groupValue: _selected,
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
                child: Column(
                  children: [
                    for (final release in widget.available)
                      RadioListTile<PublishedUpdate>(
                        value: release,
                        title: Text(
                          release.versionCode == widget.available.first.versionCode
                              ? '${release.versionName} · ultima (consigliata)'
                              : release.versionName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          release.notes.isEmpty ? 'Codice ${release.versionCode}' : release.notes,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              )
            else ...[
              Text(_selected.notes.isEmpty ? 'Puoi scaricare quando vuoi.' : _selected.notes),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Più tardi')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(many ? 'Scarica ${_selected.versionName}' : 'Scarica'),
        ),
      ],
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog({required this.release, required this.dio});

  final PublishedUpdate release;
  final Dio dio;

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  late final ApkDownloader _downloader = ApkDownloader(widget.dio);
  DownloadProgress _progress = const DownloadProgress(received: 0, total: 0, bytesPerSecond: 0);
  String? _error;
  File? _file;
  var _done = false;
  var _installing = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final file = await _downloader.download(
        release: widget.release,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (!mounted) return;
      setState(() {
        _file = file;
        _done = true;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      if (CancelToken.isCancel(error)) {
        Navigator.pop(context);
        return;
      }
      setState(() => _error = 'Scarico non riuscito. Controlla la rete e riprova.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  Future<void> _install() async {
    final file = _file;
    if (file == null) return;
    setState(() => _installing = true);
    final result = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
    if (!mounted) return;
    setState(() => _installing = false);
    if (result.type != ResultType.done) {
      setState(() => _error = 'Il telefono non ha aperto l\'installazione (${result.message}).');
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = _progress.total;
    final received = _progress.received;
    final remaining = _progress.remaining;
    return AlertDialog(
      title: Text(_done ? 'Pronto da installare' : 'Scarico ${_progress.fraction == 0 ? '…' : '${(_progress.fraction * 100).toStringAsFixed(0)}%'}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Versione ${widget.release.versionName}'),
            const SizedBox(height: 12),
            Container(height: 8, color: AppColors.banner),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
            else if (_done)
              const Text('File scaricato. Tocca Installa e, se Android lo chiede, consenti l\'installazione da questa app.')
            else ...[
              LinearProgressIndicator(value: total <= 0 ? null : _progress.fraction, minHeight: 10),
              const SizedBox(height: 12),
              Text(
                total <= 0
                    ? 'Ricevuti ${formatByteSize(received)}…'
                    : '${formatByteSize(received)} di ${formatByteSize(total)}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.numberBlue),
              ),
              const SizedBox(height: 4),
              Text(
                _progress.bytesPerSecond <= 0
                    ? 'Calcolo velocità…'
                    : '${formatByteSize(_progress.bytesPerSecond.round())}/s'
                        '${remaining == null ? '' : ' · restano circa ${formatRemaining(remaining)}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_done)
          TextButton(
            onPressed: () {
              _downloader.cancel();
              Navigator.pop(context);
            },
            child: const Text('Annulla'),
          ),
        if (_done) ...[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Chiudi')),
          FilledButton(
            onPressed: _installing ? null : _install,
            child: Text(_installing ? 'Apro…' : 'Installa'),
          ),
        ],
      ],
    );
  }
}

Future<UpdateCatalog?> _fetchCatalog(Dio dio, String url, {int retries = 3}) async {
  Object? lastError;
  for (var attempt = 0; attempt < retries; attempt++) {
    if (attempt > 0) {
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }
    try {
      final response = await dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          // Evita risposte cache vecchie del CDN GitHub.
          headers: {
            'User-Agent': 'LottoIntelligenceAI/0.5 (controllo versione)',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
          validateStatus: (code) => code != null && code < 500,
        ),
      );
      if ((response.statusCode ?? 500) >= 400) {
        lastError = 'HTTP ${response.statusCode}';
        continue;
      }
      final body = response.data;
      if (body == null || body.isEmpty) {
        lastError = 'vuoto';
        continue;
      }
      final catalog = parseUpdateCatalog(body);
      if (catalog != null) return catalog;
      lastError = 'JSON non valido';
    } catch (error) {
      lastError = error;
    }
  }
  assert(() {
    // ignore: avoid_print
    print('Aggiornamento: lettura manifesto fallita ($lastError)');
    return true;
  }());
  return null;
}

bool _httpUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}
