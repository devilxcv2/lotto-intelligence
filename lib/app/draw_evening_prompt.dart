// lib/app/draw_evening_prompt.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/lotto/freshness.dart';
import '../core/lotto/wheel_catalog.dart';
import '../core/settings/settings_controller.dart';
import '../features/draws/data/archive_sync.dart';
import '../features/draws/data/draw_repository.dart';
import 'theme/app_theme.dart';

/// Popup serale: avvisa prima dell'estrazione e spiega quando i risultati
/// diventano visibili (non subito dopo le 19:30).
class DrawEveningPrompt extends ConsumerStatefulWidget {
  const DrawEveningPrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DrawEveningPrompt> createState() => _DrawEveningPromptState();
}

class _DrawEveningPromptState extends ConsumerState<DrawEveningPrompt> {
  String? _shownKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybePrompt();
    });
  }

  Future<void> _maybePrompt() async {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings == null) return;
    final now = DateTime.now();
    final phase = drawEveningPhase(now);
    if (phase == DrawEveningPhase.none) return;

    final dayKey = '${now.year}-${now.month}-${now.day}-${phase.name}';
    if (_shownKey == dayKey) return;

    if (phase == DrawEveningPhase.waitingResults) {
      final summary = await ref.read(drawRepositoryProvider).summary(now: now);
      final today = DateTime.utc(now.year, now.month, now.day);
      final latest = summary.latestDate?.toUtc();
      final hasToday = latest != null && !latest.isBefore(today) && latest.year == today.year && latest.month == today.month && latest.day == today.day;
      if (hasToday) return;
    }

    if (!mounted) return;
    _shownKey = dayKey;
    await showDialog<void>(
      context: context,
      builder: (context) => _DrawEveningDialog(
        phase: phase,
        liveSync: settings.liveSyncEnabled,
        onSync: () {
          Navigator.pop(context);
          ref.read(archiveSyncProvider.notifier).syncOfficial();
        },
        onSettings: () {
          Navigator.pop(context);
          context.push('/more/settings');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsControllerProvider, (previous, next) {
      if (previous?.value == null && next.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybePrompt();
        });
      }
    });
    return widget.child;
  }
}

class _DrawEveningDialog extends StatelessWidget {
  const _DrawEveningDialog({
    required this.phase,
    required this.liveSync,
    required this.onSync,
    required this.onSettings,
  });

  final DrawEveningPhase phase;
  final bool liveSync;
  final VoidCallback onSync;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final closing = phase == DrawEveningPhase.closingSoon;
    return AlertDialog(
      title: Text(closing ? 'Estrazione imminente' : 'Risultati non ancora online'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              closing
                  ? 'Oggi ${formatItalianDate(DateTime.now())} la raccolta chiude alle '
                      '$salesCloseHour:${salesCloseMinute.toString().padLeft(2, '0')}. '
                      'L\'estrazione non pubblica i numeri subito dopo la chiusura.'
                  : 'La raccolta di oggi è chiusa. I risultati non compaiono subito: '
                      'di solito diventano visibili verso le '
                      '$typicalResultsHour:${typicalResultsMinute.toString().padLeft(2, '0')}.',
            ),
            const SizedBox(height: 12),
            Container(height: 8, color: AppColors.banner),
            const SizedBox(height: 12),
            Text(drawEveningTimeline, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(
              liveSync
                  ? 'Aggiornamento automatico attivo: l\'app scaricherà lo ZIP da sola e ti notificherà.'
                  : 'Aggiornamento automatico spento: attiva Impostazioni → Aggiornamento serale, oppure controlla a mano.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actions: [
        if (!liveSync) TextButton(onPressed: onSettings, child: const Text('Impostazioni')),
        if (!closing) TextButton(onPressed: onSync, child: const Text('Controlla archivio')),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Ho capito')),
      ],
    );
  }
}
