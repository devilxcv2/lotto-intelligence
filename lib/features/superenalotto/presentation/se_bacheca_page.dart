// lib/features/superenalotto/presentation/se_bacheca_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/settings/app_settings.dart';
import '../../systems/domain/sisal_guarantee.dart';
import '../domain/se_bacheca.dart';
import 'se_chrome.dart';
import 'se_studio_page.dart';

/// Bacheca sistemi SuperEnalotto (studio): tutte le tipologie Sisal descritte in
/// https://www.superenalotto.it/come-si-gioca/bacheca-dei-sistemi
class SeBachecaPage extends ConsumerStatefulWidget {
  const SeBachecaPage({super.key});

  @override
  ConsumerState<SeBachecaPage> createState() => _SeBachecaPageState();
}

class _SeBachecaPageState extends ConsumerState<SeBachecaPage> {
  var _kind = SeBachecaKind.integrale;
  final _pool = <int>{};
  final _basi = <int>{};
  final _varianti = <int>{};
  final _ruotanti = <int>{};
  var _guarantee = SisalGuarantee.g5;
  var _basiK = 2;
  var _cruciverbaN = 6;
  var _multiSize = 7;
  var _multiPacks = 5;
  var _busy = false;
  String? _message;
  SeBachecaResult? _result;

  void _wipeResult() {
    _result = null;
    _message = null;
  }

  void _togglePool(int n) {
    setState(() {
      _wipeResult();
      if (!_pool.remove(n)) _pool.add(n);
    });
  }

  void _toggleBasi(int n) {
    setState(() {
      _wipeResult();
      _varianti.remove(n);
      if (!_basi.remove(n)) _basi.add(n);
    });
  }

  void _toggleVarianti(int n) {
    setState(() {
      _wipeResult();
      _basi.remove(n);
      if (!_varianti.remove(n)) _varianti.add(n);
    });
  }

  void _toggleRuotanti(int n) {
    setState(() {
      _wipeResult();
      if (_pool.contains(n)) return;
      if (!_ruotanti.remove(n)) {
        if (_ruotanti.length >= 5) {
          _message = 'Al massimo 5 ruotanti (pannello B Sisal).';
          return;
        }
        _ruotanti.add(n);
      }
    });
  }

