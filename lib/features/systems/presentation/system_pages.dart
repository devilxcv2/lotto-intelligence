// lib/features/systems/presentation/system_pages.dart

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/isolates/background_job.dart';
import '../../../core/lotto/hypergeometric.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../statistics/data/statistics_providers.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../superenalotto/presentation/se_studio_page.dart';
import '../../virtual_wallet/presentation/wallet_pages.dart';
import '../data/strategy_repository.dart';
import '../domain/combinations.dart';
import '../domain/system_request.dart';

/// Oltre questa soglia la strategia salva solo i parametri: integrale e
/// generatori con seed rigenerano le stesse colonne.
const int _maxStoredColumns = 20000;

class LabHubPage extends StatelessWidget {
  const LabHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Laboratorio',
      child: ListView(
        children: [
          _link(context, '/lab/systems', 'System builder', 'Integrali, ridotti verificati, casuali, filtri'),
          _link(context, '/lab/strategies', 'Strategie salvate', 'Configurazioni conservate in locale'),
          _link(context, '/lab/ai', 'AI Lab', 'Baseline, pesi descrittivi, filtri, modelli opzionali'),
          _link(context, '/lab/models', 'Modelli AI', 'Endpoint, timeout, prova di connessione'),
          _link(context, '/lab/discovery', 'Ricerca trend', 'Settimane, probabilità e sistemone di studio'),
          _link(context, '/lab/zoppe', 'Sistemone Zoppe', 'Suggerimenti a cinque gambe · anche da Nuova schedina'),
          _link(context, '/lab/backtest', 'Backtesting', 'Walk-forward senza dati futuri'),
          _link(context, '/lab/reports', 'Report', 'Simulazioni salvate ed esportabili'),
        ],
      ),
    );
  }

  Widget _link(BuildContext context, String path, String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(path),
    );
  }
}

class SystemBuilderPage extends ConsumerStatefulWidget {
  const SystemBuilderPage({super.key});

  @override
  ConsumerState<SystemBuilderPage> createState() => _SystemBuilderPageState();
}

class _SystemBuilderPageState extends ConsumerState<SystemBuilderPage> {
  final _selected = <int>{};
  final _name = TextEditingController(text: 'Sistema di studio');
  final _paste = TextEditingController();
  var _mode = GenerationMode.integral;
  var _columnSize = 5;
  var _count = 50;
  var _assumed = 3;
  var _guaranteed = 2;
  var _quickCount = 15;
  var _seed = 42;
  var _filtersOn = false;
  late RangeValues _even = _evenBounds;
  late RangeValues _sum = _sumBounds;
  var _maxConsecutive = maxColumnSize;
  var _maxPerDecade = maxColumnSize;

  BackgroundJob<GenerationResult>? _job;
  StreamSubscription<double>? _progressSub;
  final _clock = Stopwatch();
  double _progress = 0;
  GenerationResult? _result;
  SystemRequest? _resultRequest;
  String? _message;

  RangeValues get _evenBounds => RangeValues(0, _columnSize.toDouble());
  RangeValues get _sumBounds => RangeValues(
        (_columnSize * (_columnSize + 1) / 2).toDouble(),
        (_columnSize * (181 - _columnSize) / 2).toDouble(),
      );

  @override
  void dispose() {
    _job?.cancel();
    _progressSub?.cancel();
    _name.dispose();
    _paste.dispose();
    super.dispose();
  }

  CombinationFilter get _filter {
    if (!_filtersOn || _mode == GenerationMode.reduced) return const CombinationFilter();
    return CombinationFilter(
      minEven: _even.start.round(),
      maxEven: _even.end.round(),
      minSum: _sum.start.round(),
      maxSum: _sum.end.round(),
      maxConsecutiveRun: _maxConsecutive,
      maxPerDecade: _maxPerDecade,
    );
  }

