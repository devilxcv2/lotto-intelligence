// lib/features/superenalotto/presentation/se_hub_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lotto/wheel_catalog.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/presentation/draws_pages.dart';
import '../data/se_ticket_repository.dart';
import '../data/superenalotto_repository.dart';
import '../data/superenalotto_sync.dart';
import 'se_chrome.dart';

/// Area dedicata al SuperEnalotto: distinta dal Lotto (schedine, archivio, studio).
class SeHubPage extends ConsumerWidget {
  const SeHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draws = ref.watch(superenalottoDrawsProvider);
    final tickets = ref.watch(seTicketsProvider);
    final sync = ref.watch(superenalottoSyncProvider);
    final ticketList = tickets.value ?? const <SeTicket>[];
    final open = ticketList.where((t) => t.isOpen).length;
    final wins = ticketList.where((t) => t.match?.isCategoryWin == true).length;
    final closed = ticketList.where((t) => !t.isOpen).length;

    return Scaffold(
      backgroundColor: SeColors.cream,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SeHeroHeader(
                  title: 'SuperEnalotto',
                  subtitle: 'Studio separato dal Lotto: categorie di premio, non euro simulati.',
                  trailing: IconButton(
                    tooltip: 'Aggiorna archivio',
                    onPressed: sync.running ? null : () => ref.read(superenalottoSyncProvider.notifier).syncLatest(),
                    icon: Icon(
                      sync.running ? Icons.hourglass_top : Icons.refresh,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (sync.running || sync.message != null || sync.error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sync.message != null) Text(sync.message!),
                        if (sync.running) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: sync.progress == 0 ? null : sync.progress,
                            color: SeColors.forest,
                          ),
                        ],
                        if (sync.error != null)
                          Text(sync.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      SeStatChip(label: 'In attesa', value: '$open'),
                      const SizedBox(width: 8),
                      SeStatChip(label: 'Valutate', value: '$closed'),
                      const SizedBox(width: 8),
                      SeStatChip(label: 'Categorie', value: '$wins', highlight: wins > 0),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                draws.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(color: SeColors.forest),
                  ),
                  error: (error, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$error')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SeActionCard(
                          icon: Icons.cloud_download_outlined,
                          title: 'Scarica i concorsi',
                          subtitle: 'Nessun archivio ancora. Parti dagli ultimi ufficiali.',
                          onTap: () {
                            if (!sync.running) ref.read(superenalottoSyncProvider.notifier).syncLatest();
                          },
                        ),
                      );
                    }
                    final latest = items.first;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: SeColors.forest.withValues(alpha: 0.15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResultsBanner(
                                'Ultimo · Nº ${latest.contestNumber} · ${formatItalianDate(latest.date)}',
                                color: SeColors.forest,
                              ),
                              const SizedBox(height: 14),
                              NumberBalls(numbers: latest.numbers, gold: true),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('Jolly ${latest.jolly}', style: const TextStyle(fontWeight: FontWeight.w700, color: SeColors.forest)),
                                  const SizedBox(width: 16),
                                  Text('SuperStar ${latest.superstar}', style: const TextStyle(fontWeight: FontWeight.w700, color: SeColors.mint)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Categorie a montepremi: sei, cinque + Jolly, cinque, quattro, tre, due. Nessun importo inventato.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SeActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Nuova schedina',
                        subtitle: 'Sei numeri, SuperStar facoltativa, suggerimenti e sistemone',
                        onTap: () => context.push('/more/se/studio'),
                      ),
                      const SizedBox(height: 10),
                      SeActionCard(
                        icon: Icons.view_module_outlined,
                        title: 'Sistemi G5 / G4 / G3',
                        subtitle: 'Maschera Sisal: griglia colonne e quanto spendi',
                        onTap: () => context.push('/lab/sisal'),
                      ),
                      const SizedBox(height: 10),
                      SeActionCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Catalogo schedine',
                        subtitle: open + closed == 0
                            ? 'Ancora vuoto · separato dalle schedine Lotto'
                            : '$open in attesa · $wins con categoria · mai mescolate al Lotto',
                        onTap: () => context.push('/more/se/tickets'),
                      ),
                      const SizedBox(height: 10),
                      SeActionCard(
                        icon: Icons.table_chart_outlined,
                        title: 'Estrazioni e archivio',
                        subtitle: 'Ultime combinazioni e scarico dal sito ufficiale',
                        onTap: () {
                          ref.read(drawsGameProvider.notifier).state = 1;
                          context.go('/draws');
                        },
                      ),
                      const SizedBox(height: 10),
                      SeActionCard(
                        icon: Icons.history_edu_outlined,
                        title: 'Dal 2023',
                        subtitle: 'Scarico più ampio delle pagine ufficiali',
                        onTap: () {
                          if (!sync.running) ref.read(superenalottoSyncProvider.notifier).syncMonths();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton(
                    onPressed: () => context.push('/more/info'),
                    child: const Text('Avvertenze e informazioni →'),
                  ),
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
