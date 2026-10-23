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

  /// Prefisso della nota in database (filtro elenco «Auto»).
  String get noteTag => switch (this) {
        AutoStudyMethod.zoppe => 'Auto · Zoppe',
        AutoStudyMethod.delays => 'Auto · Ritardi',
        AutoStudyMethod.frequent => 'Auto · Frequenti',
      };
}

bool isAutoStudyNote(String? note) => note != null && note.startsWith('Auto ·');

/// Posta di default per le schedine automatiche: 1 € sull'ambo.
Map<LottoSorte, int> autoStudyStakes({int amboCents = 100}) => {LottoSorte.ambo: amboCents};

AutoStudyMethod? parseAutoStudyMethod(String? raw) {
  return switch (raw) {
    'delays' => AutoStudyMethod.delays,
    'frequent' => AutoStudyMethod.frequent,
    'zoppe' => AutoStudyMethod.zoppe,
    _ => null,
  };
}
