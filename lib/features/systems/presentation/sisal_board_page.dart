// lib/features/systems/presentation/sisal_board_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../superenalotto/presentation/se_chrome.dart';
import '../../superenalotto/presentation/se_studio_page.dart';
import '../../virtual_wallet/presentation/wallet_pages.dart';
import '../domain/combinations.dart';
import '../domain/sisal_guarantee.dart';

/// Maschera stile Sisal: griglia colonne, garanzie G5/G4/G3, spesa in basso.
class SisalBoardPage extends ConsumerStatefulWidget {
  const SisalBoardPage({this.forSuperEnalotto = true, super.key});

  final bool forSuperEnalotto;

  @override
  ConsumerState<SisalBoardPage> createState() => _SisalBoardPageState();
}

class _SisalBoardPageState extends ConsumerState<SisalBoardPage> {
  late var _se = widget.forSuperEnalotto;
  var _guarantee = SisalGuarantee.g4;
  final _pool = <int>{};
  var _stakeCents = seUnitCostCents;
  var _busy = false;
  String? _message;
  GenerationResult? _result;

  int get _drawn => _se ? superenalottoDrawnSize : lottoDrawnSize;
  int get _columnSize => _se ? 6 : 5;
  ({int min, int max}) get _range => _se ? sisalSePoolRange(_guarantee) : sisalLottoPoolRange(_guarantee);

  @override
  void initState() {
    super.initState();
    if (!_se) _stakeCents = 100;
  }

  void _toggle(int n) {
    setState(() {
      _result = null;
      _message = null;
      if (!_pool.remove(n)) {
        if (_pool.length >= _range.max) {
          _message = 'Per ${_guarantee.label} il pannello A Sisal prevede al massimo ${_range.max} numeri.';
          return;
        }
        _pool.add(n);
      }
    });
  }

