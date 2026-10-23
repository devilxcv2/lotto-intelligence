// lib/features/dashboard/presentation/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/background/evening_sync.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../features/virtual_wallet/data/wallet_repository.dart';
import '../../../features/virtual_wallet/presentation/wallet_pages.dart';
import '../../../features/backtesting/data/backtest_repository.dart';
import '../../../features/draws/data/archive_sync.dart';
import '../../../features/draws/data/draw_repository.dart';
import '../../../features/draws/presentation/draws_pages.dart';
import '../../../features/statistics/data/statistics_providers.dart';
import '../../../features/statistics/domain/statistics_engine.dart';
import '../../../features/systems/data/strategy_repository.dart';
import '../../../shared/widgets/common_widgets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(archiveSummaryProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    final wheel = settings?.selectedWheelCode ?? 'BA';
    final draws = ref.watch(wheelDrawsProvider(wheel));
    final strategies = ref.watch(strategiesProvider);
    final backtests = ref.watch(backtestsProvider);
    return PageScaffold(
      title: 'Lotto Intelligence',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          AsyncBody<ArchiveSummary>(
            value: summary,
            onRetry: () => ref.invalidate(archiveSummaryProvider),
            data: (data) => _SummaryCard(summary: data),
          ),
          const SizedBox(height: 16),
          const _StudyCard(),
          const SizedBox(height: 16),
          const SectionCard(title: 'Ruota', child: WheelSelector()),
          const SizedBox(height: 16),
          AsyncBody<List<ArchivedDraw>>(
            value: draws,
            onRetry: () => ref.invalidate(wheelDrawsProvider(wheel)),
            data: (items) => _WheelPreview(wheel: wheel, draws: items),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _LinkTile(label: 'Laboratorio sistemi', detail: 'Combinazioni e filtri', onTap: () => context.go('/lab/systems')),
              _LinkTile(label: 'AI Lab', detail: 'Motori locali e provider opzionali', onTap: () => context.go('/lab/ai')),
              _LinkTile(
                label: 'Strategie salvate',
                detail: '${strategies.value?.length ?? 0}',
                onTap: () => context.go('/lab/strategies'),
              ),
              _LinkTile(
                label: 'Simulazioni',
                detail: '${backtests.value?.length ?? 0} report',
                onTap: () => context.go('/lab/reports'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.summary});

  final ArchiveSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(archiveSyncProvider);
    return SectionCard(
      title: 'Archivio',
      trailing: Text(freshnessLabel(summary.freshness)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.latestDate == null ? 'Nessuna estrazione in archivio.' : 'Ultima data: ${formatItalianDate(summary.latestDate!)}'),
          const SizedBox(height: 4),
          Text('${summary.drawCount} cinquine locali. Il numero di concorso non è nel file ufficiale.'),
          const SizedBox(height: 4),
          const Text('Le righe non sono marcate come ufficialmente verificate: manca un confronto con una seconda fonte.'),
          if (summary.httpLastModified != null) Text('Ultima modifica dichiarata dal file: ${summary.httpLastModified}'),
          if (summary.lastError != null) Text(summary.lastError!),
          if (sync.message != null) ...[
            const SizedBox(height: 8),
            Text(sync.message!),
            if (sync.running) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: sync.progress == 0 ? null : sync.progress),
            ],
          ],
          if (sync.error != null) Text(sync.error!),
          if (sync.report != null)
            Text('Inserite ${sync.report!.inserted}, duplicati ${sync.report!.duplicates}, conflitti ${sync.report!.conflicts}, non valide ${sync.report!.invalid}.'),
          if (sync.evaluatedTickets.isNotEmpty)
            Text(
              'Schedine confrontate con le nuove estrazioni: ${sync.evaluatedTickets.length}, netto simulato '
              '${formatEuro(sync.evaluatedTickets.fold<int>(0, (sum, t) => sum + (t.evaluation?.netCents ?? 0)))}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: sync.running ? null : () => ref.read(archiveSyncProvider.notifier).syncOfficial(),
                child: const Text('Aggiorna archivio'),
              ),
              if (sync.running)
                OutlinedButton(onPressed: () => ref.read(archiveSyncProvider.notifier).cancel(), child: const Text('Annulla')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stato dello studio in tempo reale: prossimo concorso, schedine in attesa,
/// ultimo esito e saldo simulato.
class _StudyCard extends ConsumerWidget {
  const _StudyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider).value;
    final tickets = ref.watch(ticketsProvider).value ?? const <StoredTicket>[];
    final settings = ref.watch(settingsControllerProvider).value;
    final now = DateTime.now();
    final next = nextOpenDrawDate(now);
    final check = EveningSync.nextCheckTime(now);
    final lastEvaluated = tickets.where((t) => t.evaluation != null && !t.isLegacy).toList()
      ..sort((a, b) => b.evaluation!.evaluatedAt.compareTo(a.evaluation!.evaluatedAt));
    final balance = summary?.balanceCents ?? 0;
    final balanceColor = balance > 0 ? AppColors.gold : (balance < 0 ? Theme.of(context).colorScheme.error : null);
    return SectionCard(
      title: 'Studio in tempo reale',
      trailing: summary == null
          ? null
          : Text(
              '${balance > 0 ? '+' : ''}${formatEuro(balance)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: balanceColor, fontWeight: FontWeight.w700),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prossimo concorso: ${formatItalianDate(next)}. '
              'Raccolta fino alle $salesCloseHour:${salesCloseMinute.toString().padLeft(2, '0')}; '
              'risultati tipici verso le $typicalResultsHour:${typicalResultsMinute.toString().padLeft(2, '0')} (non subito). '
              '${(settings?.liveSyncEnabled ?? true) ? 'ZIP automatico dalle ${check.hour}:${check.minute.toString().padLeft(2, '0')} del ${formatItalianDate(check)}.' : 'Aggiornamento serale spento: attivalo in Impostazioni.'}'),
          const SizedBox(height: 6),
          if (summary != null)
            Text('${summary.openCount} schedine in attesa (${formatEuro(summary.openStakeCents)}), ${summary.evaluatedCount} valutate, '
                'giocato ${formatEuro(summary.stakedCents)}, netto ${formatEuro(summary.netCents)}.'),
          if (lastEvaluated.isNotEmpty) ...[
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final last = lastEvaluated.first;
              final result = last.evaluation!;
              return Text(
                'Ultimo esito (${result.drawDate == null ? '—' : formatItalianDate(result.drawDate!)}, ${last.coversAllWheels ? 'tutte' : last.wheelCode}): '
                '${result.hits} centri, netto ${formatEuro(result.netCents)} su ${formatEuro(last.stakeCents)}.',
              );
            }),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.go('/tickets'),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Schedine'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(newTicketRoute(wheel: settings?.selectedWheelCode)),
                icon: const Icon(Icons.add),
                label: const Text('Nuova schedina'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/lab/zoppe'),
                icon: const Icon(Icons.hub_outlined),
                label: const Text('Sistemone Zoppe'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/more/wallet'),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Portafoglio'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/more/statistics'),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Statistiche'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(drawsGameProvider.notifier).state = 1;
                  context.go('/draws');
                },
                icon: const Icon(Icons.stars_outlined),
                label: const Text('SuperEnalotto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelPreview extends ConsumerWidget {
  const _WheelPreview({required this.wheel, required this.draws});

  final String wheel;
  final List<ArchivedDraw> draws;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (draws.isEmpty) {
      return SectionCard(
        title: wheelByCode(wheel)?.name ?? wheel,
        child: const Text('Nessuna cinquina per questa ruota. Dopo l\'importazione compariranno numeri, frequenze e ritardi.'),
      );
    }
    final latest = draws.last;
    final statistics = ref.watch(wheelStatisticsProvider((wheel: wheel, window: null)));
    return SectionCard(
      title: '${wheelByCode(wheel)?.name ?? wheel} · ${formatItalianDate(latest.date)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberBalls(numbers: latest.numbers),
          const SizedBox(height: 12),
          Text('${draws.length} estrazioni in archivio per questa ruota.'),
          const SizedBox(height: 8),
          switch (statistics) {
            AsyncData(:final value?) => _rankings(value),
            AsyncError(:final error) => Text('Statistiche non disponibili: $error'),
            _ => const LinearProgressIndicator(),
          },
          const SizedBox(height: 8),
          const Text('Queste classifiche descrivono la finestra archiviata. Non indicano il prossimo estratto.'),
        ],
      ),
    );
  }

  Widget _rankings(WheelStatistics stats) {
    final delays = [...stats.numbers]..sort((a, b) => b.currentDelay.compareTo(a.currentDelay));
    final frequent = [...stats.numbers]..sort((a, b) => b.absoluteFrequency.compareTo(a.absoluteFrequency));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ritardi correnti più lunghi: ${delays.take(3).map((item) => '${item.number} (${item.currentDelay})').join(', ')}.'),
        Text('Frequenze più alte: ${frequent.take(3).map((item) => '${item.number} (${item.absoluteFrequency})').join(', ')}.'),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.label, required this.detail, required this.onTap});

  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(detail),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
