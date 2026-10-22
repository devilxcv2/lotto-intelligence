// lib/features/backtesting/presentation/backtest_pages.dart

import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../virtual_wallet/presentation/wallet_pages.dart';
import '../data/backtest_repository.dart';
import '../domain/backtest_engine.dart';
import '../domain/study_strategies.dart';

const String _fixedChoice = 'fixed';

class BacktestPage extends ConsumerStatefulWidget {
  const BacktestPage({super.key});

  @override
  ConsumerState<BacktestPage> createState() => _BacktestPageState();
}

class _BacktestPageState extends ConsumerState<BacktestPage> {
  int? _window = 100;
  var _seed = 42;
  var _runs = 30;
  var _choice = 'frequency-top';
  var _methodWindow = defaultStrategyWindow;
  final _numbers = TextEditingController(text: '1 2 3 4 5');
  BacktestReport? _report;
  List<int>? _nextProposal;
  List<StrategyComparisonRow>? _comparison;
  String? _message;
  var _busy = false;

  @override
  void dispose() {
    _numbers.dispose();
    super.dispose();
  }

  StrategyInfo? get _info => strategyInfoById(_choice);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value ?? AppSettings.initial;
    final wheel = settings.selectedWheelCode;
    final info = _info;
    return PageScaffold(
      title: 'Backtesting',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 12),
          Text('Ruota ${wheelByCode(wheel)?.name ?? wheel}. Il metodo vede solo le estrazioni precedenti a quella valutata. Le estrazioni prima della finestra servono da riscaldamento e non entrano nel punteggio.'),
          const SizedBox(height: 8),
          const Text('Concorsi valutati'),
          WindowPicker(value: _window, onChanged: (value) => setState(() => _window = value)),
          const SizedBox(height: 12),
          DropdownMenu<String>(
            initialSelection: _choice,
            label: const Text('Metodo'),
            expandedInsets: EdgeInsets.zero,
            onSelected: _busy ? null : (value) => setState(() => _choice = value ?? _choice),
            dropdownMenuEntries: [
              for (final item in studyStrategyCatalog) DropdownMenuEntry(value: item.id, label: item.name),
              const DropdownMenuEntry(value: _fixedChoice, label: 'Cinquina fissa'),
            ],
          ),
          const SizedBox(height: 8),
          Text(info?.description ?? 'Sempre gli stessi 5 numeri, scritti sotto.'),
          if (_choice == _fixedChoice)
            TextField(controller: _numbers, decoration: const InputDecoration(labelText: 'Cinque numeri separati da spazio')),
          if (info?.usesWindow == true) ...[
            Text('Finestra del metodo: ultime $_methodWindow estrazioni'),
            Slider(
              value: _methodWindow.toDouble(),
              min: 10,
              max: 500,
              divisions: 49,
              label: '$_methodWindow',
              onChanged: _busy ? null : (value) => setState(() => _methodWindow = value.round()),
            ),
          ],
          Text('Seed $_seed'),
          Slider(value: _seed.toDouble(), min: 1, max: 999, divisions: 100, onChanged: (value) => setState(() => _seed = value.round())),
          Text('Simulazioni casuali $_runs'),
          Slider(value: _runs.toDouble(), min: 0, max: 100, divisions: 20, onChanged: (value) => setState(() => _runs = value.round())),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _busy ? null : _run, child: const Text('Esegui simulazione')),
              OutlinedButton(onPressed: _busy ? null : _compareAll, child: const Text('Confronta tutti i metodi')),
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator()),
          if (_message != null) Text(_message!),
          if (_report != null) _ReportBody(report: _report!, onSave: _save, onExport: _export),
          if (_report != null && _nextProposal != null) _NextProposal(numbers: _nextProposal!, report: _report!, onTicket: () => _ticket(settings)),
          if (_comparison != null) _ComparisonTable(rows: _comparison!),
        ],
      ),
    );
  }

  StudyStrategy? _buildStrategy() {
    if (_choice == _fixedChoice) {
      final numbers = _numbers.text.split(RegExp(r'[\s,]+')).map(int.tryParse).whereType<int>().toList();
      if (numbers.length != 5 || numbers.toSet().length != 5 || numbers.any((n) => n < 1 || n > 90)) {
        setState(() => _message = 'Servono 5 numeri distinti fra 1 e 90.');
        return null;
      }
      return FixedNumbersStrategy(numbers);
    }
    return _info?.build(_methodWindow);
  }

  Future<List<ArchivedDraw>?> _loadDraws() async {
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = await ref.read(drawRepositoryProvider).loadWheel(wheel);
    if (draws.isEmpty) {
      setState(() => _message = 'Servono estrazioni archiviate.');
      return null;
    }
    return draws;
  }

  int _scoreFrom(int length) {
    final window = _window;
    return window == null || window >= length ? 0 : length - window;
  }

  Future<void> _run() async {
    final strategy = _buildStrategy();
    if (strategy == null) return;
    setState(() {
      _busy = true;
      _message = null;
      _comparison = null;
    });
    final draws = await _loadDraws();
    if (draws == null) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _message = 'Simulazione in corso su ${draws.length} estrazioni. Puoi usare il resto dell\'app.');
    try {
      final report = await runBacktestInBackground(
        draws: draws,
        strategy: strategy,
        seed: _seed,
        scoreFromIndex: _scoreFrom(draws.length),
        monteCarloRuns: _runs,
      );
      // La proposta per il concorso successivo usa tutta la storia disponibile:
      // è la stessa funzione valutata nel backtest, applicata a oggi.
      final next = strategy.propose(historyBefore: draws, contestIndex: draws.length, seed: _seed);
      if (!mounted) return;
      setState(() {
        _report = report;
        _nextProposal = next;
        _message = null;
      });
    } catch (error) {
      if (mounted) setState(() => _message = 'Simulazione non riuscita: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _compareAll() async {
    setState(() {
      _busy = true;
      _message = null;
      _report = null;
      _nextProposal = null;
    });
    final draws = await _loadDraws();
    if (draws == null) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _message = 'Confronto di ${studyStrategyCatalog.length} metodi in corso. Puoi usare il resto dell\'app.');
    try {
      final rows = await _compareInBackground(draws, _seed, _scoreFrom(draws.length), _methodWindow);
      if (!mounted) return;
      setState(() {
        _comparison = rows;
        _message = null;
      });
    } catch (error) {
      if (mounted) setState(() => _message = 'Confronto non riuscito: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _ticket(AppSettings settings) {
    final numbers = _nextProposal;
    if (numbers == null || numbers.isEmpty) return;
    // La posta per sorte si sceglie nella pagina della schedina, con i tetti.
    context.push(newTicketRoute(numbers: numbers, wheel: settings.selectedWheelCode));
  }

  Future<void> _save() async {
    final report = _report;
    if (report == null) return;
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final id = await ref.read(backtestRepositoryProvider).save(
          label: '${_info?.name ?? report.strategyId} · $wheel',
          wheelCode: wheel,
          seed: _seed,
          report: report,
        );
    ref.invalidate(backtestsProvider);
    setState(() => _message = 'Report $id salvato.');
  }

  Future<void> _export(String kind) async {
    final report = _report;
    if (report == null) return;
    if (kind == 'json') {
      await FilePicker.saveFile(
        fileName: 'backtest.json',
        bytes: Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(report.toJson()))),
        mimeType: 'application/json',
      );
      return;
    }
    if (kind == 'csv') {
      await FilePicker.saveFile(
        fileName: 'backtest.csv',
        bytes: Uint8List.fromList(utf8.encode(reportCsv(report))),
        mimeType: 'text/csv',
      );
      return;
    }
    final body = StringBuffer()
      ..writeln('Simulazione storica, non una garanzia futura.')
      ..writeln('Metodo: ${_info?.name ?? report.strategyId}')
      ..writeln('Estrazioni valutate: ${report.scoredDraws}')
      ..writeln('Riscaldamento: ${report.warmupDraws}')
      ..writeln('Media centri strategia: ${report.strategyMeanHits.toStringAsFixed(3)}')
      ..writeln('Media centri baseline: ${report.baselineMeanHits.toStringAsFixed(3)}')
      ..writeln('Media teorica: ${report.expectedMeanHits.toStringAsFixed(3)}')
      ..writeln(report.limitation);
    final bytes = await reportPdf(title: 'Report backtest', body: body.toString());
    await FilePicker.saveFile(fileName: 'backtest.pdf', bytes: bytes, mimeType: 'application/pdf');
  }
}

