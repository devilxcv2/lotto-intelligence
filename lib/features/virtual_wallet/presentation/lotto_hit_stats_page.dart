// lib/features/virtual_wallet/presentation/lotto_hit_stats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../data/wallet_repository.dart';
import '../domain/lotto_hit_stats.dart';
import 'wallet_pages.dart';

const _drawDays = 12;

final _lottoHitStatsProvider = FutureProvider<LottoHitStatsReport>((ref) async {
  final tickets = await ref.watch(ticketsProvider.future);
  final numbers = <int>{
    for (final t in tickets)
      if (t.evaluation != null)
        ...t.evaluation!.hitNumbers,
  };
  final recent = await ref.read(drawRepositoryProvider).recentNumberAppearances(
        numbers: numbers,
        drawDays: _drawDays,
      );
  return buildLottoHitStats(tickets: tickets, recent: recent, drawDays: _drawDays);
});

class LottoHitStatsPage extends ConsumerWidget {
  const LottoHitStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(_lottoHitStatsProvider);
    final settings = ref.watch(settingsControllerProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Numeri Lotto'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            onPressed: () => ref.invalidate(_lottoHitStatsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AsyncBody<LottoHitStatsReport>(
              value: report,
              onRetry: () => ref.invalidate(_lottoHitStatsProvider),
              data: (data) {
                if (data.numbers.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Quando una schedina Lotto prende qualcosa, qui vedi i numeri che hanno centrato '
                        'e su quali ruote sono usciti di recente.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.push('/tickets/quick'),
                        icon: const Icon(Icons.add),
                        label: const Text('Crea una schedina'),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Text(
                      '${data.payingTicketCount} schedine in utile. '
                      'Ultime ${data.drawDays} date di estrazione nell\'archivio.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Studio descrittivo: non aumenta le probabilità del prossimo concorso.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (data.topNumbers.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => context.push(
                          newTicketRoute(
                            numbers: data.topNumbers.take(5).toList(),
                            wheel: settings?.selectedWheelCode,
                          ),
                        ),
                        icon: const Icon(Icons.playlist_add),
                        label: Text('Nuova Lotto con i top ${data.topNumbers.take(5).length}'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    for (final stat in data.numbers) _NumberCard(stat: stat),
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

class _NumberCard extends StatelessWidget {
  const _NumberCard({required this.stat});

  final LottoHitNumberStat stat;

  @override
  Widget build(BuildContext context) {
    final wheelBits = stat.recentByWheel.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final played = stat.playedWheels.entries.map((e) {
      final name = e.key == 'TUTTE' ? 'Tutte' : (wheelByCode(e.key)?.name ?? e.key);
      return '$name ×${e.value}';
    }).join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NumberBalls(numbers: [stat.number], hits: {stat.number}, compact: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stat.payingTickets > 0
                        ? '${stat.payingTickets} vincite · netto ${formatEuro(stat.netCents)}'
                        : '${stat.hitTickets} centri (senza euro)',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                ),
              ],
            ),
            if (played.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nelle tue schedine: $played', style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Text(
              wheelBits.isEmpty
                  ? 'Nelle ultime uscite: non ricomparso.'
                  : 'Ultime uscite: ${wheelBits.map((e) => '${wheelByCode(e.key)?.name ?? e.key} ×${e.value}').join(' · ')}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (stat.recentAppearances.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                [
                  for (final row in stat.recentAppearances.take(6))
                    '${formatItalianDate(row.date)} ${wheelByCode(row.wheelCode)?.name ?? row.wheelCode}',
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(newTicketRoute(numbers: [stat.number])),
                child: const Text('Usa in nuova'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
