// lib/features/virtual_wallet/presentation/quick_play_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/prize_table.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../superenalotto/presentation/se_chrome.dart';
import '../../superenalotto/presentation/se_studio_page.dart';
import 'wallet_pages.dart';

/// GUI rapida: Lotto e SuperEnalotto senza cercare nei menu.
class QuickPlayPage extends ConsumerStatefulWidget {
  const QuickPlayPage({super.key});

  @override
  ConsumerState<QuickPlayPage> createState() => _QuickPlayPageState();
}

class _QuickPlayPageState extends ConsumerState<QuickPlayPage> {
  final _picked = <int>{};
  var _seMode = false;

  void _toggle(int n) {
    setState(() {
      if (!_picked.remove(n)) {
        final cap = _seMode ? 6 : maxTicketNumbers;
        if (_picked.length >= cap) return;
        _picked.add(n);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    final sorted = _picked.toList()..sort();
    final readyLotto = sorted.isNotEmpty;
    final readySe = sorted.length == 6;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text('Crea schedina')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _GameCard(
                        title: 'Lotto',
                        subtitle: 'Poste e ruota',
                        color: AppColors.navy,
                        selected: !_seMode,
                        onTap: () => setState(() {
                          _seMode = false;
                          if (_picked.length > maxTicketNumbers) {
                            final keep = (_picked.toList()..sort()).take(maxTicketNumbers);
                            _picked
                              ..clear()
                              ..addAll(keep);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GameCard(
                        title: 'SuperEnalotto',
                        subtitle: '6 numeri · 1 €',
                        color: SeColors.forest,
                        selected: _seMode,
                        onTap: () => setState(() {
                          _seMode = true;
                          if (_picked.length > 6) {
                            final keep = (_picked.toList()..sort()).take(6);
                            _picked
                              ..clear()
                              ..addAll(keep);
                          }
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _seMode ? 'Scegli 6 numeri (${sorted.length}/6)' : 'Scegli i numeri (${sorted.length}/$maxTicketNumbers)',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 8),
                if (sorted.isNotEmpty) NumberBalls(numbers: sorted, gold: _seMode),
                const SizedBox(height: 12),
                _QuickGrid(selected: _picked, onToggle: _toggle, accent: _seMode ? SeColors.forest : AppColors.ballGold),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _seMode ? SeColors.forest : AppColors.navy,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _seMode
                      ? (readySe ? () => context.push(seStudioRoute(numbers: sorted)) : null)
                      : (readyLotto
                          ? () => context.push(newTicketRoute(numbers: sorted, wheel: settings?.selectedWheelCode))
                          : null),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _seMode
                        ? (readySe ? 'Apri studio SE' : 'Servono 6 numeri')
                        : (readyLotto ? 'Apri composizione Lotto' : 'Scegli almeno un numero'),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: sorted.isEmpty ? null : () => setState(_picked.clear),
                  child: const Text('Svuota selezione'),
                ),
                const SizedBox(height: 20),
                const ResultsBanner('Altre scorciatoie'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.center_focus_strong, size: 18),
                      label: const Text('Ambo mirato'),
                      onPressed: () => context.push(newTicketRoute(wheel: settings?.selectedWheelCode)),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.view_module_outlined, size: 18),
                      label: const Text('Maschera G4'),
                      onPressed: () => context.push('/lab/sisal'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.dashboard_customize_outlined, size: 18),
                      label: const Text('Bacheca SE'),
                      onPressed: () => context.push('/more/se/bacheca'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text('Catalogo SE'),
                      onPressed: () => context.push('/more/se/tickets'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? color : AppColors.line, width: selected ? 0 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: selected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: selected ? Colors.white70 : AppColors.ink.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid({required this.selected, required this.onToggle, required this.accent});

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 90,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;
        final on = selected.contains(number);
        return InkWell(
          onTap: () => onToggle(number),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: on ? accent : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: on ? accent : AppColors.line),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
