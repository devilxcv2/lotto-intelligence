// lib/app/app_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/updates/update_prompt.dart';
import '../features/draws/data/archive_sync.dart';
import 'draw_evening_prompt.dart';
import 'result_notice.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    // Ordine allineato ai branch del router: Home → Estrazioni → Schedine → Lab → Altro.
    const items = <(IconData, String)>[
      (Icons.home_outlined, 'Home'),
      (Icons.confirmation_number_outlined, 'Estrazioni'),
      (Icons.receipt_long_outlined, 'Schedine'),
      (Icons.science_outlined, 'Lab'),
      (Icons.menu, 'Altro'),
    ];
    final body = ResultNoticeHost(
      child: Column(
        children: [
          Expanded(child: shell),
          const _SyncBanner(),
        ],
      ),
    );
    final page = wide
        ? Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: shell.goBranch,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items) NavigationRailDestination(icon: Icon(item.$1), label: Text(item.$2)),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          )
        : Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: shell.goBranch,
              destinations: [
                for (final item in items) NavigationDestination(icon: Icon(item.$1), label: item.$2),
              ],
            ),
          );
    return UpdatePrompt(child: DrawEveningPrompt(child: page));
  }
}

/// L'aggiornamento continua mentre si naviga; il banner lo rende visibile
/// da ogni scheda senza obbligare a restare sulla Home.
class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(archiveSyncProvider);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !sync.running
          ? const SizedBox(width: double.infinity)
          : Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(sync.message ?? 'Aggiornamento archivio', maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: sync.progress == 0 ? null : sync.progress),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(archiveSyncProvider.notifier).cancel(),
                      child: const Text('Annulla'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
