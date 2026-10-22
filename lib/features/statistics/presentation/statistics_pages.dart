// lib/features/statistics/presentation/statistics_pages.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/hypergeometric.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../features/draws/data/draw_repository.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../data/statistics_providers.dart';
import '../domain/statistics_engine.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int? _window = 100;

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final key = (wheel: wheel, window: _window);
    final statistics = ref.watch(wheelStatisticsProvider(key));
    return PageScaffold(
      title: 'Statistiche',
      actions: [
        IconButton(tooltip: 'Heatmap', onPressed: () => context.push('/statistics/heatmap'), icon: const Icon(Icons.grid_on)),
        IconButton(tooltip: 'Avanzate', onPressed: () => context.push('/statistics/advanced'), icon: const Icon(Icons.functions)),
        IconButton(tooltip: 'Coppie', onPressed: () => context.push('/statistics/pairs'), icon: const Icon(Icons.join_inner)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 12),
          const WheelSelector(),
          const SizedBox(height: 12),
          WindowPicker(value: _window, onChanged: (value) => setState(() => _window = value)),
          const SizedBox(height: 12),
          AsyncBody<WheelStatistics?>(
            value: statistics,
            onRetry: () => ref.invalidate(wheelStatisticsProvider(key)),
            data: (stats) {
              if (stats == null) return const Text('Nessuna estrazione in archivio per questa ruota.');
              final byDelay = [...stats.numbers]..sort((a, b) => b.currentDelay.compareTo(a.currentDelay));
              final byFreq = [...stats.numbers]..sort((a, b) => b.absoluteFrequency.compareTo(a.absoluteFrequency));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${wheelByCode(wheel)?.name} · ${stats.drawCount} estrazioni nella finestra.'),
                  const SizedBox(height: 8),
                  Text('Probabilità teorica di un numero, se l\'estrazione è equa: ${(singleNumberProbability * 100).toStringAsFixed(2)}% a ogni concorso, indipendentemente dal passato.'),
                  const SizedBox(height: 16),
                  const ResultsBanner('Top 10 ritardatari'),
                  const SizedBox(height: 0),
                  OrangeTable(
                    headers: const ['Numero', 'Ritardo', 'Massimo', 'Uscite'],
                    rows: [
                      for (final stat in byDelay.take(10)) ['${stat.number}', '${stat.currentDelay}', '${stat.maxDelay}', '${stat.absoluteFrequency}'],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Il ritardo descrive quante estrazioni sono passate dall\'ultima uscita. Non alza la probabilità della prossima.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  const ResultsBanner('Frequenze più alte'),
                  OrangeTable(
                    headers: const ['Numero', 'Uscite', 'Quota', 'Wilson'],
                    rows: [
                      for (final stat in byFreq.take(10))
                        [
                          '${stat.number}',
                          '${stat.absoluteFrequency}',
                          '${(stat.relativeFrequency * 100).toStringAsFixed(1)}%',
                          '${(stat.wilsonLow * 100).toStringAsFixed(0)}–${(stat.wilsonHigh * 100).toStringAsFixed(0)}%',
                        ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    byFreq.take(10).any((stat) => !stat.compatibleWithFairDraw)
                        ? 'Qualche frequenza della finestra esce dall\'intervallo di Wilson attorno a 5/90. Resta una descrizione del passato.'
                        : 'Queste frequenze restano compatibili con un\'estrazione equa 5/90.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class HeatmapPage extends ConsumerWidget {
  const HeatmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final key = (wheel: wheel, window: null);
    return PageScaffold(
      title: 'Heatmap',
      child: AsyncBody<WheelStatistics?>(
        value: ref.watch(wheelStatisticsProvider(key)),
        onRetry: () => ref.invalidate(wheelStatisticsProvider(key)),
        data: (stats) {
          if (stats == null) return const Center(child: Text('Archivio vuoto.'));
          final maxDelay = stats.numbers.fold<int>(1, (max, item) => item.currentDelay > max ? item.currentDelay : max);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: 90,
            itemBuilder: (context, index) {
              final stat = stats.statOf(index + 1);
              final tone = stat.currentDelay / maxDelay;
              return Tooltip(
                message: '${stat.number}: ritardo ${stat.currentDelay}, uscite ${stat.absoluteFrequency}',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(const Color(0xFFE7F0FA), AppColors.banner, tone),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text('${stat.number}', style: const TextStyle(fontSize: 12))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdvancedStatisticsPage extends ConsumerStatefulWidget {
  const AdvancedStatisticsPage({super.key});

  @override
  ConsumerState<AdvancedStatisticsPage> createState() => _AdvancedStatisticsPageState();
}

class _AdvancedStatisticsPageState extends ConsumerState<AdvancedStatisticsPage> {
  final _first = TextEditingController(text: '1');
  final _second = TextEditingController(text: '2');

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = ref.watch(wheelDrawsProvider(wheel)).value ?? const <ArchivedDraw>[];
    final key = (wheel: wheel, window: null);
    return PageScaffold(
      title: 'Statistiche avanzate',
      child: AsyncBody<WheelStatistics?>(
        value: ref.watch(wheelStatisticsProvider(key)),
        onRetry: () => ref.invalidate(wheelStatisticsProvider(key)),
        data: (stats) {
          if (stats == null) return const Center(child: Text('Archivio vuoto.'));
          final items = draws;
          final a = int.tryParse(_first.text) ?? 1;
          final b = int.tryParse(_second.text) ?? 2;
          final correlation = pearsonPresence(items, a, b);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const DisclaimerBanner(),
              const SizedBox(height: 12),
              Text('Somma media ${stats.sumMean.toStringAsFixed(2)} (attesa teorica ${expectedSumOfFive.toStringAsFixed(1)}). Min ${stats.sumMin}, max ${stats.sumMax}.'),
              Text('Estrazioni con almeno due consecutivi: ${stats.drawsWithConsecutive} su ${stats.drawCount}.'),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                    barGroups: [
                      for (var i = 0; i <= 5; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: stats.evenHistogram[i].toDouble(), width: 14, color: Theme.of(context).colorScheme.primary),
                        ]),
                    ],
                  ),
                ),
              ),
              const Text('Barre: quante estrazioni hanno 0–5 numeri pari. Il confronto con l\'ipergeometrica è nel testo sotto.'),
              for (var i = 0; i <= 5; i++)
                Text('$i pari: osservati ${stats.evenHistogram[i]}, attesi ${stats.expectedEvenHistogram[i].toStringAsFixed(1)}.'),
              const SizedBox(height: 12),
              const Text('Decine 1-10 … 81-90'),
              Text(stats.decadeCounts.join(' · ')),
              const SizedBox(height: 8),
              const Text('Cifre finali 0-9'),
              Text(stats.finalDigitCounts.join(' · ')),
              const SizedBox(height: 12),
              const Text('Correlazione di Pearson fra due presenze. Confrontare molte coppie fa emergere valori estremi anche per caso.'),
              Row(
                children: [
                  Expanded(child: TextField(controller: _first, decoration: const InputDecoration(labelText: 'Numero A'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _second, decoration: const InputDecoration(labelText: 'Numero B'), keyboardType: TextInputType.number)),
                  IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.calculate)),
                ],
              ),
              Text(correlation == null ? 'Servono almeno tre estrazioni e due numeri diversi.' : 'Pearson = ${correlation.toStringAsFixed(3)}.'),
            ],
          );
        },
      ),
    );
  }
}

class PairsPage extends ConsumerWidget {
  const PairsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final key = (wheel: wheel, window: null);
    return PageScaffold(
      title: 'Coppie',
      child: AsyncBody<WheelStatistics?>(
        value: ref.watch(wheelStatisticsProvider(key)),
        onRetry: () => ref.invalidate(wheelStatisticsProvider(key)),
        data: (stats) {
          if (stats == null) return const Center(child: Text('Archivio vuoto.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Le coppie in cima sono scelte dopo aver visto i dati. Non sono una scoperta confermata: fra migliaia di coppie possibili, qualcuna risulta più frequente per caso.'),
              const SizedBox(height: 8),
              Text('Attese per una coppia specifica, in questa finestra: ${stats.expectedPairCount.toStringAsFixed(2)}.'),
              const SizedBox(height: 12),
              for (final pair in stats.topPairs)
                Text('${pair.a}-${pair.b}: ${pair.count} osservazioni, attese ${pair.expected.toStringAsFixed(2)}.'),
            ],
          );
        },
      ),
    );
  }
}
