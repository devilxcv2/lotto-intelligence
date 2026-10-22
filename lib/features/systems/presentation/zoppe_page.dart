// lib/features/systems/presentation/zoppe_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/hypergeometric.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../../virtual_wallet/presentation/wallet_pages.dart';
import '../domain/zoppe_system.dart';

class ZoppePage extends ConsumerStatefulWidget {
  const ZoppePage({this.initialMask = const {}, super.key});

  final Set<int> initialMask;

  @override
  ConsumerState<ZoppePage> createState() => _ZoppePageState();
}

class _ZoppePageState extends ConsumerState<ZoppePage> {
  late final Set<int> _universe = {...widget.initialMask.where((number) => number >= 1 && number <= 90)};
  var _seed = 42;
  ZoppeResult? _result;
  String? _error;

  void _compose() {
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = ref.read(wheelDrawsProvider(wheel)).valueOrNull;
    if (draws == null) {
      setState(() => _error = 'L\'archivio di questa ruota non è ancora pronto.');
      return;
    }
    if (draws.length < 30) {
      setState(() {
        _result = null;
        _error = 'Servono almeno 30 estrazioni in archivio su questa ruota.';
      });
      return;
    }
    final window = draws.length < zoppeWindowDraws ? draws.length : zoppeWindowDraws;
    final stats = frequencyAndDelay(draws, window: window);
    final result = buildZoppeSystem(
      hits: stats.hits,
      delays: stats.delay,
      universe: _universe,
      columnSize: 5,
      seed: _seed,
      windowDraws: window,
    );
    setState(() {
      _result = result;
      _error = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final name = wheelByCode(wheel)?.name ?? wheel;
    final archive = ref.watch(wheelDrawsProvider(wheel));
    final result = _result;
    return PageScaffold(
      title: 'Sistemone Zoppe',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: DisclaimerBanner()),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ResultsBanner('Legenda'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(zoppeLegendFive, style: Theme.of(context).textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Ruota: $name. Tocca i numeri per limitare l\'universo (opzionale). '
              'Se nessuno è acceso, lo Zoppe legge tutti i 90.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _MaskGrid(
              selected: _universe,
              result: result,
              onToggle: (number) => setState(() {
                if (!_universe.remove(number)) _universe.add(number);
                _result = null;
                _error = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(_universe.isEmpty ? 'Universo: tutti i 90' : 'Universo: ${_universe.length} numeri'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Seme del gettonato casuale: $_seed'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Slider(
              value: _seed.toDouble(),
              min: 1,
              max: 99,
              divisions: 98,
              label: '$_seed',
              onChanged: (value) => setState(() {
                _seed = value.round();
                _result = null;
                _error = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'Il seme cambia quale gettonato esce a caso fra i più usciti. '
              'La probabilità equa resta ${(singleNumberProbability * 100).toStringAsFixed(2)}% per ogni numero.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: FilledButton.icon(
              onPressed: archive.isLoading ? null : _compose,
              icon: const Icon(Icons.hub_outlined),
              label: const Text('Componi lo Zoppe'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (result != null && result.columns.isNotEmpty) _Outcome(result: result, wheel: wheel),
        ],
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({required this.result, required this.wheel});

  final ZoppeResult result;
  final String wheel;

  @override
  Widget build(BuildContext context) {
    final watched = result.allPoolNumbers.length;
    final atLeast = zoppeFairAtLeastOne(watched);
    final preview = result.columns.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const ResultsBanner('Gambe dello Zoppe'),
        for (final leg in result.legs)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leg.label, style: const TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w800)),
                Text(leg.how, style: Theme.of(context).textTheme.bodySmall),
                Text(leg.pool.isEmpty ? '—' : leg.pool.join(' · '), style: const TextStyle(color: AppColors.numberBlue, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            '${result.columns.length} colonne da ${result.columnSize}, lette su ${result.windowDraws} estrazioni. '
            'Probabilità equa di almeno un centro tenendo d\'occhio $watched numeri delle gambe: ${(atLeast * 100).toStringAsFixed(1)}%.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        const ResultsBanner('Colonna guida'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NumberBalls(numbers: result.leadColumn),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Somma delle uscite storiche: ${result.leadHits}. '
            'Ordina il passato. Non è la colonna più probabile.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: FilledButton.icon(
            onPressed: () => context.push(newTicketRoute(numbers: result.leadColumn, wheel: wheel)),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Apri nuova schedina con questa colonna'),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Oppure da Schedine → Nuova schedina usa il pulsante «Sistemone Zoppe»: riempie i numeri lì, senza passare da questa pagina.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < preview.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: InkWell(
              onTap: () => context.push(newTicketRoute(numbers: preview[i], wheel: wheel)),
              child: Text('${i + 1}.  ${preview[i].join('   ')}'),
            ),
          ),
        if (result.columns.length > preview.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('… e altre ${result.columns.length - preview.length} colonne.', style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _MaskGrid extends StatelessWidget {
  const _MaskGrid({required this.selected, required this.result, required this.onToggle});

  final Set<int> selected;
  final ZoppeResult? result;
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
        final role = _role(context, number);
        return Semantics(
          button: true,
          selected: selected.contains(number),
          label: 'Numero $number, ${role.label}',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onToggle(number),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: role.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: role.border),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(fontWeight: FontWeight.w700, color: role.ink, fontSize: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _Role _role(BuildContext context, int number) {
    final result = this.result;
    final legId = result?.roleOf(number);
    if (legId == 'gettonato') {
      return const _Role('gettonato', AppColors.ballGold, AppColors.navy, AppColors.ballGold);
    }
    if (legId == 'ritardatario') {
      return const _Role('ritardatario', AppColors.banner, Colors.white, AppColors.banner);
    }
    if (legId != null) {
      return const _Role('fascia', AppColors.ball, AppColors.ballText, AppColors.ball);
    }
    if (selected.isEmpty || selected.contains(number)) {
      final scheme = Theme.of(context).colorScheme;
      return _Role(selected.isEmpty ? 'universo' : 'selezionato', scheme.surface, scheme.onSurface, AppColors.line);
    }
    return const _Role('fuori', Color(0xFFE8E8E8), Color(0xFF9A9A9A), AppColors.line);
  }
}

class _Role {
  const _Role(this.label, this.color, this.ink, this.border);

  final String label;
  final Color color;
  final Color ink;
  final Color border;
}
