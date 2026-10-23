// lib/features/superenalotto/presentation/se_studio_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../systems/domain/combinations.dart';
import '../data/se_ticket_repository.dart';
import '../data/superenalotto_repository.dart';
import '../domain/superenalotto_studio.dart';
import 'se_chrome.dart';

String seStudioRoute({List<int>? numbers}) {
  if (numbers == null || numbers.isEmpty) return '/more/se/studio';
  return '/more/se/studio?numbers=${numbers.join(',')}';
}

class SeStudioPage extends ConsumerStatefulWidget {
  const SeStudioPage({this.initialNumbers = const [], super.key});

  final List<int> initialNumbers;

  @override
  ConsumerState<SeStudioPage> createState() => _SeStudioPageState();
}

class _SeStudioPageState extends ConsumerState<SeStudioPage> {
  late final Set<int> _selected = {...widget.initialNumbers.where((number) => number >= 1 && number <= 90)};
  final _superstar = TextEditingController();
  var _systemMode = false;
  var _origin = 'manuale';
  String? _message;
  GenerationResult? _system;

  @override
  void initState() {
    super.initState();
    if (_selected.length > 6) _systemMode = true;
  }

  @override
  void dispose() {
    _superstar.dispose();
    super.dispose();
  }

  int? get _star {
    final text = _superstar.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  void _toggle(int number) {
    setState(() {
      _origin = 'manuale';
      _system = null;
      _message = null;
      if (!_selected.remove(number)) {
        final cap = _systemMode ? 18 : 6;
        if (_selected.length >= cap) {
          _message = _systemMode ? 'Il sistemone qui accetta fino a 18 numeri.' : 'La schedina ha 6 numeri. Per svilupparne di più usa Sistemone.';
          return;
        }
        _selected.add(number);
      }
    });
  }

  Future<void> _save(List<int> numbers, {String? origin}) async {
    final text = _superstar.text.trim();
    if (!_systemMode && text.isNotEmpty && int.tryParse(text) == null) {
      setState(() => _message = 'La SuperStar è un numero fra 1 e 90, oppure si lascia vuota.');
      return;
    }
    final star = _systemMode ? null : _star;
    final problem = seTicketProblem(numbers, superstar: star);
    if (problem != null) {
      setState(() => _message = problem);
      return;
    }
    try {
      await ref.read(seTicketRepositoryProvider).add(numbers: numbers, superstar: star, origin: origin ?? _origin);
      ref.invalidate(seTicketsProvider);
      if (!mounted) return;
      final when = formatItalianDate(nextOpenDrawDate(DateTime.now()));
      setState(() => _message = 'Schedina registrata per il $when. La trovi nel catalogo SuperEnalotto (categoria, non euro).');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrata per il $when'),
          action: SnackBarAction(label: 'Catalogo', onPressed: () => context.push('/more/se/tickets')),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    }
  }

  void _develop() {
    final pool = _selected.toList()..sort();
    if (pool.length < 7) {
      setState(() => _message = 'Per il sistemone servono almeno 7 numeri. La schedina singola ne usa 6.');
      return;
    }
    final result = generateReduced(pool: pool, combinationSize: 6, assumedHits: 3, guaranteedHits: 2, seed: 42);
    setState(() {
      _system = result;
      _message = result.combinations.isEmpty ? result.coverageClaim : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(superenalottoHistoryProvider);
    return Scaffold(
      backgroundColor: SeColors.cream,
      appBar: AppBar(
        backgroundColor: SeColors.forest,
        foregroundColor: Colors.white,
        title: const Text('Nuova schedina SE'),
        actions: [
          TextButton(
            onPressed: () => context.push('/more/se/tickets'),
            child: const Text('Catalogo', style: TextStyle(color: SeColors.gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator(color: SeColors.forest)),
        error: (error, _) => Center(child: Text('$error')),
        data: (draws) {
          final stats = superenalottoStats(draws);
          final delayed = [...stats]..sort((a, b) {
              final byDelay = b.delay.compareTo(a.delay);
              if (byDelay != 0) return byDelay;
              return a.number.compareTo(b.number);
            });
          final suggestions = suggestSuperenalotto(draws);
          final latest = draws.reversed.take(5).toList();
          final fair = (superenalottoNumberProbability * 100).toStringAsFixed(2);
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const SeHeroHeader(
                title: 'Componi la giocata',
                subtitle: 'Categorie a montepremi · separate dalle schedine Lotto in euro.',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Probabilità equa di un numero nei sei: $fair%. Jolly e SuperStar non azzerano i ritardi dei sei.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (latest.isNotEmpty) ...[
                const SizedBox(height: 16),
                ResultsBanner(
                  'Concorso ${latest.first.contestNumber} · ${formatItalianDate(latest.first.date)}',
                  color: SeColors.forest,
                ),
                const SizedBox(height: 12),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: NumberBalls(numbers: latest.first.numbers, gold: true)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text('Jolly ${latest.first.jolly} · SuperStar ${latest.first.superstar}'),
                ),
              ],
              const SizedBox(height: 16),
              ResultsBanner('Ritardatari', color: SeColors.forest),
              if (draws.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Scarica prima l\'archivio dall\'area SuperEnalotto o da Estrazioni.'),
                )
              else
                OrangeTable(
                  headers: const ['N', 'Ritardo', 'Uscite', 'Equa'],
                  rows: [
                    for (final stat in delayed.take(10))
                      ['${stat.number}', stat.neverSeen ? '${stat.delay} (mai)' : '${stat.delay}', '${stat.hits}', '$fair%'],
                  ],
                ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                ResultsBanner('Suggerimenti', color: SeColors.forest),
                for (final suggestion in suggestions)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(suggestion.name, style: const TextStyle(fontWeight: FontWeight.w800, color: SeColors.forest)),
                        const SizedBox(height: 4),
                        Text(suggestion.how, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        NumberBalls(numbers: suggestion.numbers, gold: true),
                        if (suggestion.jolly != null) ...[
                          const SizedBox(height: 8),
                          Text('Jolly suggerito: ${suggestion.jolly}', style: const TextStyle(color: SeColors.forest, fontWeight: FontWeight.w700)),
                          if (suggestion.jollyHow != null) Text(suggestion.jollyHow!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (suggestion.superstar != null) ...[
                          const SizedBox(height: 8),
                          Text('SuperStar suggerita: ${suggestion.superstar}', style: const TextStyle(color: SeColors.mint, fontWeight: FontWeight.w700)),
                          if (suggestion.superstarHow != null) Text(suggestion.superstarHow!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => setState(() {
                            _systemMode = false;
                            _system = null;
                            _selected
                              ..clear()
                              ..addAll(suggestion.numbers);
                            _origin = suggestion.name.contains('Zoppe') ? 'zoppe' : 'suggerimento';
                            _message = null;
                            if (suggestion.superstar != null) {
                              _superstar.text = '${suggestion.superstar}';
                            }
                          }),
                          child: const Text('Metti in schedina'),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Schedina da 6'), icon: Icon(Icons.receipt_long_outlined)),
                    ButtonSegment(value: true, label: Text('Sistemone'), icon: Icon(Icons.hub_outlined)),
                  ],
                  selected: {_systemMode},
                  onSelectionChanged: (value) => setState(() {
                    _systemMode = value.first;
                    _system = null;
                    _message = null;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(_systemMode ? 'Pronostico ${_selected.length} numeri, colonne da 6.' : 'Numeri ${_selected.length} / 6'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _Grid(selected: _selected, onToggle: _toggle),
              ),
              if (!_systemMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _superstar,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SuperStar (facoltativa, 1–90)',
                      helperText: 'Può coincidere con uno dei sei. Non entra nella categoria principale.',
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!_systemMode)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: SeColors.forest),
                        onPressed: () => _save(_selected.toList()..sort()),
                        child: const Text('Registra schedina'),
                      ),
                    if (_systemMode)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: SeColors.forest),
                        onPressed: _develop,
                        child: const Text('Sviluppa il sistemone'),
                      ),
                    TextButton(
                      onPressed: () => setState(() {
                        _selected.clear();
                        _system = null;
                        _origin = 'manuale';
                      }),
                      child: const Text('Svuota'),
                    ),
                  ],
                ),
              ),
              if (_message != null)
                Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(_message!)),
              if (_system != null && _system!.combinations.isNotEmpty)
                _SystemPreview(result: _system!, onSave: (row) => _save(row, origin: 'sistemone')),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/more/se/tickets'),
                  icon: const Icon(Icons.receipt_long_outlined, color: SeColors.forest),
                  label: const Text('Vedi catalogo schedine e categorie'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SystemPreview extends StatelessWidget {
  const _SystemPreview({required this.result, required this.onSave});

  final GenerationResult result;
  final ValueChanged<List<int>> onSave;

  @override
  Widget build(BuildContext context) {
    final preview = result.combinations.take(6).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${result.combinations.length} colonne da 6. ${result.coverageClaim}'),
          const SizedBox(height: 4),
          Text(
            result.guaranteeVerified
                ? 'Garanzia ricontrollata: se almeno 3 dei 6 estratti sono nel pronostico, una colonna ne contiene almeno 2. Non alza la probabilità che escano.'
                : 'Garanzia non verificata.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final row in preview)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(row.join(' · '))),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => onSave(preview.first), child: const Text('Registra la prima colonna')),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 90,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, mainAxisSpacing: 4, crossAxisSpacing: 4),
      itemBuilder: (context, index) {
        final number = index + 1;
        final on = selected.contains(number);
        return InkWell(
          onTap: () => onToggle(number),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: on ? AppColors.ballGold : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: on ? AppColors.ballGold : AppColors.line),
            ),
            child: Center(
              child: Text('$number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on ? AppColors.navy : Theme.of(context).colorScheme.onSurface)),
            ),
          ),
        );
      },
    );
  }
}
