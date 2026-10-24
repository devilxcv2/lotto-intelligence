import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/prize_table.dart';
import 'package:lotto_intelligence/core/settings/app_settings.dart';
import 'package:lotto_intelligence/features/virtual_wallet/domain/auto_study.dart';

void main() {
  test('le poste suggerite mettono ambo e terno a 1 euro', () {
    expect(suggestedAutoStakes[LottoSorte.ambo], 100);
    expect(suggestedAutoStakes[LottoSorte.terno], 100);
    expect(autoStudyStakeTotal(suggestedAutoStakes), 200);
    expect(autoStudyStakesProblem(suggestedAutoStakes), isNull);
  });

  test('senza poste la schedina automatica non è valida', () {
    expect(autoStudyStakesProblem(const {}), isNotNull);
    expect(autoStudyStakesFrom(estrattoCents: 0, amboCents: 0, ternoCents: 0, quaternaCents: 0, cinquinaCents: 0), isEmpty);
  });

  test('AppSettings espone solo le sorti con posta', () {
    final settings = AppSettings.initial.withSuggestedAutoStakes();
    expect(settings.autoStudyStakes.keys, containsAll([LottoSorte.ambo, LottoSorte.terno]));
    expect(settings.autoStudyStakes.containsKey(LottoSorte.cinquina), isFalse);
  });
}
