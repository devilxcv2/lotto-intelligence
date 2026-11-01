// lib/features/virtual_wallet/presentation/ticket_hub_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../superenalotto/data/se_ticket_repository.dart';
import '../../superenalotto/presentation/se_chrome.dart';
import '../data/wallet_repository.dart';

/// Menu Ticket: crea, storico, stats Lotto/SE — tutto senza girare l'interfaccia.
class TicketHubPage extends ConsumerWidget {
  const TicketHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotto = ref.watch(ticketsProvider).value ?? const <StoredTicket>[];
    final se = ref.watch(seTicketsProvider).value ?? const <SeTicket>[];
    final lottoOpen = lotto.where((t) => t.isOpen).length;
    final seOpen = se.where((t) => t.isOpen).length;
    final lottoWins = lotto.where((t) => t.evaluation?.isWin == true).length;
    final seWins = se.where((t) => t.match?.isCategoryWin == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF163A66), Color(0xFF1B4E8C), Color(0xFF2F6EAD)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.ballGold.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.ballGold.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(Icons.confirmation_number_rounded, color: AppColors.ballGold, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Ticket',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'serif',
                                height: 1.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crea, storico e numeri che hanno pagato — senza cercare nei menu.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.88), height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _HeroStat(label: 'Lotto attesa', value: '$lottoOpen')),
                          const SizedBox(width: 8),
                          Expanded(child: _HeroStat(label: 'SE attesa', value: '$seOpen')),
                          const SizedBox(width: 8),
                          Expanded(child: _HeroStat(label: 'Vincite', value: '${lottoWins + seWins}')),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          title: 'Crea',
                          subtitle: 'Lotto o SE in un tap',
                          icon: Icons.flash_on_rounded,
                          gradient: const [Color(0xFF1B4E8C), Color(0xFF2F6EAD)],
                          onTap: () => context.push('/tickets/quick'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Storico',
                          subtitle: 'Tutto a portata',
                          icon: Icons.history_rounded,
                          gradient: const [Color(0xFF0B5C3B), Color(0xFF1A8F5C)],
                          onTap: () => context.push('/tickets/history'),
                        ),
                      ),
                    ],
                  ),
                ),
                HubSection(
                  title: 'Cosa ha preso',
                  subtitle: 'Numeri delle tue schedine, incrociati con le ultime uscite.',
                  children: [
                    HubTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Numeri Lotto',
                      subtitle: lottoWins == 0
                          ? 'Ancora nessuna vincita simulata'
                          : '$lottoWins in utile · ruote delle ultime uscite',
                      onTap: () => context.push('/tickets/stats/lotto'),
                    ),
                    HubTile(
                      icon: Icons.stars_outlined,
                      title: 'Numeri SuperEnalotto',
                      subtitle: seWins == 0
                          ? 'Ancora nessuna categoria'
                          : '$seWins categorie · ultime uscite SE',
                      accent: SeColors.forest,
                      onTap: () => context.push('/tickets/stats/se'),
                    ),
                  ],
                ),
                HubSection(
                  title: 'Scorciatoie',
                  children: [
                    HubTile(
                      icon: Icons.add_circle_outline,
                      title: 'Nuova Lotto completa',
                      subtitle: 'Ruota, poste e sorti',
                      onTap: () => context.push('/tickets/new'),
                    ),
                    HubTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Studio SuperEnalotto',
                      subtitle: 'Sei numeri, SuperStar, sistemoni',
                      accent: SeColors.forest,
                      onTap: () => context.push('/more/se/studio'),
                    ),
                    HubTile(
                      icon: Icons.view_module_outlined,
                      title: 'Maschera G5 / G4 / G3',
                      subtitle: 'Sistema SE con registrazione a budget',
                      accent: SeColors.forest,
                      onTap: () => context.push('/lab/sisal'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Text(
                    'Tutto studio: nessuna giocata reale. I numeri «caldi» descrivono il passato delle tue schedine, non prevedono il prossimo concorso.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.58),
                          height: 1.4,
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 118,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const Spacer(),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