  Future<void> _develop() async {
    final pool = _pool.toList()..sort();
    final range = _range;
    if (pool.length < range.min) {
      setState(() => _message = 'Per ${_guarantee.label} servono almeno ${range.min} numeri (come pannello A Sisal).');
      return;
    }
    final params = sisalReducedParams(
      guarantee: _guarantee,
      drawnSize: _drawn,
      combinationSize: _columnSize,
    );
    setState(() {
      _busy = true;
      _message = null;
      _result = null;
    });
    await Future<void>.delayed(Duration.zero);
    final result = generateReduced(
      pool: pool,
      combinationSize: _columnSize,
      assumedHits: params.assumedHits,
      guaranteedHits: params.guaranteedHits,
      seed: 42,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
      _message = result.combinations.isEmpty ? result.coverageClaim : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value ?? AppSettings.initial;
    if (!_se) _stakeCents = settings.unitCostCents;
    final columns = _result?.combinations ?? const <List<int>>[];
    final spend = buildSisalSpendSummary(
      columns: columns.length,
      combinationSize: _columnSize,
      poolSize: _pool.length,
      unitCostCents: _stakeCents,
      settings: settings,
    );
    final refCost = _se ? sisalSeReferenceCostCents(_guarantee, _pool.length) : null;
    final brand = _se ? SeColors.forest : AppColors.navy;

    return Scaffold(
      backgroundColor: _se ? SeColors.cream : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        title: Text(_se ? 'SuperEnalotto · Sistemi' : 'Lotto · Sistemi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(
                  'Maschera di studio ispirata a Sisal: griglia colonne, garanzia G5/G4/G3 e spesa simulata. Nessun acquisto reale.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('SuperEnalotto'), icon: Icon(Icons.stars_outlined)),
                    ButtonSegment(value: false, label: Text('Lotto'), icon: Icon(Icons.confirmation_number_outlined)),
                  ],
                  selected: {_se},
                  onSelectionChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _se = v.first;
                            _pool.clear();
                            _result = null;
                            _message = null;
                            _stakeCents = _se ? seUnitCostCents : settings.unitCostCents;
                          }),
                ),
                const SizedBox(height: 12),
                Text('Garanzia', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                SegmentedButton<SisalGuarantee>(
                  segments: [
                    for (final g in SisalGuarantee.values)
                      ButtonSegment(value: g, label: Text(g.label), tooltip: g.longLabel),
                  ],
                  selected: {_guarantee},
                  onSelectionChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _guarantee = v.first;
                            _result = null;
                            _message = null;
                          }),
                ),
                const SizedBox(height: 8),
                Text(
                  sisalHint(guarantee: _guarantee, drawnSize: _drawn, combinationSize: _columnSize),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Pannello A: ${_range.min}–${_range.max} numeri · selezionati ${_pool.length}.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _NumberGrid(selected: _pool, accent: brand, onToggle: _busy ? (_) {} : _toggle),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: brand),
                      onPressed: _busy ? null : _develop,
                      icon: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.grid_on),
                      label: Text(_busy ? 'Sviluppo…' : 'Sviluppa ${_guarantee.label}'),
                    ),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _pool.clear();
                                _result = null;
                                _message = null;
                              }),
                      child: const Text('Svuota'),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                if (_result != null && columns.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SpendBoard(
                    spend: spend,
                    guarantee: _guarantee,
                    verified: _result!.guaranteeVerified,
                    referenceCostCents: refCost,
                    brand: brand,
                    se: _se,
                    stakeCents: _stakeCents,
                    onStake: _se
                        ? null
                        : (cents) => setState(() => _stakeCents = cents),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _result!.coverageClaim,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _SisalColumnCard(
                    columns: columns,
                    columnSize: _columnSize,
                    brand: brand,
                    se: _se,
                    guarantee: _guarantee,
                    totalCents: spend.totalCents,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_se)
                        OutlinedButton.icon(
                          onPressed: () {
                            final first = columns.first;
                            context.push(seStudioRoute(numbers: first));
                          },
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Prima colonna in schedina SE'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () {
                            final first = columns.first;
                            context.push(newTicketRoute(numbers: first));
                          },
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Prima colonna in schedina Lotto'),
                        ),
                      TextButton(
                        onPressed: () => context.push('/more/wallet'),
                        child: const Text('Limiti budget'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _FooterBar(
            brand: brand,
            combos: columns.length,
            totalCents: spend.totalCents,
            enabled: columns.isNotEmpty && !_busy,
            onNext: columns.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Studio: ${columns.length} colonne · ${formatEuro(spend.totalCents)}. '
                          'Nessun pagamento inviato.',
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.brand,
    required this.combos,
    required this.totalCents,
    required this.enabled,
    required this.onNext,
  });

  final Color brand;
  final int combos;
  final int totalCents;
  final bool enabled;
  final VoidCallback? onNext;

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
                    Text(
                      '$combos Comb',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    Text(
                      formatEuro(totalCents),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: brand),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: enabled ? brand : brand.withValues(alpha: 0.35),
                  minimumSize: const Size(140, 48),
                ),
                onPressed: enabled ? onNext : null,
                child: const Text('Avanti', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendBoard extends StatelessWidget {
  const _SpendBoard({
    required this.spend,
    required this.guarantee,
    required this.verified,
    required this.referenceCostCents,
    required this.brand,
    required this.se,
    required this.stakeCents,
    required this.onStake,
  });

  final SisalSpendSummary spend;
  final SisalGuarantee guarantee;
  final bool verified;
  final int? referenceCostCents;
  final Color brand;
  final bool se;
  final int stakeCents;
  final ValueChanged<int>? onStake;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spend.overContestBudget ? Theme.of(context).colorScheme.error : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Quanto spendi', style: TextStyle(fontWeight: FontWeight.w800, color: brand, fontSize: 16)),
              const Spacer(),
              if (verified)
                Chip(
                  avatar: Icon(Icons.verified, color: brand, size: 18),
                  label: Text('${guarantee.label} ok'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _Mini(label: 'Colonne', value: '${spend.columns}')),
              Expanded(child: _Mini(label: 'A colonna', value: formatEuro(spend.unitCostCents))),
              Expanded(child: _Mini(label: 'Totale', value: formatEuro(spend.totalCents), emphasize: true)),
            ],
          ),
          if (!se && onStake != null) ...[
            const SizedBox(height: 8),
            Text('Posta studio Lotto: ${formatEuro(stakeCents)}'),
            Slider(
              value: stakeCents.toDouble().clamp(100, 2000),
              min: 100,
              max: 2000,
              divisions: 19,
              label: formatEuro(stakeCents),
              onChanged: (v) => onStake!((v / 50).round() * 50),
            ),
          ],
          if (se) ...[
            const SizedBox(height: 6),
            Text('Posta SE di studio: 1,00 € a colonna (come Sisal).', style: Theme.of(context).textTheme.bodySmall),
          ],
          if (referenceCostCents != null) ...[
            const SizedBox(height: 6),
            Text(
              'Tabella Sisal di riferimento (stesso ${guarantee.label}, 0 ruotanti): circa ${formatEuro(referenceCostCents!)}. '
              'Il nostro sviluppo greedy può dare un numero di colonne diverso; la garanzia è comunque ricontrollata.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Text(spend.advice, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: emphasize ? 18 : 16,
            color: emphasize ? AppColors.navy : AppColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Scheda stile Sisal: intestazione verde, righe numerate, cerchi con i numeri giocati.
class _SisalColumnCard extends StatelessWidget {
  const _SisalColumnCard({
    required this.columns,
    required this.columnSize,
    required this.brand,
    required this.se,
    required this.guarantee,
    required this.totalCents,
  });

  final List<List<int>> columns;
  final int columnSize;
  final Color brand;
  final bool se;
  final SisalGuarantee guarantee;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: brand.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: brand,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Colonne per garantire ${guarantee.label}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                Text(
                  '${columns.length} comb · ${formatEuro(totalCents)}',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text(
              se
                  ? 'Ogni riga è una sestina di studio. La stella SuperStar non entra nella garanzia G5/G4/G3.'
                  : 'Ogni riga è una cinquina di studio sulla ruota che scegli in schedina.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            height: min(480, columns.length * 52.0 + 8),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0A01A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            for (var i = 0; i < columnSize; i++) ...[
                              if (i > 0) const SizedBox(width: 4),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: brand, width: 1.6),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        i < row.length ? '${row[i]}' : '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          color: brand,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (se) ...[
                              const SizedBox(width: 6),
                              AspectRatio(
                                aspectRatio: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE53935), width: 1.6),
                                  ),
                                  child: const Icon(Icons.star_border, color: Color(0xFFE53935), size: 14),
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

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({required this.selected, required this.accent, required this.onToggle});

  final Set<int> selected;
  final Color accent;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
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
        return InkWell(
          onTap: () => onToggle(number),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: on ? accent : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: on ? accent : AppColors.line),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
