// lib/features/systems/domain/system_request.dart

import 'dart:math';

import '../../../core/isolates/background_job.dart';
import 'combinations.dart';

/// Parametri completi di una generazione; contiene solo dati inviabili
/// a un isolate.
class SystemRequest {
  const SystemRequest({
    required this.mode,
    required this.pool,
    required this.combinationSize,
    required this.filter,
    required this.count,
    required this.assumedHits,
    required this.guaranteedHits,
    required this.seed,
  });

  final GenerationMode mode;
  final List<int> pool;
  final int combinationSize;
  final CombinationFilter filter;
  final int count;
  final int assumedHits;
  final int guaranteedHits;
  final int seed;

  /// Colonne attese prima di generare. Per il ridotto il numero esatto
  /// si conosce solo alla fine, quindi resta nullo.
  BigInt? get expectedColumns => switch (mode) {
        GenerationMode.integral => estimateCombinations(poolSize: pool.length, combinationSize: combinationSize).total,
        GenerationMode.parametric => BigInt.from(count),
        GenerationMode.reduced => null,
      };

  Map<String, String> toParameters() => {
        'mode': mode.name,
        'pool': ([...pool]..sort()).join(','),
        'column_size': '$combinationSize',
        'count': '$count',
        'assumed_hits': '$assumedHits',
        'guaranteed_hits': '$guaranteedHits',
        'seed': '$seed',
        'filter_even': '${filter.minEven}-${filter.maxEven}',
        'filter_sum': '${filter.minSum}-${filter.maxSum}',
        'filter_max_consecutive': '${filter.maxConsecutiveRun}',
        'filter_max_per_decade': '${filter.maxPerDecade}',
      };
}

GenerationResult runSystemRequest(SystemRequest request, ProgressReporter report) {
  switch (request.mode) {
    case GenerationMode.integral:
      final total = estimateCombinations(poolSize: request.pool.length, combinationSize: request.combinationSize).total;
      final scale = total == BigInt.zero ? 1.0 : total.toDouble();
      return generateIntegral(
        pool: request.pool,
        combinationSize: request.combinationSize,
        filter: request.filter,
        onProgress: (scanned, _) => report(scanned / scale),
      );
    case GenerationMode.parametric:
      return generateParametric(
        pool: request.pool,
        combinationSize: request.combinationSize,
        count: request.count,
        random: Random(request.seed),
        filter: request.filter,
        onProgress: (kept, target) => report(target == 0 ? 1 : kept / target),
      );
    case GenerationMode.reduced:
      return generateReduced(
        pool: request.pool,
        combinationSize: request.combinationSize,
        assumedHits: request.assumedHits,
        guaranteedHits: request.guaranteedHits,
        seed: request.seed,
        onProgress: report,
      );
  }
}

Future<BackgroundJob<GenerationResult>> startSystemJob(SystemRequest request) {
  return BackgroundJob.start<GenerationResult>((report) => runSystemRequest(request, report));
}
