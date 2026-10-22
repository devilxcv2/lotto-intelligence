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
  late final Set<int> _positive = {...widget.initialMask.where((number) => number >= 1 && number <= 90)};
  var _share = 12;
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
    final hits = frequencyInWindow(draws);
    final result = buildZoppeSystem(
      positiveMask: _positive,
      hits: hits,
      positiveShare: _share / 100,
      windowDraws: draws.length < zoppeWindowDraws ? draws.length : zoppeWindowDraws,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Ruota: $name. Tocca i numeri della maschera positiva. '
              'Quelli che restano spenti sono la maschera negativa, il complemento dei 90.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _MaskGrid(
              positive: _positive,
              result: result,
              onToggle: (number) => setState(() {
                if (!_positive.remove(number)) _positive.add(number);
                _result = null;
                _error = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Positiva ${_positive.length} · negativa ${90 - _positive.length}'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Fetta più gettonata della positiva: $_share%'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Slider(
              value: _share.toDouble(),
              min: 10,
              max: 15,
              divisions: 5,
              label: '$_share%',
              onChanged: (value) => setState(() {
                _share = value.round();
                _result = null;
                _error = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dalla negativa si tengono i numeri fra il 30° e il 45° posto della frequenza '
              'nelle ultime $zoppeWindowDraws estrazioni. Non è la probabilità di uscire: '
              'quella equa è sempre ${(singleNumberProbability * 100).toStringAsFixed(2)}% per ogni numero.',
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
    final watched = {...result.positiveSlice, ...result.negativeBand}.length;
    final atLeast = zoppeFairAtLeastOne(watched);
    final preview = result.columns.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const ResultsBanner('Gambe dello Zoppe'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Fetta positiva, i più usciti: ${result.positiveSlice.join(' · ')}',
            style: const TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Text(
            'Fascia negativa 30–45: ${result.negativeBand.join(' · ')}',
            style: const TextStyle(color: AppColors.numberBlue, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Ogni colonna porta ${result.fromPositive} numeri della fetta positiva e ${result.fromNegative} della fascia negativa. '
            'La gamba positiva è la più corta. Colonne: ${result.columns.length}, lette su ${result.windowDraws} estrazioni.',
          ),
        ),
        if (result.trimmed)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text('La fascia era troppo larga per i pari merito: sono rimasti i numeri più vicini al centro, il 37,5.'),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Probabilità equa di almeno un centro tenendo d\'occhio questi $watched numeri: ${(atLeast * 100).toStringAsFixed(1)}%. '
            'Ogni numero resta al ${(singleNumberProbability * 100).toStringAsFixed(2)}%.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        const ResultsBanner('Colonna con più uscite nel periodo'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NumberBalls(numbers: result.leadColumn),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Somma delle uscite storiche: ${result.leadHits}. '
            'Ordina il passato. Non è la colonna più probabile: ogni cinquina di cinque numeri distinti ha la stessa probabilità.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: OutlinedButton.icon(
            onPressed: () => context.push(newTicketRoute(numbers: result.leadColumn, wheel: wheel)),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Schedina ipotetica con questa colonna'),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < preview.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text('${i + 1}.  ${preview[i].join('   ')}'),
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
  const _MaskGrid({required this.positive, required this.result, required this.onToggle});

  final Set<int> positive;
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
          selected: positive.contains(number),
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
    if (result != null && result.positiveSlice.contains(number)) {
      return const _Role('fetta positiva', AppColors.ballGold, AppColors.navy, AppColors.ballGold);
    }
    if (result != null && result.negativeBand.contains(number)) {
      return const _Role('fascia negativa', AppColors.ball, AppColors.ballText, AppColors.ball);
    }
    if (positive.contains(number)) {
      return const _Role('maschera positiva', AppColors.banner, Colors.white, AppColors.banner);
    }
    final scheme = Theme.of(context).colorScheme;
    return _Role('maschera negativa', scheme.surface, scheme.onSurface, AppColors.line);
  }
}

class _Role {
  const _Role(this.label, this.color, this.ink, this.border);

  final String label;
  final Color color;
  final Color ink;
  final Color border;
}