  Future<void> _develop() async {
    setState(() {
      _busy = true;
      _message = null;
      _result = null;
    });
    await Future<void>.delayed(Duration.zero);
    late SeBachecaResult result;
    switch (_kind) {
      case SeBachecaKind.integrale:
        result = developIntegrale(_pool.toList());
      case SeBachecaKind.ridotto:
        result = developRidotto(
          panelA: _pool.toList(),
          guarantee: _guarantee,
          ruotanti: _ruotanti.toList(),
        );
      case SeBachecaKind.basiVarianti:
        result = developBasiVarianti(basi: _basi.toList(), varianti: _varianti.toList(), k: _basiK);
      case SeBachecaKind.cruciverba:
        result = developCruciverba(_pool.toList(), _cruciverbaN);
      case SeBachecaKind.minicruciverba:
        result = developMinicruciverba(_pool.toList());
      case SeBachecaKind.multistella:
        result = developMultistella(size: _multiSize, packs: _multiPacks, seed: Random().nextInt(1 << 30));
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
      if (result.columns.isEmpty) _message = result.coverageClaim;
    });
  }

  @override
  Widget build(BuildContext context) {
    final columns = _result?.columns ?? const <List<int>>[];
    return Scaffold(
      backgroundColor: SeColors.cream,
      appBar: AppBar(
        backgroundColor: SeColors.forest,
        foregroundColor: Colors.white,
        title: const Text('Bacheca sistemi'),
        actions: [
          TextButton(
            onPressed: () => context.push('/lab/sisal?game=se'),
            child: const Text('Solo G5/G4/G3', style: TextStyle(color: SeColors.gold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(
                  'Studio delle tipologie Sisal (Integrale, Ridotto, Basi e Varianti, Cruciverba, Minicruciverba, Multistella). '
                  'Costo a 1,00 € a sestina. Nessun acquisto reale né carature.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Fonte: superenalotto.it · Bacheca dei sistemi',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: SeColors.forest),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in SeBachecaKind.values)
                      ChoiceChip(
                        label: Text(k.label),
                        selected: _kind == k,
                        selectedColor: SeColors.forest.withValues(alpha: 0.2),
                        onSelected: _busy
                            ? null
                            : (on) {
                                if (!on) return;
                                setState(() {
                                  _kind = k;
                                  _result = null;
                                  _message = null;
                                  _ruotanti.clear();
                                });
                              },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_kind.blurb, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                ..._kindControls(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: SeColors.forest, minimumSize: const Size.fromHeight(48)),
                  onPressed: _busy ? null : _develop,
                  icon: _busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.grid_on),
                  label: Text(_busy ? 'Sviluppo…' : 'Sviluppa ${_kind.label}'),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                if (_result != null && columns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ResultHeader(result: _result!),
                  if (_result!.grid != null) ...[
                    const SizedBox(height: 8),
                    _GridPreview(grid: _result!.grid!, brand: SeColors.forest),
                  ],
                  if (_result!.superstars.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'SuperStar per pacchetto: ${_result!.superstars.join(' · ')}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE53935)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(_result!.coverageClaim, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  _SisalRows(
                    columns: columns,
                    totalCents: _result!.costCents,
                    title: '${_kind.label} · ${columns.length} sestine',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push(seStudioRoute(numbers: columns.first)),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Prima sestina in schedina'),
                  ),
                ],
              ],
            ),
          ),
          _Footer(
            combos: columns.length,
            totalCents: _result?.costCents ?? 0,
            enabled: columns.isNotEmpty,
          ),
        ],
      ),
    );
  }

  List<Widget> _kindControls() {
    switch (_kind) {
      case SeBachecaKind.integrale:
        return [
          Text('Numeri ${_pool.length} (7–19)', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _PoolGrid(selected: _pool, onToggle: _busy ? (_) {} : _togglePool),
          const SizedBox(height: 8),
          _IntegralCostTable(selected: _pool.length),
        ];
      case SeBachecaKind.ridotto:
        return [
          SegmentedButton<SisalGuarantee>(
            segments: [
              for (final g in SisalGuarantee.values) ButtonSegment(value: g, label: Text(g.label)),
            ],
            selected: {_guarantee},
            onSelectionChanged: _busy
                ? null
                : (v) => setState(() {
                      _guarantee = v.first;
                      _wipeResult();
                    }),
          ),
          const SizedBox(height: 8),
          Text(
            'Pannello A: ${sisalSePoolRange(_guarantee).min}–${sisalSePoolRange(_guarantee).max} · ${_pool.length} scelti',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _PoolGrid(selected: _pool, onToggle: _busy ? (_) {} : _togglePool),
          const SizedBox(height: 8),
          Text('Ruotanti pannello B (0–5): ${_ruotanti.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _PoolGrid(
            selected: _ruotanti,
            accent: const Color(0xFFF0A01A),
            onToggle: _busy ? (_) {} : _toggleRuotanti,
            dimmed: _pool,
          ),
        ];
      case SeBachecaKind.basiVarianti:
        return [
          SegmentedButton<int>(
            segments: [for (var k = 1; k <= 5; k++) ButtonSegment(value: k, label: Text('B$k'))],
            selected: {_basiK},
            onSelectionChanged: _busy
                ? null
                : (v) => setState(() {
                      _basiK = v.first;
                      _wipeResult();
                    }),
          ),
          const SizedBox(height: 6),
          Text('B$_basiK: ${_basiK} basi + ${6 - _basiK} varianti per sestina.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text('Basi (${_basi.length})', style: const TextStyle(fontWeight: FontWeight.w700, color: SeColors.forest)),
          _PoolGrid(selected: _basi, onToggle: _busy ? (_) {} : _toggleBasi),
          const SizedBox(height: 8),
          Text('Varianti (${_varianti.length})', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFF0A01A))),
          _PoolGrid(selected: _varianti, accent: const Color(0xFFF0A01A), onToggle: _busy ? (_) {} : _toggleVarianti),
        ];
      case SeBachecaKind.cruciverba:
        return [
          SegmentedButton<int>(
            segments: [for (final n in seCruciverbaSizes) ButtonSegment(value: n, label: Text('${n}×$n'))],
            selected: {_cruciverbaN},
            onSelectionChanged: _busy
                ? null
                : (v) => setState(() {
                      _cruciverbaN = v.first;
                      _pool.clear();
                      _wipeResult();
                    }),
          ),
          const SizedBox(height: 6),
          Text(
            'Servono ${_cruciverbaN * _cruciverbaN} numeri · ${_pool.length} · catalogo ${seCruciverbaCatalogCombinations(_cruciverbaN)} comb.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text('10×10 e 11×11: solo ricevitoria Sisal (oltre 90 celle).', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          _PoolGrid(selected: _pool, onToggle: _busy ? (_) {} : _togglePool, maxSelect: _cruciverbaN * _cruciverbaN),
        ];
      case SeBachecaKind.minicruciverba:
        return [
          Text('9 numeri per la griglia 3×3 · ${_pool.length}/9', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _PoolGrid(selected: _pool, onToggle: _busy ? (_) {} : _togglePool, maxSelect: 9),
        ];
      case SeBachecaKind.multistella:
        return [
          const Text('Taglio Sisal (studio)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cut in seMultistellaCuts)
                ChoiceChip(
                  label: Text(cut.name),
                  selected: _multiSize == cut.size && _multiPacks == cut.packs,
                  selectedColor: SeColors.forest.withValues(alpha: 0.2),
                  onSelected: _busy
                      ? null
                      : (on) {
                          if (!on) return;
                          setState(() {
                            _multiSize = cut.size;
                            _multiPacks = cut.packs;
                            _wipeResult();
                          });
                        },
                ),
            ],
          ),
        ];
    }
  }
}

class _IntegralCostTable extends StatelessWidget {
  const _IntegralCostTable({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tabella Sisal integrale (estratto)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final n in [7, 8, 9, 10, 12, 15, 19])
            Text(
              '$n num → ${seIntegralCombinations(n)} comb · ${formatEuro(seIntegralCostCents(n))}'
              '${selected == n ? '  ←' : ''}',
              style: TextStyle(
                fontWeight: selected == n ? FontWeight.w800 : FontWeight.w500,
                color: selected == n ? SeColors.forest : AppColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result});

  final SeBachecaResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFFF0A01A)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.kind.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                Text(
                  '${result.columnCount} sestine · ${formatEuro(result.costCents)}'
                  '${result.catalogColumns != null ? ' · catalogo ${result.catalogColumns}' : ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (result.guaranteeVerified)
            const Icon(Icons.verified, color: Colors.white),
        ],
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview({required this.grid, required this.brand});

  final List<List<int>> grid;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          for (final row in grid)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (final n in row)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: brand),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$n', style: TextStyle(fontWeight: FontWeight.w800, color: brand)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SisalRows extends StatelessWidget {
  const _SisalRows({required this.columns, required this.totalCents, required this.title});

  final List<List<int>> columns;
  final int totalCents;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SeColors.forest.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: SeColors.forest,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                Text(formatEuro(totalCents), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          SizedBox(
            height: min(440, columns.length * 52.0 + 8),
            child: ListView.builder(
              itemCount: columns.length,
              itemExtent: 52,
              itemBuilder: (context, index) {
                final row = columns[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: const Color(0xFFF0A01A), borderRadius: BorderRadius.circular(6)),
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            for (var i = 0; i < 6; i++) ...[
                              if (i > 0) const SizedBox(width: 4),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: SeColors.forest, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        i < row.length ? '${row[i]}' : '',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: SeColors.forest),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.combos, required this.totalCents, required this.enabled});

  final int combos;
  final int totalCents;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$combos Comb', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(formatEuro(totalCents), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: SeColors.forest)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: enabled ? SeColors.forest : SeColors.forest.withValues(alpha: 0.35),
                  minimumSize: const Size(140, 48),
                ),
                onPressed: enabled
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Studio: $combos sestine · ${formatEuro(totalCents)}. Nessun pagamento.')),
                        )
                    : null,
                child: const Text('Avanti', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PoolGrid extends StatelessWidget {
  const _PoolGrid({
    required this.selected,
    required this.onToggle,
    this.accent = SeColors.forest,
    this.dimmed = const {},
    this.maxSelect,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final Color accent;
  final Set<int> dimmed;
  final int? maxSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 90,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, mainAxisSpacing: 3, crossAxisSpacing: 3),
      itemBuilder: (context, index) {
        final number = index + 1;
        final on = selected.contains(number);
        final blocked = dimmed.contains(number);
        return InkWell(
          onTap: blocked
              ? null
              : () {
                  if (!on && maxSelect != null && selected.length >= maxSelect!) return;
                  onToggle(number);
                },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: on ? accent : (blocked ? const Color(0xFFEEEEEE) : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(color: on ? accent : AppColors.line),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : (blocked ? Colors.black26 : AppColors.ink),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