// Top-level: la closura inviata all'isolate non deve catturare lo State.
Future<List<StrategyComparisonRow>> _compareInBackground(List<ArchivedDraw> draws, int seed, int scoreFrom, int window) {
  return Isolate.run(() => compareStrategies(draws: draws, seed: seed, scoreFromIndex: scoreFrom, window: window));
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.onSave, required this.onExport});

  final BacktestReport report;
  final VoidCallback onSave;
  final void Function(String kind) onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Valutate ${report.scoredDraws} estrazioni, riscaldamento ${report.warmupDraws}.'),
        Text('Media centri strategia ${report.strategyMeanHits.toStringAsFixed(3)}, baseline ${report.baselineMeanHits.toStringAsFixed(3)}, teoria ${report.expectedMeanHits.toStringAsFixed(3)}.'),
        Text('Estrazioni con almeno un centro: ${report.drawsWithAtLeastOneHit}.'),
        const SizedBox(height: 8),
        for (var hits = 0; hits <= 5; hits++)
          Text('$hits centri: strategia ${report.strategyHistogram[hits]}, baseline ${report.baselineHistogram[hits]}, attesi ${report.expectedHistogram[hits].toStringAsFixed(1)}.'),
        const SizedBox(height: 8),
        Text(
          'Monte Carlo: ${report.monteCarlo.runs} simulazioni, media centri totali ${report.monteCarlo.meanTotalHits.toStringAsFixed(1)}. '
          'Simulazioni con almeno i centri della strategia: ${report.monteCarlo.runsAtLeastStrategy}. È un rango sul campione, non un valore p.',
        ),
        const SizedBox(height: 8),
        Text(report.limitation),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: onSave, child: const Text('Salva report')),
            OutlinedButton(onPressed: () => onExport('json'), child: const Text('JSON')),
            OutlinedButton(onPressed: () => onExport('csv'), child: const Text('CSV')),
            OutlinedButton(onPressed: () => onExport('pdf'), child: const Text('PDF')),
          ],
        ),
      ],
    );
  }
}

