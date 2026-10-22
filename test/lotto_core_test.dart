// test/lotto_core_test.dart

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/archive_parser.dart';
import 'package:lotto_intelligence/core/lotto/draw_validation.dart';
import 'package:lotto_intelligence/core/lotto/freshness.dart';
import 'package:lotto_intelligence/core/lotto/hypergeometric.dart';
import 'package:lotto_intelligence/core/network/endpoint_policy.dart';
import 'package:lotto_intelligence/features/backtesting/domain/backtest_engine.dart';
import 'package:lotto_intelligence/features/backtesting/domain/study_strategies.dart';
import 'package:lotto_intelligence/features/statistics/domain/statistics_engine.dart';
import 'package:lotto_intelligence/core/isolates/background_job.dart';
import 'package:lotto_intelligence/features/systems/domain/combinations.dart';
import 'package:lotto_intelligence/features/systems/domain/system_request.dart';

void main() {
  test('rifiuta cinquine non valide', () {
    expect(validateDrawNumbers([1, 2, 3, 4]).isValid, isFalse);
    expect(validateDrawNumbers([1, 2, 3, 4, 91]).isValid, isFalse);
    expect(validateDrawNumbers([1, 2, 3, 4, 4]).isValid, isFalse);
    expect(validateDrawNumbers([90, 1, 2, 3, 4]).isValid, isTrue);
    expect(parseDrawDate('1939/01/07'), DateTime.utc(1939, 1, 7));
    expect(parseDrawDate('1939-02-31'), isNull);
    expect(missingContestNumbers([1, 2, 4]), [3]);
    expect(missingContestNumbers([1, null]), isEmpty);
    final gaps = findWheelDateGaps({
      'BA': {DateTime.utc(2020, 1, 1), DateTime.utc(2020, 1, 3)},
      'FI': {DateTime.utc(2020, 1, 1), DateTime.utc(2020, 1, 2), DateTime.utc(2020, 1, 3)},
    });
    expect(gaps.single.wheelCode, 'BA');
    expect(gaps.single.missingDates, [DateTime.utc(2020, 1, 2)]);
  });

  test('legge il formato ufficiale e gli import manuali', () {
    const official = '1939/01/07\tBA\t58\t22\t47\t49\t69\n1939/01/07\tRN\t1\t2\t3\t4\t4\n';
    final parsed = parseOfficialArchiveText(official);
    expect(parsed.draws.first.isValid, isTrue);
    expect(parsed.draws.first.numbers, [58, 22, 47, 49, 69]);
    expect(parsed.draws[1].isValid, isFalse);

    final csv = parseManualCsv('date,wheel,n1,n2,n3,n4,n5\n1939-01-07,NAZ,1,2,3,4,5\n');
    expect(csv.draws.single.wheelCode, 'RN');

    final json = parseManualJson('{"schema":"lotto-intelligence.draws/v1","draws":[{"date":"1939-01-07","wheel":"FI","numbers":[27,57,81,43,61]}]}');
    expect(json.draws.single.isValid, isTrue);
    expect(parseManualJson('{"schema":"altro"}').draws.single.isValid, isFalse);
  });

  test('la freschezza distingue il venerdì sera dal giovedì già pubblicato', () {
    final fridayNight = DateTime(2026, 10, 9, 22, 17);
    expect(
      evaluateFreshness(
        latestDrawDate: DateTime.utc(2026, 10, 8),
        now: fridayNight,
        hasSuccessfulSync: true,
        lastAttemptFailed: false,
      ),
      SourceFreshness.delayed,
    );
    final fridayAfternoon = DateTime(2026, 10, 9, 18);
    expect(
      evaluateFreshness(
        latestDrawDate: DateTime.utc(2026, 10, 8),
        now: fridayAfternoon,
        hasSuccessfulSync: true,
        lastAttemptFailed: false,
      ),
      SourceFreshness.updated,
    );
    expect(
      evaluateFreshness(latestDrawDate: null, now: fridayNight, hasSuccessfulSync: false, lastAttemptFailed: true),
      SourceFreshness.unavailable,
    );
  });

  test('frequenza, ritardo e intervallo su una serie nota', () {
    final draws = [
      ArchivedDraw(date: DateTime.utc(2020, 1, 1), numbers: [1, 2, 3, 4, 5]),
      ArchivedDraw(date: DateTime.utc(2020, 1, 2), numbers: [1, 2, 3, 4, 6]),
      ArchivedDraw(date: DateTime.utc(2020, 1, 3), numbers: [1, 2, 3, 7, 8]),
    ];
    final stats = const StatisticsEngine().summarize(draws);
    final one = stats.statOf(1);
    final five = stats.statOf(5);
    final nine = stats.statOf(9);
    expect(one.absoluteFrequency, 3);
    expect(one.currentDelay, 0);
    expect(five.absoluteFrequency, 1);
    expect(five.currentDelay, 2);
    expect(nine.neverSeen, isTrue);
    expect(nine.currentDelay, 3);
    expect(stats.sumMean, closeTo((15 + 16 + 21) / 3, 0.001));
    expect(stats.topPairs.first.count, greaterThan(0));
    expect(pearsonPresence(draws, 5, 6), isNotNull);
  });

  test('il sistema integrale copre tutte le combinazioni e si ferma se sono troppe', () {
    final small = generateIntegral(pool: [1, 2, 3, 4, 5, 6], combinationSize: 5);
    expect(small.complete, isTrue);
    expect(small.combinations, hasLength(6));
    expect(small.coverageClaim, contains('esattamente una volta'));
    // C(40,5) = 658008 supera il limite di colonne restituite.
    final tooBig = generateIntegral(pool: [for (var n = 1; n <= 40; n++) n], combinationSize: 5);
    expect(tooBig.combinations, isEmpty);
    expect(tooBig.coverageClaim, contains('non è una copertura integrale'));
    final random = generateParametric(pool: [1, 2, 3, 4, 5, 6, 7], combinationSize: 5, count: 4, random: Random(1));
    expect(random.coverageClaim, contains('senza copertura'));
    expect(random.combinations.map((row) => row.join(',')).toSet(), hasLength(4));
    expect(hypotheticalCostCents(3, 100), 300);
  });

  test('colonne da 2 e da 10 numeri con filtro neutro', () {
    final ambi = generateIntegral(pool: [1, 2, 3], combinationSize: 2);
    expect(ambi.combinations, [
      [1, 2],
      [1, 3],
      [2, 3],
    ]);
    expect(ambi.complete, isTrue);
    final decine = generateIntegral(pool: [for (var n = 1; n <= 11; n++) n], combinationSize: 10);
    expect(decine.combinations, hasLength(11));
    expect(decine.coverageClaim, contains('esattamente una volta'));
    final ambiTutti = estimateCombinations(poolSize: 90, combinationSize: 2);
    expect(ambiTutti.total, BigInt.from(4005));
  });

  test('il ridotto dichiara la garanzia solo dopo la verifica esaustiva', () {
    final pool = [for (var n = 1; n <= 12; n++) n * 7];
    final reduced = generateReduced(pool: pool, combinationSize: 5, assumedHits: 3, guaranteedHits: 2, seed: 3);
    expect(reduced.guaranteeVerified, isTrue);
    expect(reduced.combinations.length, lessThan(792));
    expect(reduced.coverageClaim, contains('Ridotto verificato'));
    expect(
      verifyReducedColumns(pool: pool, columns: reduced.combinations, assumedHits: 3, guaranteedHits: 2),
      isTrue,
    );
    for (final column in reduced.combinations) {
      expect(column.toSet(), hasLength(5));
      expect(pool.toSet().containsAll(column), isTrue);
    }
    final again = generateReduced(pool: pool, combinationSize: 5, assumedHits: 3, guaranteedHits: 2, seed: 3);
    expect(again.combinations, reduced.combinations);

    // Una sola colonna non può garantire l'ambo su 12 numeri con 3 estratti.
    expect(
      verifyReducedColumns(pool: pool, columns: [reduced.combinations.first], assumedHits: 3, guaranteedHits: 2),
      isFalse,
    );
    final invalid = generateReduced(pool: pool, combinationSize: 5, assumedHits: 2, guaranteedHits: 3, seed: 1);
    expect(invalid.combinations, isEmpty);
    expect(invalid.guaranteeVerified, isFalse);
    expect(popCount(0x8000000000000001), 2);
    expect(popCount((1 << 60) - 1), 60);
  });

  test('il job in background riporta avanzamento e si annulla', () async {
    final request = SystemRequest(
      mode: GenerationMode.integral,
      pool: [for (var n = 1; n <= 20; n++) n],
      combinationSize: 5,
      filter: const CombinationFilter(),
      count: 0,
      assumedHits: 3,
      guaranteedHits: 2,
      seed: 1,
    );
    final job = await startSystemJob(request);
    final result = await job.result;
    expect(result.combinations, hasLength(15504));
    expect(result.complete, isTrue);

    final slow = await BackgroundJob.start<int>((report) {
      var x = 0;
      for (var i = 0; i < 1 << 40; i++) {
        x += i;
        if (i % 1000000 == 0) report(i / (1 << 40));
      }
      return x;
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    slow.cancel();
    await expectLater(slow.result, throwsA(isA<JobCancelled>()));
  });

  test('il backtest non consegna il futuro e la frequenza non vede il 90', () {
    final draws = [
      ArchivedDraw(date: DateTime.utc(2024, 1, 2), numbers: [1, 2, 3, 4, 5]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 4), numbers: [1, 2, 3, 4, 6]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 6), numbers: [1, 2, 3, 4, 7]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 9), numbers: [90, 8, 9, 10, 11]),
    ];
    final probe = _HistoryProbe();
    const BacktestEngine().run(draws: draws, strategy: probe, seed: 7, monteCarloRuns: 0);
    expect(probe.lengths, [0, 1, 2, 3]);
    for (var i = 0; i < draws.length; i++) {
      if (probe.lastDates[i] != null) {
        expect(probe.lastDates[i]!.isBefore(draws[i].date), isTrue);
      }
    }
    final report = const BacktestEngine().run(
      draws: draws,
      strategy: const FrequencyTopStrategy(),
      seed: 11,
      scoreFromIndex: 3,
      monteCarloRuns: 5,
    );
    expect(report.rows.single.proposed.contains(90), isFalse);
    expect(report.rows.single.proposed, [1, 2, 3, 4, 5]);
    expect(report.warmupDraws, 3);
    final repeat = const BacktestEngine().run(draws: draws, strategy: const RandomBaselineStrategy(), seed: 99, monteCarloRuns: 0);
    final again = const BacktestEngine().run(draws: draws, strategy: const RandomBaselineStrategy(), seed: 99, monteCarloRuns: 0);
    expect(repeat.baselineHistogram, again.baselineHistogram);
    expect(report.toJson()['monetary'], isA<Map<String, Object?>>());
    expect((report.toJson()['monetary'] as Map)['available'], isFalse);
  });

  test('i metodi classici propongono cinquine valide senza vedere il futuro', () {
    final draws = [
      ArchivedDraw(date: DateTime.utc(2024, 1, 2), numbers: [1, 2, 3, 4, 5]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 4), numbers: [10, 20, 30, 40, 50]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 6), numbers: [1, 2, 3, 4, 6]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 9), numbers: [10, 20, 30, 40, 51]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 11), numbers: [7, 8, 9, 11, 12]),
      ArchivedDraw(date: DateTime.utc(2024, 1, 13), numbers: [60, 70, 80, 90, 45]),
    ];
    for (final info in studyStrategyCatalog) {
      final strategy = info.build(3);
      for (var i = 0; i <= draws.length; i++) {
        final proposal = strategy.propose(historyBefore: draws.sublist(0, i), contestIndex: i, seed: 5);
        expect(validateDrawNumbers(proposal).isValid, isTrue, reason: '${info.id} con $i estrazioni');
      }
      final a = strategy.propose(historyBefore: draws.sublist(0, 4), contestIndex: 4, seed: 5);
      final b = strategy.propose(historyBefore: draws.sublist(0, 4), contestIndex: 4, seed: 5);
      expect(a, b, reason: '${info.id} deve essere riproducibile');
    }

    // Ritardatari: dopo le prime due estrazioni mancano da più tempo i numeri mai usciti.
    final delayed = const DelayTopStrategy().propose(historyBefore: draws.sublist(0, 2), contestIndex: 2, seed: 1);
    expect(delayed.any((n) => [1, 2, 3, 4, 5, 10, 20, 30, 40, 50].contains(n)), isFalse);

    // Spie: l'ultima estrazione è [1,2,3,4,6]; dopo [1,2,3,4,5] uscì [10,20,30,40,50].
    final spies = const SpyFollowersStrategy().propose(historyBefore: draws.sublist(0, 3), contestIndex: 3, seed: 1);
    expect(spies, [10, 20, 30, 40, 50]);

    // Diametrali di [1,2,3,4,5] sono 46..50.
    final diametral = const DiametralStrategy().propose(historyBefore: draws.sublist(0, 1), contestIndex: 1, seed: 1);
    expect(diametral, [46, 47, 48, 49, 50]);
    expect(const DiametralStrategy().propose(historyBefore: [draws.last], contestIndex: 1, seed: 1), contains(90));

    // Frequenti su finestra 2: le ultime due estrazioni [7..12] e [60,70,80,90,45] pesano 1 ciascuno.
    final window = const WindowFrequencyStrategy(2).propose(historyBefore: draws, contestIndex: 6, seed: 1);
    expect(window, [7, 8, 9, 11, 12]);

    final decades = const BalancedDecadesStrategy().propose(historyBefore: draws, contestIndex: 0, seed: 1);
    expect(decades.map((n) => (n - 1) ~/ 10).toSet(), hasLength(5));

    final comparison = compareStrategies(draws: draws, seed: 3, scoreFromIndex: 3, window: 3);
    expect(comparison.map((row) => row.info.id).toSet(), studyStrategyCatalog.map((info) => info.id).toSet());
    expect(comparison.every((row) => row.report.scoredDraws == 3), isTrue);
    expect(multipleComparisonWarning(comparison.length), contains('out-of-sample'));
  });

  test('endpoint HTTP solo in rete privata', () {
    expect(isAllowedAiEndpoint(Uri.parse('https://api.openai.com/v1')), isTrue);
    expect(isAllowedAiEndpoint(Uri.parse('http://127.0.0.1:11434')), isTrue);
    expect(isAllowedAiEndpoint(Uri.parse('http://192.168.1.20:11434')), isTrue);
    expect(isAllowedAiEndpoint(Uri.parse('http://example.com')), isFalse);
  });

  test('la probabilità teorica di un numero è 5/90', () {
    expect(singleNumberProbability, closeTo(5 / 90, 1e-12));
    final p = hypergeometricPmf(population: 90, successStates: 5, drawSize: 5, observed: 0);
    expect(p, greaterThan(0));
    expect(p, lessThan(1));
  });
}

class _HistoryProbe implements StudyStrategy {
  final lengths = <int>[];
  final lastDates = <DateTime?>[];

  @override
  String get id => 'probe';

  @override
  String get version => '1';

  @override
  List<int> propose({required List<ArchivedDraw> historyBefore, required int contestIndex, required int seed}) {
    lengths.add(historyBefore.length);
    lastDates.add(historyBefore.isEmpty ? null : historyBefore.last.date);
    return const [1, 2, 3, 4, 5];
  }
}
