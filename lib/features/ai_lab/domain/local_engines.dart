// lib/features/ai_lab/domain/local_engines.dart

import 'dart:math';

import '../../../core/lotto/scientific_notice.dart';
import '../../statistics/domain/statistics_engine.dart';
import '../../systems/domain/combinations.dart';

class StudyProposal {
  const StudyProposal({
    required this.engineId,
    required this.engineVersion,
    required this.numbers,
    required this.method,
    required this.rationale,
    required this.limitations,
    required this.datasetNote,
    required this.config,
  });

  final String engineId;
  final String engineVersion;
  final List<int> numbers;
  final String method;
  final String rationale;
  final String limitations;
  final String datasetNote;
  final Map<String, Object?> config;
}

class UniformEngine {
  const UniformEngine();

  StudyProposal generate({required String wheelCode, required int seed, required int datasetDraws}) {
    final numbers = sampleUniform(5, Random(seed));
    return StudyProposal(
      engineId: 'uniform-baseline',
      engineVersion: '1',
      numbers: numbers,
      method: 'Campione uniforme di 5 numeri distinti fra 1 e 90.',
      rationale: 'Nessun peso storico. È la baseline con cui confrontare gli altri metodi.',
      limitations: scientificDisclaimer,
      datasetNote: 'Ruota $wheelCode, estrazioni disponibili al momento della generazione: $datasetDraws. Il sorteggio non le usa.',
      config: {'seed': seed, 'wheel': wheelCode},
    );
  }
}

class DescriptiveWeightEngine {
  const DescriptiveWeightEngine();

  StudyProposal generate({
    required String wheelCode,
    required List<ArchivedDraw> history,
    required int seed,
    required bool useDelay,
  }) {
    final stats = const StatisticsEngine().summarize(history);
    final weights = <int, double>{
      for (final stat in stats.numbers) stat.number: (useDelay ? stat.currentDelay : stat.absoluteFrequency) + 1,
    };
    final numbers = _weightedDistinct(weights, 5, Random(seed));
    final mode = useDelay ? 'ritardo corrente' : 'frequenza assoluta';
    return StudyProposal(
      engineId: useDelay ? 'descriptive-delay-weight' : 'descriptive-frequency-weight',
      engineVersion: '1',
      numbers: numbers,
      method: 'Campionamento pesato senza reinserimento. Peso = $mode + 1.',
      rationale:
          'Il +1 evita di escludere i numeri con peso zero. Il peso è una descrizione dell\'archivio normalizzata solo per estrarre una combinazione di studio: non è la probabilità di uscita alla prossima estrazione, che nel modello equo resta 5/90 per ogni numero.',
      limitations: scientificDisclaimer,
      datasetNote: 'Ruota $wheelCode, finestra usata: ${history.length} estrazioni precedenti alla generazione.',
      config: {'seed': seed, 'wheel': wheelCode, 'window': history.length, 'weight': mode},
    );
  }
}

class HeuristicFilterEngine {
  const HeuristicFilterEngine();

  /// Se i filtri lasciano meno di 5 numeri, solleva [StateError] invece di allentare i criteri in silenzio.
  StudyProposal generate({
    required String wheelCode,
    required List<ArchivedDraw> history,
    required int seed,
    required int minDelay,
    required bool evensOnly,
  }) {
    final stats = const StatisticsEngine().summarize(history);
    final pool = [
      for (final stat in stats.numbers)
        if (stat.currentDelay >= minDelay && (!evensOnly || stat.number.isEven)) stat.number,
    ];
    if (pool.length < 5) {
      throw StateError('I filtri lasciano ${pool.length} numeri, meno dei 5 richiesti. Allarga il criterio: il motore non lo fa da solo.');
    }
    final numbers = sampleUniform(5, Random(seed), pool: pool);
    return StudyProposal(
      engineId: 'heuristic-filter',
      engineVersion: '1',
      numbers: numbers,
      method: 'Filtro su ritardo minimo $minDelay${evensOnly ? ' e sola parità pari' : ''}, poi campione uniforme fra i numeri rimasti.',
      rationale: 'I filtri sono scelte dell\'utente, non evidenze che quei numeri siano più probabili.',
      limitations: scientificDisclaimer,
      datasetNote: 'Ruota $wheelCode, finestra: ${history.length} estrazioni. Numeri ammessi dal filtro: ${pool.length}.',
      config: {'seed': seed, 'wheel': wheelCode, 'minDelay': minDelay, 'evensOnly': evensOnly, 'pool': pool.length},
    );
  }
}

List<int> _weightedDistinct(Map<int, double> weights, int count, Random random) {
  final keys = <int, double>{};
  for (final entry in weights.entries) {
    final safe = entry.value <= 0 ? 0.0001 : entry.value;
    final unit = random.nextDouble().clamp(0.0000001, 1.0);
    keys[entry.key] = pow(unit, 1 / safe).toDouble();
  }
  final ranked = keys.keys.toList()..sort((a, b) => keys[b]!.compareTo(keys[a]!));
  return ranked.take(count).toList()..sort();
}
