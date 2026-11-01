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
    final brand = _seMode ? SeColors.forest : AppColors.navy;
    final accent = _seMode ? SeColors.gold : AppColors.ballGold;

    return Scaffold(
      backgroundColor: _seMode ? SeColors.cream : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        title: Text(_seMode ? 'Crea SuperEnalotto' : 'Crea Lotto'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'serif',
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _GameCard(
                              title: 'Lotto',
                              subtitle: 'Poste e ruota',
                              icon: Icons.confirmation_number_outlined,
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
                              icon: Icons.stars_rounded,
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _seMode
                                  ? 'Scegli 6 numeri'
                                  : 'Scegli i numeri',
                              style: TextStyle(fontWeight: FontWeight.w800, color: brand, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: brand.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _seMode ? '${sorted.length}/6' : '${sorted.length}/$maxTicketNumbers',
                              style: TextStyle(fontWeight: FontWeight.w800, color: brand),
                            ),
                          ),
                        ],
                      ),
                      if (sorted.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        NumberBalls(numbers: sorted, gold: _seMode),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: _QuickGrid(
                          selected: _picked,
                          onToggle: _toggle,
                          accent: accent,
                          inkOn: _seMode ? SeColors.forestDeep : AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Scorciatoie', style: TextStyle(fontWeight: FontWeight.w800, color: brand)),
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
                Material(
                  elevation: 10,
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: sorted.isEmpty ? null : () => setState(_picked.clear),
                            child: const Text('Svuota'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: brand,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _seMode
                                  ? (readySe ? () => context.push(seStudioRoute(numbers: sorted)) : null)
                                  : (readyLotto
                                      ? () => context.push(
                                            newTicketRoute(numbers: sorted, wheel: settings?.selectedWheelCode),
                                          )
                                      : null),
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                _seMode
                                    ? (readySe ? 'Apri studio SE' : 'Servono 6')
                                    : (readyLotto ? 'Apri Lotto' : 'Scegli numeri'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? color : AppColors.line, width: selected ? 0 : 1),
        boxShadow: selected
            ? [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: selected ? Colors.white : color, size: 22),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: selected ? Colors.white : color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white70 : AppColors.ink.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid({
    required this.selected,
    required this.onToggle,
    required this.accent,
    required this.inkOn,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final Color accent;
  final Color inkOn;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 90,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;
        final on = selected.contains(number);
        return Material(
          color: on ? accent : const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onToggle(number),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: on ? inkOn : AppColors.ink.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
