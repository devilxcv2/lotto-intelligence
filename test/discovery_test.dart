// test/discovery_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/hypergeometric.dart';
import 'package:lotto_intelligence/features/discovery/domain/trend_search.dart';
import 'package:lotto_intelligence/features/statistics/domain/statistics_engine.dart';

void main() {
  test('la probabilità equa di un centro non dipende dal trend', () {
    final five = fairChanceOfAtLeastOneHit(5);
    expect(five, greaterThan(0.24));
    expect(five, lessThan(0.27));
    expect(fairChanceOfAtLeastOneHit(0), 0);
    expect(5 * singleNumberProbability, closeTo(0.2778, 0.001));
  });

  test('la frequenza recente legge solo il blocco delle ultime settimane', () {
    final draws = [
      for (var i = 0; i < 40; i++)
        ArchivedDraw(
          date: DateTime.utc(2024, 1, 2).add(Duration(days: i)),
          numbers: i < 24 ? const [1, 2, 3, 4, 5] : const [6, 7, 8, 9, 10],
        ),
    ];
    final report = searchTrends(draws: draws, weeks: 4, seed: 7, weekday: DateTime.tuesday);
    final frequency = report.rules.singleWhere((rule) => rule.id == 'freq-4');
    expect(frequency.proposal, [6, 7, 8, 9, 10]);
    final six = report.trends.singleWhere((trend) => trend.number == 6);
    expect(six.slope, greaterThan(0));
    expect(six.compatibleWithFair, isFalse);
    expect(report.system, isNotNull);
    expect(report.system!.guaranteeVerified, isTrue);
    expect(report.limitation, contains('5/90'));
  });

  test('il giorno della settimana non usa gli altri giorni', () {
    final draws = <ArchivedDraw>[];
    var day = DateTime.utc(2024, 1, 2);
    while (draws.length < 48) {
      final numbers = day.weekday == DateTime.tuesday ? const [11, 21, 31, 41, 51] : const [12, 22, 32, 42, 52];
      if (day.weekday == DateTime.tuesday || day.weekday == DateTime.thursday) {
        draws.add(ArchivedDraw(date: day, numbers: numbers));
      }
      day = day.add(const Duration(days: 1));
    }
    final report = searchTrends(draws: draws, weeks: 4, seed: 3, weekday: DateTime.tuesday);
    final rule = report.rules.singleWhere((item) => item.id == 'weekday');
    expect(rule.proposal, contains(11));
    expect(rule.proposal, isNot(contains(12)));
  });

  test('il confronto non legge l\'estrazione che sta valutando', () {
    final draws = [
      for (var i = 0; i < 36; i++)
        ArchivedDraw(
          date: DateTime.utc(2024, 1, 2).add(Duration(days: i)),
          numbers: i < 35 ? const [1, 2, 3, 4, 5] : const [90, 89, 88, 87, 86],
        ),
    ];
    final report = searchTrends(draws: draws, weeks: 4, seed: 1, weekday: DateTime.tuesday);
    final frequency = report.rules.singleWhere((rule) => rule.id == 'freq-4');
    expect(frequency.meanHits, greaterThan(3));
    expect(frequency.proposal, isNot(contains(90)));
  });
}
