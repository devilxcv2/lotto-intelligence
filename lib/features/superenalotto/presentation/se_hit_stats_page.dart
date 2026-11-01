// lib/features/superenalotto/presentation/se_hit_stats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/settings/app_settings.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../data/se_ticket_repository.dart';
import '../data/superenalotto_repository.dart';
import '../domain/se_hit_stats.dart';
import 'se_chrome.dart';
import 'se_studio_page.dart';

const _lookback = 12;

final _seHitStatsProvider = FutureProvider<SeHitStatsReport>((ref) async {
  final tickets = await ref.watch(seTicketsProvider.future);
  final history = await ref.watch(superenalottoHistoryProvider.future);
  return buildSeHitStats(
    tickets: tickets,
    historyChronological: history,
    lookbackDraws: _lookback,
  );
});

class SeHitStatsPage extends ConsumerWidget {
  const SeHitStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(_seHitStatsProvider);

    return Scaffold(
      backgroundColor: SeColors.cream,
      appBar: AppBar(
        backgroundColor: SeColors.forest,
        foregroundColor: Colors.white,
        title: const Text('Numeri SuperEnalotto'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(_seHitStatsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AsyncBody<SeHitStatsReport>(
              value: report,
              onRetry: () => ref.invalidate(_seHitStatsProvider),
              data: (data) {
                if (data.numbers.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Quando una schedina SE prende una categoria (o SuperStar), qui vedi quali numeri '
                        'hanno contribuito e come sono ricomparsi nelle ultime uscite.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: SeColors.forest),
                        onPressed: () => context.push('/tickets/quick'),
                        icon: const Icon(Icons.add),
                        label: const Text('Crea schedina SE'),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Text(
                      '${data.categoryTicketCount} schedine con categoria. '
                      'Ultime ${data.lookbackDraws} estrazioni SE.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stime in euro da quote medie Sisal (studio). Non prevedono il prossimo concorso.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (data.topNumbers.length >= 6) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(foregroundColor: SeColors.forest),
                        onPressed: () => context.push(seStudioRoute(numbers: data.topNumbers.take(6).toList())),
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Apri studio con i top 6'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    for (final stat in data.numbers) _SeNumberCard(stat: stat),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SeNumberCard extends StatelessWidget {
  const _SeNumberCard({required this.stat});

  final SeHitNumberStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: stat.estimatedCents > 0 ? SeColors.gold.withValues(alpha: 0.55) : const Color(0xFFC5D9C0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NumberBalls(numbers: [stat.number], gold: true, compact: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${stat.categoryTickets} categorie'
                  '${stat.estimatedCents > 0 ? ' · stima ${formatEuro(stat.estimatedCents)}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: SeColors.forest),
                ),
              ),
              TextButton(
                onPressed: () => context.push(seStudioRoute(numbers: [stat.number])),
                child: const Text('Studio'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (stat.asMainHits > 0) _chip('Nei sei ×${stat.asMainHits}'),
              if (stat.asJolly > 0) _chip('Jolly ×${stat.asJolly}'),
              if (stat.asSuperstar > 0) _chip('SuperStar ×${stat.asSuperstar}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            stat.recentTotal == 0 ? 'Nelle ultime uscite: non ricomparso.' : 'Ultime uscite',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          if (stat.recentTotal > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (stat.recentMain > 0) _chip('Sei ×${stat.recentMain}'),
                if (stat.recentJolly > 0) _chip('Jolly ×${stat.recentJolly}'),
                if (stat.recentSuperstar > 0) _chip('SuperStar ×${stat.recentSuperstar}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SeColors.forest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: SeColors.forest)),
    );
  }
}