class _NextProposal extends StatelessWidget {
  const _NextProposal({required this.numbers, required this.report, required this.onTicket});

  final List<int> numbers;
  final BacktestReport report;
  final VoidCallback onTicket;

  @override
  Widget build(BuildContext context) {
    final delta = report.strategyMeanHits - report.expectedMeanHits;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SectionCard(
        title: 'Cosa proporrebbe oggi questo metodo',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberBalls(numbers: numbers),
            const SizedBox(height: 12),
            Text(
              'Stessa funzione del backtest applicata a tutta la storia della ruota. Nel periodo valutato ha fatto in media '
              '${report.strategyMeanHits.toStringAsFixed(3)} centri per concorso contro ${report.expectedMeanHits.toStringAsFixed(3)} teorici '
              '(${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(3)}). Il passato non cambia la probabilità del prossimo concorso: '
              'ogni cinquina ha la stessa.',
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onTicket, child: const Text('Registra come schedina ipotetica')),
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.rows});

  final List<StrategyComparisonRow> rows;

  @override
  Widget build(BuildContext context) {
    final expected = rows.isEmpty ? 0.0 : rows.first.report.expectedMeanHits;
    final scored = rows.isEmpty ? 0 : rows.first.report.scoredDraws;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SectionCard(
        title: 'Confronto fra metodi · $scored concorsi',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media teorica per concorso ${expected.toStringAsFixed(3)} centri. Stessi concorsi e stesso seed per tutti.'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Metodo')),
                  DataColumn(label: Text('Media centri'), numeric: true),
                  DataColumn(label: Text('Vs teoria'), numeric: true),
                  DataColumn(label: Text('≥1 centro'), numeric: true),
                  DataColumn(label: Text('Ambo+'), numeric: true),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(cells: [
                      DataCell(Text(row.info.name)),
                      DataCell(Text(row.report.strategyMeanHits.toStringAsFixed(3))),
                      DataCell(Text(_signed(row.report.strategyMeanHits - row.report.expectedMeanHits))),
                      DataCell(Text('${row.report.drawsWithAtLeastOneHit}')),
                      DataCell(Text('${_atLeast(row.report.strategyHistogram, 2)}')),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(multipleComparisonWarning(rows.length)),
          ],
        ),
      ),
    );
  }

  static String _signed(double value) => '${value >= 0 ? '+' : ''}${value.toStringAsFixed(3)}';

  static int _atLeast(List<int> histogram, int hits) {
    var total = 0;
    for (var i = hits; i < histogram.length; i++) {
      total += histogram[i];
    }
    return total;
  }
}

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(backtestsProvider);
    return PageScaffold(
      title: 'Report',
      child: AsyncBody<List<StoredBacktest>>(
        value: reports,
        onRetry: () => ref.invalidate(backtestsProvider),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Nessun report salvato.'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.label),
                subtitle: Text(formatItalianDate(item.createdAt)),
                onTap: () => context.push('/lab/reports/${item.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class ReportDetailPage extends ConsumerWidget {
  const ReportDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(_reportProvider(id));
    return PageScaffold(
      title: 'Report $id',
      child: AsyncBody<StoredBacktest?>(
        value: report,
        onRetry: () => ref.invalidate(_reportProvider(id)),
        data: (item) {
          if (item == null) return const Center(child: Text('Report non trovato.'));
          final json = const JsonEncoder.withIndent('  ').convert(jsonDecode(item.summaryJson));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(item.label),
              const SizedBox(height: 12),
              SelectableText(json),
            ],
          );
        },
      ),
    );
  }
}

final _reportProvider = FutureProvider.family<StoredBacktest?, int>((ref, id) {
  return ref.watch(backtestRepositoryProvider).find(id);
});
