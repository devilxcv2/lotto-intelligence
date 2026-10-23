// lib/app/app_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/updates/update_prompt.dart';
import 'theme/app_theme.dart';
import '../features/draws/data/archive_sync.dart';
import 'draw_evening_prompt.dart';
import 'result_notice.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _items = <_NavItem>[
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.bolt_rounded, Icons.bolt_outlined, 'Extra'),
    _NavItem(Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Ticket'),
    _NavItem(Icons.auto_awesome_rounded, Icons.auto_awesome_outlined, 'Lab'),
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Più'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
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
                  backgroundColor: const Color(0xFFF7F9FC),
                  indicatorColor: AppColors.banner.withValues(alpha: 0.22),
                  selectedIconTheme: const IconThemeData(color: AppColors.navy),
                  unselectedIconTheme: IconThemeData(color: AppColors.ink.withValues(alpha: 0.45)),
                  destinations: [
                    for (final item in _items)
                      NavigationRailDestination(
                        icon: Icon(item.outline),
                        selectedIcon: Icon(item.filled),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          )
        : Scaffold(
            body: body,
            extendBody: true,
            bottomNavigationBar: _YouthBottomBar(
              index: shell.currentIndex,
              items: _items,
              onSelect: shell.goBranch,
            ),
          );
    return UpdatePrompt(child: DrawEveningPrompt(child: page));
  }
}

class _NavItem {
  const _NavItem(this.filled, this.outline, this.label);

  final IconData filled;
  final IconData outline;
  final String label;
}

/// Barra flottante a pillola: più leggera e “app moderna” della NavigationBar piatta.
class _YouthBottomBar extends StatelessWidget {
  const _YouthBottomBar({
    required this.index,
    required this.items,
    required this.onSelect,
  });

  final int index;
  final List<_NavItem> items;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom > 0 ? bottom : 12),
      child: Material(
        elevation: 10,
        shadowColor: AppColors.navy.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _YouthNavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouthNavButton extends StatelessWidget {
  const _YouthNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.filled : item.outline,
              size: 22,
              color: selected ? AppColors.ballText : AppColors.ink.withValues(alpha: 0.42),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: selected ? 0.2 : 0,
                color: selected ? Colors.white : AppColors.ink.withValues(alpha: 0.48),
              ),
            ),
          ],
        ),
      ),
    );
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
