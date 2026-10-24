// lib/features/virtual_wallet/domain/auto_study.dart

import '../../../core/lotto/prize_table.dart';

/// Metodo con cui l'app compone da sola una schedina di studio.
enum AutoStudyMethod {
  zoppe,
  delays,
  frequent,
}

extension AutoStudyMethodLabel on AutoStudyMethod {
  String get label => switch (this) {
        AutoStudyMethod.zoppe => 'Sistemone Zoppe',
        AutoStudyMethod.delays => 'Ritardatari',
        AutoStudyMethod.frequent => 'Frequenti',
      };

  /// Prefisso della nota / origine in database (filtro elenco «Auto»).
  String get noteTag => switch (this) {
        AutoStudyMethod.zoppe => 'Auto · Zoppe',
        AutoStudyMethod.delays => 'Auto · Ritardi',
        AutoStudyMethod.frequent => 'Auto · Frequenti',
      };
}

bool isAutoStudyNote(String? note) => note != null && note.startsWith('Auto ·');

/// Poste consigliate per lo studio automatico (passi da 0,50 €; totale ≥ 1 €).
const Map<LottoSorte, int> suggestedAutoStakes = {
  LottoSorte.estratto: 0,
  LottoSorte.ambo: 100,
  LottoSorte.terno: 100,
  LottoSorte.quaterna: 0,
  LottoSorte.cinquina: 0,
};

/// Solo le sorti con posta > 0.
Map<LottoSorte, int> autoStudyStakesFrom({
  required int estrattoCents,
  required int amboCents,
  required int ternoCents,
  required int quaternaCents,
  required int cinquinaCents,
}) {
  final raw = <LottoSorte, int>{
    LottoSorte.estratto: estrattoCents,
    LottoSorte.ambo: amboCents,
    LottoSorte.terno: ternoCents,
    LottoSorte.quaterna: quaternaCents,
    LottoSorte.cinquina: cinquinaCents,
  };
  return {
    for (final entry in raw.entries)
      if (entry.value > 0) entry.key: entry.value,
  };
}

int autoStudyStakeTotal(Map<LottoSorte, int> stakes) =>
    stakes.values.fold(0, (sum, value) => sum + value);

String? autoStudyStakesProblem(Map<LottoSorte, int> stakes) {
  if (stakes.isEmpty) return 'Scegli almeno una sorte con posta (es. ambo 1 €).';
  return stakeProblem(autoStudyStakeTotal(stakes));
}

AutoStudyMethod? parseAutoStudyMethod(String? raw) {
  return switch (raw) {
    'delays' => AutoStudyMethod.delays,
    'frequent' => AutoStudyMethod.frequent,
    'zoppe' => AutoStudyMethod.zoppe,
    _ => null,
  };
}
