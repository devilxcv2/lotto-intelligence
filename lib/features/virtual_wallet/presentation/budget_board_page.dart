// lib/features/virtual_wallet/presentation/budget_board_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../superenalotto/data/se_ticket_repository.dart';
import '../../superenalotto/domain/superenalotto_studio.dart';
import '../data/wallet_repository.dart';
import '../domain/study_review.dart';

/// Scheda dedicata: credito, budget, vincite e perché le giocate (Zoppe ecc.) non hanno “funzionato”.
class BudgetBoardPage extends ConsumerWidget {
  const BudgetBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider);
    final tickets = ref.watch(ticketsProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    final seTickets = ref.watch(seTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AsyncBody<WalletSummary>(
              value: summary,
              onRetry: () => ref.invalidate(walletSummaryProvider),
              data: (data) {
                final credit = settings == null
                    ? data.balanceCents
                    : simulatedCreditCents(settings: settings, summary: data);
                final methods = scoreByMethod(tickets.value ?? const []);
                final lessons = lessonsFromTickets(tickets.value ?? const []);
                final seLines = seAutoTrendLines([
                  for (final t in seTickets.value ?? const <SeTicket>[]) (origin: t.origin, match: t.match),
                ]);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Text(
                      'Soldi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            fontFamily: 'serif',
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Budget, credito e vincite simulate. Sotto: cosa hanno centrato Zoppe e le altre strategie.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    _CreditHero(
                      creditCents: credit,
                      balanceCents: data.balanceCents,
                      settings: settings,
                      summary: data,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Vincite',
                            value: '${data.winningTickets}',
                            hint: 'schedine in utile',
                            highlight: data.winningTickets > 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniStat(
                            label: 'Netto',
                            value: formatEuro(data.netCents),
                            hint: 'dopo ritenuta 8%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniStat(
                            label: 'Giocato',
                            value: formatEuro(data.stakedCents),
                            hint: '${data.evaluatedCount} valutate',
                          ),
                        ),
                      ],
                    ),
                    if (settings != null) ...[
                      const SizedBox(height: 12),
                      _BudgetStrip(settings: settings, summary: data),
                    ],
                    const SizedBox(height: 20),
                    ResultsBanner('Per metodo: chi ha reso (o no)'),
                    const SizedBox(height: 8),
                    if (methods.isEmpty)
                      const Text('Ancora nessuna schedina Lotto valutata. Dopo un concorso vedi qui Zoppe, Auto, mirate…')
                    else
                      for (final method in methods) _MethodTile(score: method),
                    const SizedBox(height: 20),
                    ResultsBanner('Perché non ha centrato (o sì)'),
                    const SizedBox(height: 8),
                    const Text(
                      'Il sistemone e i ritardi non “sbagliano” la probabilità: ogni numero resta 5 su 90. '
                      'Qui vedi centri, numeri fuori e il saldo di ogni giocata.',
                      style: TextStyle(height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    if (lessons.isEmpty)
                      const Text('Quando chiudi delle schedine, compare qui la lettura didattica.')
                    else
                      for (final lesson in lessons) _LessonCard(lesson: lesson),
                    const SizedBox(height: 20),
                    ResultsBanner('SuperEnalotto · trend Auto'),
                    const SizedBox(height: 8),
                    for (final line in seLines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(line, style: Theme.of(context).textTheme.bodySmall),
                      ),
                    const SizedBox(height: 16),
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
                          onPressed: () => context.push('/more/wallet'),
                          icon: const Icon(Icons.tune),
                          label: const Text('Limiti budget'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/more/se/tickets'),
                          icon: const Icon(Icons.stars_outlined),
                          label: const Text('Catalogo SE'),
                        ),
                      ],
                    ),
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

class _CreditHero extends StatelessWidget {
  const _CreditHero({
    required this.creditCents,
    required this.balanceCents,
    required this.settings,
    required this.summary,
  });

  final int creditCents;
  final int balanceCents;
  final AppSettings? settings;
  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = creditCents >= 0 ? AppColors.navy : Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4E8C), Color(0xFF2F6EAD), Color(0xFFF0A01A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Credito simulato', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            formatEuro(creditCents),
            style: TextStyle(color: color == AppColors.navy ? Colors.white : const Color(0xFFFFCDD2), fontSize: 34, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Saldo schedine valutate: ${balanceCents >= 0 ? '+' : ''}${formatEuro(balanceCents)}'
            '${summary.openStakeCents > 0 ? ' · in attesa ${formatEuro(summary.openStakeCents)}' : ''}',
            style: const TextStyle(color: Colors.white70),
          ),
          if (settings != null) ...[
            const SizedBox(height: 4),
            Text(
              'Capitale di partenza ${formatEuro(settings!.virtualCapitalCents)} · ${settings!.budgetMode.label}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.hint, this.highlight = false});

  final String label;
  final String value;
  final String hint;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? AppColors.banner.withValues(alpha: 0.18) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.navy)),
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BudgetStrip extends StatelessWidget {
  const _BudgetStrip({required this.settings, required this.summary});

  final AppSettings settings;
  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!settings.budgetMode.enforcesLimits) {
      return Card(
        child: ListTile(
          title: Text(settings.budgetMode.label),
          subtitle: Text(settings.budgetMode.hint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/more/wallet'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget con limiti', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Concorso max ${formatEuro(settings.contestBudgetCents)} · mese ${formatEuro(settings.monthlyBudgetCents)}'),
            Text('In attesa ora: ${formatEuro(summary.openStakeCents)}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => context.push('/more/wallet'), child: const Text('Modifica')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.score});

  final MethodScore score;

  @override
  Widget build(BuildContext context) {
    final bal = score.balanceCents;
    final color = bal > 0 ? AppColors.gold : (bal < 0 ? Theme.of(context).colorScheme.error : AppColors.ink);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(score.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${score.tickets} schedine · ${score.wins} vincite · media ${score.avgHits.toStringAsFixed(1)} centri',
        ),
        trailing: Text(
          '${bal >= 0 ? '+' : ''}${formatEuro(bal)}',
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final TicketLesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/tickets/${lesson.ticketId}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
              const SizedBox(height: 4),
              Text(lesson.headline, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (lesson.hitNumbers.isNotEmpty) ...[
                NumberBalls(numbers: lesson.hitNumbers, hits: lesson.hitNumbers.toSet(), compact: true),
                const SizedBox(height: 6),
              ],
              Text(lesson.body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
