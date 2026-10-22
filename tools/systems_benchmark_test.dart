// tools/systems_benchmark_test.dart
//
// Tempi indicativi dei generatori su configurazioni grandi. Non fa parte
// della suite: flutter test tools/systems_benchmark_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/features/systems/domain/combinations.dart';

void main() {
  test('sistemi grandi', () {
    final clock = Stopwatch()..start();
    final integral = generateIntegral(pool: [for (var n = 1; n <= 30; n++) n], combinationSize: 5);
    _log('integrale 30 in cinquine', integral, clock);

    final filtered = generateIntegral(
      pool: [for (var n = 1; n <= 45; n++) n],
      combinationSize: 5,
      filter: const CombinationFilter(minEven: 2, maxEven: 3, minSum: 100, maxSum: 130, maxConsecutiveRun: 2, maxPerDecade: 2),
    );
    _log('45 numeri filtrati (1221759 esaminate)', filtered, clock);

    for (final (pool, k, m, t) in [(20, 5, 3, 2), (30, 5, 3, 2), (20, 5, 4, 3), (30, 6, 4, 3), (20, 5, 5, 4), (40, 5, 3, 2), (25, 10, 5, 4), (60, 6, 4, 3), (60, 10, 4, 2)]) {
      final result = generateReduced(
        pool: [for (var n = 1; n <= pool; n++) n],
        combinationSize: k,
        assumedHits: m,
        guaranteedHits: t,
        seed: 1,
      );
      expect(result.guaranteeVerified, isTrue);
      _log('ridotto $pool numeri, colonne da $k, $m estratti -> $t', result, clock);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}

void _log(String label, GenerationResult result, Stopwatch clock) {
  // ignore: avoid_print
  print('$label: ${result.combinations.length} colonne su ${result.estimate.total} integrali, ${clock.elapsedMilliseconds} ms');
  clock.reset();
}
