// lib/features/discovery/presentation/discovery_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/hypergeometric.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../../virtual_wallet/presentation/wallet_pages.dart';
import '../domain/trend_search.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  var _weeks = 4;
  var _busy = false;
  String? _error;
  TrendReport? _report;

  Future<void> _search() async {
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = await ref.read(wheelDrawsProvider(wheel).future);
    if (!mounted) return;
    if (draws.length < 30) {
      setState(() {
        _report = null;
        _error = 'Servono almeno 30 estrazioni in archivio su questa ruota.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final report = await searchTrendsInBackground(
        draws: draws,
        weeks: _weeks,
        seed: 42,
        weekday: nextOpenDrawDate(DateTime.now()).weekday,
      );
      if (!mounted) return;
      setState(() => _report = report);
    } catch (error) {
      if (mounted) setState(() => _error = 'Ricerca non riuscita: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final name = wheelByCode(wheel)?.name ?? wheel;
    final report = _report;
    return PageScaffold(
      title: 'Ricerca trend',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ruota: $name. Il cursore è il numero di settimane da leggere nell\'archivio.'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('2'),
                    Expanded(
                      child: Slider(
                        value: _weeks.toDouble(),
                        min: 2,
                        max: 12,
                        divisions: 10,
                        label: '$_weeks settimane',
                        onChanged: _busy ? null : (value) => setState(() => _weeks = value.round()),
                      ),
                    ),
                    const Text('12'),
                  ],
                ),
                Text('$_weeks settimane · circa ${_weeks * drawsPerWeek} estrazioni per blocco.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _busy ? null : _search,
                  icon: const Icon(Icons.manage_search),
                  label: Text(_busy ? 'Leggo l\'archivio…' : 'Cerca algoritmi nel database'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          if (report != null) ...[
            const SizedBox(height: 16),
            _Trends(report: report),
            const SizedBox(height: 16),
            _Rules(report: report),
            if (report.selected != null) ...[
              const SizedBox(height: 16),
              _Proposal(rule: report.selected!, wheel: wheel),
            ],
            if (report.system != null) ...[
              const SizedBox(height: 16),
              _SystemCard(system: report.system!, wheel: wheel),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(report.limitation, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}

class _Trends extends StatelessWidget {
  const _Trends({required this.report});

  final TrendReport report;

  @override
  Widget build(BuildContext context) {
    final shown = report.trends.take(12).toList();
    final fair = (singleNumberProbability * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultsBanner('Cosa è cambiato nelle ultime ${report.weeks} settimane'),
        OrangeTable(
          headers: const ['N', 'Ora', 'Prima', 'Δ', 'Oss.', 'Equa'],
          rows: [
            for (final trend in shown)
              [
                '${trend.number}',
                '${trend.recentHits}',
                '${trend.previousHits}',
                '${trend.slope > 0 ? '+' : ''}${trend.slope}',
                '${(trend.observedRate * 100).toStringAsFixed(0)}%',
                '$fair%',
              ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Ora e Prima sono le uscite nel blocco recente e in quello precedente. '
            'Oss. è la quota di estrazioni del blocco recente in cui il numero c\'è; Equa è sempre $fair% (5 su 90). '
            '${shown.where((t) => !t.compatibleWithFair).length} di questi 12 escono dall\'intervallo di Wilson: '
            'con 90 numeri e poche settimane è l\'esito normale, non un segnale.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Rules extends StatelessWidget {
  const _Rules({required this.report});

  final TrendReport report;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Algoritmi provati sulle ultime ${report.rules.first.scoredDraws} estrazioni', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Teoria ${report.expectedMeanHits.toStringAsFixed(3)} centri a estrazione. '
            'Baseline casuale ${report.baselineMeanHits.toStringAsFixed(3)}. '
            'La prima riga è quella con la media più alta in questo elenco: per questo va letta con sospetto.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < report.rules.length; i++)
            _RuleTile(rule: report.rules[i], selected: i == 0, expected: report.expectedMeanHits),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule, required this.selected, required this.expected});

  final TriedRule rule;
  final bool selected;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final delta = rule.meanHits - expected;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.banner : AppColors.line, width: selected ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rule.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: 4),
            Text(rule.how, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Media ${rule.meanHits.toStringAsFixed(3)} centri '
              '(${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(3)} sulla teoria, '
              '${rule.zScore.toStringAsFixed(1)} errori standard).',
            ),
          ],
        ),
      ),
    );
  }
}

class _Proposal extends StatelessWidget {
  const _Proposal({required this.rule, required this.wheel});

  final TriedRule rule;
  final String wheel;

  @override
  Widget build(BuildContext context) {
    final atLeast = fairChanceOfAtLeastOneHit(rule.proposal.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResultsBanner('Ipotesi per il prossimo concorso'),
          const SizedBox(height: 12),
          Text(rule.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          NumberBalls(numbers: rule.proposal),
          const SizedBox(height: 8),
          Text(
            'Probabilità equa di almeno un centro: ${(atLeast * 100).toStringAsFixed(1)}%. '
            'Centri attesi: ${(rule.proposal.length * singleNumberProbability).toStringAsFixed(2)}. '
            'Ogni singolo numero resta al ${(singleNumberProbability * 100).toStringAsFixed(2)}%, trend compreso.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(newTicketRoute(numbers: rule.proposal, wheel: wheel)),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Registra come schedina ipotetica'),
          ),
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.system, required this.wheel});

  final DiscoveredSystem system;
  final String wheel;

  @override
  Widget build(BuildContext context) {
    final preview = system.columns.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResultsBanner('Sistemone di studio sul pronostico'),
          const SizedBox(height: 8),
          Text('15 numeri scelti dalla regola in testa, sviluppati in un ridotto: ${system.columns.length} colonne da 5.'),
          const SizedBox(height: 4),
          Text(system.coverageClaim),
          const SizedBox(height: 4),
          Text(
            system.guaranteeVerified ? 'Garanzia ricontrollata su tutti i casi.' : 'Garanzia non verificata.',
            style: TextStyle(fontWeight: FontWeight.w700, color: system.guaranteeVerified ? AppColors.wheel : null),
          ),
          const SizedBox(height: 8),
          Text('Pronostico: ${system.pool.join(' · ')}', style: const TextStyle(color: AppColors.numberBlue, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (var i = 0; i < preview.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${i + 1}.  ${preview[i].join('   ')}'),
            ),
          if (system.columns.length > preview.length)
            Text('… e altre ${system.columns.length - preview.length} colonne.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            'Il ridotto copre combinazioni del pronostico. Non alza la probabilità che quei 15 numeri escano.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (preview.isNotEmpty)
            OutlinedButton(
              onPressed: () => context.push(newTicketRoute(numbers: preview.first, wheel: wheel)),
              child: const Text('Schedina con la prima colonna'),
            ),
        ],
      ),
    );
  }
}