  SystemRequest get _request => SystemRequest(
        mode: _mode,
        pool: (_selected.toList()..sort()),
        combinationSize: _columnSize,
        filter: _filter,
        count: _count,
        assumedHits: _assumed,
        guaranteedHits: min(_guaranteed, min(_assumed, _columnSize)),
        seed: _seed,
      );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value ?? AppSettings.initial;
    final wheel = settings.selectedWheelCode;
    final running = _job != null;
    return PageScaffold(
      title: 'System builder',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 12),
          Text('Ruota di contesto: ${wheelByCode(wheel)?.name ?? wheel}. Le colonne sono di studio, nessuna giocata viene inviata.'),
          const SizedBox(height: 8),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome strategia')),
          const SizedBox(height: 16),
          SegmentedButton<GenerationMode>(
            segments: const [
              ButtonSegment(value: GenerationMode.integral, label: Text('Integrale'), icon: Icon(Icons.all_inclusive)),
              ButtonSegment(value: GenerationMode.reduced, label: Text('Ridotto'), icon: Icon(Icons.verified_outlined)),
              ButtonSegment(value: GenerationMode.parametric, label: Text('Casuale'), icon: Icon(Icons.casino_outlined)),
            ],
            selected: {_mode},
            onSelectionChanged: running ? null : (value) => setState(() => _mode = value.first),
          ),
          const SizedBox(height: 16),
          _ColumnSizePicker(
            value: _columnSize,
            enabled: !running,
            onChanged: (value) => setState(() {
              _columnSize = value;
              _even = _evenBounds;
              _sum = _sumBounds;
              _maxConsecutive = maxColumnSize;
              _maxPerDecade = maxColumnSize;
            }),
          ),
          if (_mode == GenerationMode.reduced) _reducedControls(),
          if (_mode == GenerationMode.parametric) _countControl(),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Pronostico · ${_selected.length} numeri',
            trailing: TextButton(onPressed: running ? null : () => setState(_selected.clear), child: const Text('Svuota')),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberGrid(selected: _selected, enabled: !running, onToggle: _toggle),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: running
                      ? null
                      : () {
                          final mask = (_selected.toList()..sort()).join(',');
                          context.push(mask.isEmpty ? '/lab/zoppe' : '/lab/zoppe?mask=$mask');
                        },
                  icon: const Icon(Icons.contrast),
                  label: const Text('Sistemone Zoppe su questa maschera'),
                ),
                const SizedBox(height: 12),
                _quickFill(wheel),
              ],
            ),
          ),
          if (_mode != GenerationMode.reduced) ...[
            const SizedBox(height: 12),
            _filters(),
          ],
          const SizedBox(height: 12),
          _EstimateCard(request: _request, unitCostCents: settings.unitCostCents),
          const SizedBox(height: 12),
          if (running) _progressCard() else FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.play_arrow), label: const Text('Genera')),
          if (_message != null) ...[const SizedBox(height: 12), Text(_message!)],
          if (_result != null && _resultRequest != null) ...[
            const SizedBox(height: 16),
            _ResultView(
              result: _result!,
              request: _resultRequest!,
              unitCostCents: settings.unitCostCents,
              onSave: _save,
              onExportCsv: _exportCsv,
              onExportJson: _exportJson,
              onTicket: () => _ticket(settings),
              onSuperTicket: () {
                final row = _result?.combinations.firstOrNull;
                if (row == null) return;
                context.push(seStudioRoute(numbers: row));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _reducedControls() {
    final maxGuarantee = min(_assumed, _columnSize);
    final guarantee = min(_guaranteed, maxGuarantee);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Se almeno $_assumed dei 5 estratti sono nel pronostico…'),
          Slider(
            value: _assumed.toDouble(),
            min: 2,
            max: 5,
            divisions: 3,
            label: '$_assumed',
            onChanged: _job != null ? null : (value) => setState(() => _assumed = value.round()),
          ),
          Text('…almeno una colonna ne contiene $guarantee (${_sorte(guarantee)}).'),
          if (maxGuarantee > 2)
            Slider(
              value: guarantee.toDouble(),
              min: 2,
              max: maxGuarantee.toDouble(),
              divisions: maxGuarantee - 2,
              label: '$guarantee',
              onChanged: _job != null ? null : (value) => setState(() => _guaranteed = value.round()),
            ),
          Row(
            children: [
              Expanded(child: Text('Seed della costruzione: $_seed')),
              IconButton(
                tooltip: 'Nuovo seed',
                onPressed: _job != null ? null : () => setState(() => _seed = Random().nextInt(1 << 31)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Text('Il ridotto non usa filtri: un filtro romperebbe la garanzia. Seed diversi possono dare un numero di colonne diverso.'),
        ],
      ),
    );
  }

  Widget _countControl() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Text('Colonne'),
          Expanded(
            child: Slider(
              value: log(_count) / ln10,
              min: 0,
              max: 4,
              label: '$_count',
              onChanged: _job != null ? null : (value) => setState(() => _count = pow(10, value).round().clamp(1, 10000)),
            ),
          ),
          SizedBox(width: 56, child: Text('$_count', textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _quickFill(String wheel) {
    final statistics = ref.watch(wheelStatisticsProvider((wheel: wheel, window: null))).value;
    final disabled = _job != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Riempimento rapido: $_quickCount numeri'),
            Expanded(
              child: Slider(
                value: _quickCount.toDouble(),
                min: 5,
                max: 40,
                divisions: 35,
                label: '$_quickCount',
                onChanged: disabled ? null : (value) => setState(() => _quickCount = value.round()),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: disabled ? null : () => _fill(sampleUniform(_quickCount, Random())),
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Casuali'),
            ),
            OutlinedButton.icon(
              onPressed: disabled || statistics == null ? null : () => _fill(_top(statistics, byDelay: false)),
              icon: const Icon(Icons.trending_up),
              label: const Text('Più frequenti'),
            ),
            OutlinedButton.icon(
              onPressed: disabled || statistics == null ? null : () => _fill(_top(statistics, byDelay: true)),
              icon: const Icon(Icons.hourglass_bottom),
              label: const Text('Più ritardatari'),
            ),
          ],
        ),
        if (statistics == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Frequenti e ritardatari si attivano quando la ruota ha estrazioni in archivio.'),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Frequenza e ritardo descrivono il passato della ruota: non rendono un numero più probabile.'),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _paste,
                enabled: !disabled,
                decoration: const InputDecoration(labelText: 'Incolla numeri (es. 5 12 33 47)'),
              ),
            ),
            IconButton(tooltip: 'Usa questi numeri', onPressed: disabled ? null : _usePasted, icon: const Icon(Icons.check)),
          ],
        ),
      ],
    );
  }

  Widget _filters() {
    final evenBounds = _evenBounds;
    final sumBounds = _sumBounds;
    return Card(
      child: ExpansionTile(
        title: const Text('Filtri'),
        subtitle: Text(_filtersOn ? 'Attivi: le colonne scartate non sono coperte' : 'Spenti'),
        children: [
          SwitchListTile(
            title: const Text('Applica i filtri'),
            value: _filtersOn,
            onChanged: _job != null ? null : (value) => setState(() => _filtersOn = value),
          ),
          if (_filtersOn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Numeri pari per colonna: ${_even.start.round()}–${_even.end.round()}'),
                  RangeSlider(
                    values: _even,
                    min: evenBounds.start,
                    max: evenBounds.end,
                    divisions: _columnSize,
                    onChanged: (value) => setState(() => _even = value),
                  ),
                  Text('Somma: ${_sum.start.round()}–${_sum.end.round()}'),
                  RangeSlider(
                    values: _sum,
                    min: sumBounds.start,
                    max: sumBounds.end,
                    onChanged: (value) => setState(() => _sum = value),
                  ),
                  Text('Consecutivi al massimo: ${_maxConsecutive >= _columnSize ? 'nessun limite' : _maxConsecutive}'),
                  Slider(
                    value: min(_maxConsecutive, _columnSize).toDouble(),
                    min: 1,
                    max: _columnSize.toDouble(),
                    divisions: _columnSize - 1,
                    onChanged: (value) => setState(() => _maxConsecutive = value.round() >= _columnSize ? maxColumnSize : value.round()),
                  ),
                  Text('Numeri della stessa decina al massimo: ${_maxPerDecade >= _columnSize ? 'nessun limite' : _maxPerDecade}'),
                  Slider(
                    value: min(_maxPerDecade, _columnSize).toDouble(),
                    min: 1,
                    max: _columnSize.toDouble(),
                    divisions: _columnSize - 1,
                    onChanged: (value) => setState(() => _maxPerDecade = value.round() >= _columnSize ? maxColumnSize : value.round()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    final elapsed = _clock.elapsed;
    final remaining = _progress <= 0.02 ? null : Duration(milliseconds: (elapsed.inMilliseconds * (1 - _progress) / _progress).round());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calcolo in corso · ${(_progress * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress == 0 ? null : _progress),
            const SizedBox(height: 8),
            Text('Trascorsi ${_duration(elapsed)}${remaining == null ? '' : ' · mancano circa ${_duration(remaining)}'}. Puoi cambiare scheda; tornando indietro da questa pagina il calcolo si ferma.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => _job?.cancel(), icon: const Icon(Icons.stop), label: const Text('Annulla')),
          ],
        ),
      ),
    );
  }

  void _toggle(int number) {
    setState(() {
      if (!_selected.remove(number)) _selected.add(number);
    });
  }

  void _fill(Iterable<int> numbers) {
    setState(() {
      _selected
        ..clear()
        ..addAll(numbers);
    });
  }

  List<int> _top(WheelStatistics stats, {required bool byDelay}) {
    final ranked = [...stats.numbers]
      ..sort((a, b) => byDelay ? b.currentDelay.compareTo(a.currentDelay) : b.absoluteFrequency.compareTo(a.absoluteFrequency));
    return [for (final item in ranked.take(_quickCount)) item.number];
  }

  void _usePasted() {
    final numbers = _paste.text.split(RegExp(r'[^0-9]+')).map(int.tryParse).whereType<int>().where((n) => n >= 1 && n <= 90).toSet();
    if (numbers.isEmpty) {
      setState(() => _message = 'Nessun numero fra 1 e 90 nel testo.');
      return;
    }
    _fill(numbers);
    setState(() => _message = 'Pronostico impostato con ${numbers.length} numeri.');
  }

  Future<void> _generate() async {
    if (_selected.length < _columnSize) {
      setState(() => _message = 'Servono almeno $_columnSize numeri nel pronostico.');
      return;
    }
    final request = _request;
    if (request.mode == GenerationMode.reduced) {
      final problem = reducedParametersProblem(
        poolSize: request.pool.length,
        combinationSize: request.combinationSize,
        assumedHits: request.assumedHits,
        guaranteedHits: request.guaranteedHits,
      );
      if (problem != null) {
        setState(() => _message = problem);
        return;
      }
    }
    setState(() {
      _message = null;
      _result = null;
      _progress = 0;
    });
    final job = await startSystemJob(request);
    if (!mounted) {
      job.cancel();
      return;
    }
    _clock
      ..reset()
      ..start();
    setState(() => _job = job);
    _progressSub = job.progress.listen((value) {
      if (mounted) setState(() => _progress = value);
    });
    try {
      final result = await job.result;
      if (mounted) {
        setState(() {
          _result = result;
          _resultRequest = request;
        });
      }
    } on JobCancelled {
      if (mounted) setState(() => _message = 'Generazione annullata.');
    } catch (error) {
      if (mounted) setState(() => _message = 'Generazione non riuscita: $error');
    } finally {
      _clock.stop();
      await _progressSub?.cancel();
      _progressSub = null;
      if (mounted) setState(() => _job = null);
    }
  }

  Future<void> _save() async {
    final result = _result;
    final request = _resultRequest;
    if (result == null || request == null) return;
    final settings = ref.read(settingsControllerProvider).value ?? AppSettings.initial;
    final stored = result.combinations.length <= _maxStoredColumns;
    final columnsJson = stored ? await _encodeColumns(result.combinations) : null;
    await ref.read(strategyRepositoryProvider).save(
          name: _name.text.trim().isEmpty ? 'Sistema di studio' : _name.text.trim(),
          kind: request.mode.name,
          wheelCode: settings.selectedWheelCode,
          notes: '${result.combinations.length} colonne da ${request.combinationSize}. ${result.coverageClaim}',
          parameters: {
            ...request.toParameters(),
            'columns_count': '${result.combinations.length}',
            'coverage': result.coverageClaim,
            'guarantee_verified': '${result.guaranteeVerified}',
            'combinations': ?columnsJson,
          },
        );
    ref.invalidate(strategiesProvider);
    if (mounted) {
      setState(() => _message = stored
          ? 'Strategia salvata in locale con tutte le colonne.'
          : 'Strategia salvata con i parametri: oltre $_maxStoredColumns colonne si rigenera dagli stessi parametri e dallo stesso seed.');
    }
  }

  Future<void> _exportCsv() async {
    final result = _result;
    final request = _resultRequest;
    if (result == null || request == null) return;
    final bytes = await _csvBytes(result.combinations, request.combinationSize);
    await FilePicker.saveFile(fileName: 'sistema.csv', bytes: bytes, mimeType: 'text/csv');
  }

  Future<void> _exportJson() async {
    final result = _result;
    final request = _resultRequest;
    if (result == null || request == null) return;
    final bytes = await _jsonBytes(result, request);
    await FilePicker.saveFile(fileName: 'sistema.json', bytes: bytes, mimeType: 'application/json');
  }

  void _ticket(AppSettings settings) {
    final row = _result?.combinations.firstOrNull;
    if (row == null) return;
    // La prima colonna passa alla pagina della schedina: lì si scelgono
    // sorti e poste entro i tetti simulati.
    context.push(newTicketRoute(numbers: row, wheel: settings.selectedWheelCode));
  }
}

String _sorte(int hits) => switch (hits) {
      2 => 'ambo',
      3 => 'terno',
      4 => 'quaterna',
      5 => 'cinquina',
      _ => '$hits numeri',
    };

String _duration(Duration value) {
  if (value.inHours > 0) return '${value.inHours} h ${value.inMinutes % 60} min';
  if (value.inMinutes > 0) return '${value.inMinutes} min ${value.inSeconds % 60} s';
  return '${value.inSeconds} s';
}

String _bytes(int value) {
  if (value >= 1 << 20) return '${(value / (1 << 20)).toStringAsFixed(1)} MB';
  if (value >= 1 << 10) return '${(value / (1 << 10)).toStringAsFixed(0)} KB';
  return '$value B';
}

// Serializzazioni grandi fuori dal thread dell'interfaccia; funzioni
// top-level perché la closura inviata all'isolate catturi solo i dati.
Future<String> _encodeColumns(List<List<int>> columns) => Isolate.run(() => jsonEncode(columns));

Future<Uint8List> _csvBytes(List<List<int>> columns, int size) {
  return Isolate.run(() {
    final csv = StringBuffer('${[for (var i = 1; i <= size; i++) 'n$i'].join(',')}\n');
    for (final row in columns) {
      csv.writeln(row.join(','));
    }
    return Uint8List.fromList(utf8.encode(csv.toString()));
  });
}

Future<Uint8List> _jsonBytes(GenerationResult result, SystemRequest request) {
  final columns = result.combinations;
  final meta = <String, Object?>{
    'schema': 'lotto-intelligence.system/v1',
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'parameters': request.toParameters(),
    'columns_count': columns.length,
    'complete': result.complete,
    'guarantee_verified': result.guaranteeVerified,
    'coverage': result.coverageClaim,
    'note': 'Colonne di studio. Nessuna probabilità di vincita è aumentata dalla scelta del sistema.',
  };
  return Isolate.run(() => Uint8List.fromList(utf8.encode(jsonEncode({...meta, 'columns': columns}))));
}

class _ColumnSizePicker extends StatelessWidget {
  const _ColumnSizePicker({required this.value, required this.enabled, required this.onChanged});

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Numeri per colonna: $value${value <= 5 ? ' (${_sorte(value)})' : ''}'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var size = minColumnSize; size <= maxColumnSize; size++)
              ChoiceChip(
                label: Text('$size'),
                selected: size == value,
                onSelected: enabled ? (_) => onChanged(size) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({required this.selected, required this.enabled, required this.onToggle});

  final Set<int> selected;
  final bool enabled;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 90,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;
        final on = selected.contains(number);
        return Semantics(
          button: true,
          selected: on,
          label: 'Numero $number',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? () => onToggle(number) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    '$number',
                    style: TextStyle(fontWeight: FontWeight.w600, color: on ? scheme.onPrimary : scheme.onSurface),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.request, required this.unitCostCents});

  final SystemRequest request;
  final int unitCostCents;

  @override
  Widget build(BuildContext context) {
    final v = request.pool.length;
    final k = request.combinationSize;
    final estimate = estimateCombinations(poolSize: v, combinationSize: k);
    final lines = <String>[];
    if (v < k) {
      lines.add('Seleziona almeno $k numeri.');
    } else {
      switch (request.mode) {
        case GenerationMode.integral:
          final total = estimate.total;
          lines.add('Integrale: $total colonne da $k.');
          if (total <= BigInt.from(maxReturnedCombinations)) {
            final columns = total.toInt();
            lines.add('Costo ipotetico ${formatEuro(hypotheticalCostCents(columns, unitCostCents))}, memoria stimata ${_bytes(estimate.bytesFor(columns))}.');
          } else if (request.filter.isNeutral) {
            lines.add('Oltre il limite di $maxReturnedCombinations colonne. Riduci il pronostico, attiva i filtri o usa un ridotto.');
          } else if (estimate.canScan) {
            lines.add('Con i filtri si esaminano $total colonne e se ne tengono al massimo $maxReturnedCombinations.');
          } else {
            lines.add('Oltre il limite di scansione di $maxScannedCombinations combinazioni.');
          }
        case GenerationMode.parametric:
          lines.add('Casuale: fino a ${request.count} colonne distinte da $k, costo ipotetico ${formatEuro(hypotheticalCostCents(request.count, unitCostCents))}.');
        case GenerationMode.reduced:
          final problem = reducedParametersProblem(
            poolSize: v,
            combinationSize: k,
            assumedHits: request.assumedHits,
            guaranteedHits: request.guaranteedHits,
          );
          if (problem != null) {
            lines.add(problem);
          } else {
            lines.add('Ridotto: casi da coprire e poi verificare ${binomial(v, request.assumedHits)}. L\'integrale equivalente avrebbe ${estimate.total} colonne.');
            lines.add('Il numero di colonne si conosce alla fine della costruzione.');
          }
      }
    }
    return SectionCard(
      title: 'Stima prima di generare',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line)],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.request,
    required this.unitCostCents,
    required this.onSave,
    required this.onExportCsv,
    required this.onExportJson,
    required this.onTicket,
    required this.onSuperTicket,
  });

  final GenerationResult result;
  final SystemRequest request;
  final int unitCostCents;
  final VoidCallback onSave;
  final VoidCallback onExportCsv;
  final VoidCallback onExportJson;
  final VoidCallback onTicket;
  final VoidCallback onSuperTicket;

  @override
  Widget build(BuildContext context) {
    final columns = result.combinations;
    final usage = <int, int>{};
    for (final row in columns) {
      for (final number in row) {
        usage[number] = (usage[number] ?? 0) + 1;
      }
    }
    final counts = usage.values.toList()..sort();
    final empty = columns.isEmpty;
    return SectionCard(
      title: '${columns.length} colonne da ${request.combinationSize}',
      trailing: result.guaranteeVerified
          ? Chip(
              avatar: const Icon(Icons.verified, color: AppColors.gold, size: 18),
              label: const Text('Garanzia verificata'),
              side: const BorderSide(color: AppColors.gold),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.coverageClaim),
          const SizedBox(height: 8),
          Text('Costo ipotetico ${formatEuro(hypotheticalCostCents(columns.length, unitCostCents))} a ${formatEuro(unitCostCents)} per colonna.'),
          if (counts.isNotEmpty) Text('Ogni numero usato compare in ${counts.first}–${counts.last} colonne.'),
          const SizedBox(height: 12),
          if (!empty)
            SizedBox(
              height: min(400, columns.length * 40.0 + 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Scrollbar(
                  child: ListView.builder(
                    itemExtent: 40,
                    itemCount: columns.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          SizedBox(width: 64, child: Text('${index + 1}', style: Theme.of(context).textTheme.bodySmall)),
                          Expanded(child: Text(columns[index].join(' · '), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: empty ? null : onSave, child: const Text('Salva strategia')),
              OutlinedButton(onPressed: empty ? null : onExportCsv, child: const Text('CSV')),
              OutlinedButton(onPressed: empty ? null : onExportJson, child: const Text('JSON')),
              OutlinedButton(
                onPressed: empty || request.combinationSize != 5 ? null : onTicket,
                child: const Text('Schedina Lotto'),
              ),
              OutlinedButton(
                onPressed: empty || request.combinationSize != 6 ? null : onSuperTicket,
                child: const Text('Schedina SuperEnalotto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StrategiesPage extends ConsumerWidget {
  const StrategiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(strategiesProvider);
    return PageScaffold(
      title: 'Strategie salvate',
      child: AsyncBody<List<SavedStrategy>>(
        value: strategies,
        onRetry: () => ref.invalidate(strategiesProvider),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Nessuna strategia salvata.'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.kind} · ${item.wheelCode} · ${formatItalianDate(item.createdAt)}\n${item.notes ?? ''}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
