// lib/features/virtual_wallet/presentation/ticket_hub_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../superenalotto/data/se_ticket_repository.dart';
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B4E8C), Color(0xFF163A66), Color(0xFFF0A01A)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Crea, storico e numeri che hanno pagato. '
                        'Lotto $lottoOpen in attesa · SE $seOpen in attesa.',
                        style: const TextStyle(color: Colors.white70, height: 1.35),
                      ),
                    ],
                  ),
                ),
                HubSection(
                  title: 'Veloce',
                  children: [
                    HubTile(
                      icon: Icons.flash_on_rounded,
                      title: 'Crea schedina',
                      subtitle: 'Lotto o SuperEnalotto in un tap',
                      onTap: () => context.push('/tickets/quick'),
                    ),
                    HubTile(
                      icon: Icons.history_rounded,
                      title: 'Storico schedine',
                      subtitle: 'Lotto e SE insieme, filtri e rigioca',
                      onTap: () => context.push('/tickets/history'),
                    ),
                  ],
                ),
                HubSection(
                  title: 'Cosa ha preso',
                  subtitle: 'Numeri delle tue schedine vincenti, incrociati con le ultime uscite.',
                  children: [
                    HubTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Numeri Lotto',
                      subtitle: lottoWins == 0
                          ? 'Ancora nessuna vincita simulata'
                          : '$lottoWins schedine in utile · ruote delle ultime uscite',
                      onTap: () => context.push('/tickets/stats/lotto'),
                    ),
                    HubTile(
                      icon: Icons.stars_outlined,
                      title: 'Numeri SuperEnalotto',
                      subtitle: seWins == 0
                          ? 'Ancora nessuna categoria'
                          : '$seWins categorie · ultime uscite SE',
                      onTap: () => context.push('/tickets/stats/se'),
                    ),
                  ],
                ),
                HubSection(
                  title: 'Scorciatoie',
                  children: [
                    HubTile(
                      icon: Icons.add_circle_outline,
                      title: 'Nuova Lotto',
                      subtitle: 'Composizione completa con poste',
                      onTap: () => context.push('/tickets/new'),
                    ),
                    HubTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Studio SuperEnalotto',
                      subtitle: 'Sei numeri, SuperStar, sistemoni',
                      onTap: () => context.push('/more/se/studio'),
                    ),
                    HubTile(
                      icon: Icons.view_module_outlined,
                      title: 'Maschera G5 / G4 / G3',
                      subtitle: 'Sistema SE con registrazione a budget',
                      onTap: () => context.push('/lab/sisal'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Tutto studio: nessuna giocata reale. I numeri «caldi» descrivono il passato delle tue schedine, non prevedono il prossimo concorso.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.ink.withValues(alpha: 0.65)),
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
