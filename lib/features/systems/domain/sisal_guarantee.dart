// lib/features/systems/domain/sisal_guarantee.dart

import 'dart:math';

import '../../../core/lotto/hypergeometric.dart';
import '../../../core/settings/app_settings.dart';
import 'combinations.dart';

/// Livelli di garanzia stile maschera Sisal (G5 / G4 / G3).
///
/// Se **tutti** gli estratti cadono nel pronostico, almeno una colonna ne
/// contiene [hits] o più. Non alza la probabilità che quei numeri escano.
enum SisalGuarantee {
  g5(5, 'G5'),
  g4(4, 'G4'),
  g3(3, 'G3');

  const SisalGuarantee(this.hits, this.label);

  final int hits;
  final String label;

  String get longLabel => switch (this) {
        SisalGuarantee.g5 => 'Garanzia del 5',
        SisalGuarantee.g4 => 'Garanzia del 4',
        SisalGuarantee.g3 => 'Garanzia del 3',
      };
}

const int lottoDrawnSize = 5;
const int superenalottoDrawnSize = 6;

/// Posta tipica SuperEnalotto: 1 € a colonna.
const int seUnitCostCents = 100;

/// Intervalli pannello A come nella bacheca Sisal SE (senza ruotanti).
({int min, int max}) sisalSePoolRange(SisalGuarantee g) => switch (g) {
      SisalGuarantee.g5 => (min: 10, max: 12),
      SisalGuarantee.g4 => (min: 13, max: 19),
      SisalGuarantee.g3 => (min: 20, max: 33),
    };

/// Per il Lotto di studio: range consigliato (non è un catalogo Sisal ufficiale).
({int min, int max}) sisalLottoPoolRange(SisalGuarantee g) => switch (g) {
      SisalGuarantee.g5 => (min: 7, max: 15),
      SisalGuarantee.g4 => (min: 8, max: 20),
      SisalGuarantee.g3 => (min: 10, max: 28),
    };

({int assumedHits, int guaranteedHits}) sisalReducedParams({
  required SisalGuarantee guarantee,
  required int drawnSize,
  required int combinationSize,
}) {
  final assumed = drawnSize;
  final guaranteed = min(guarantee.hits, min(assumed, combinationSize));
  return (assumedHits: assumed, guaranteedHits: max(2, guaranteed));
}

String sisalHint({
  required SisalGuarantee guarantee,
  required int drawnSize,
  required int combinationSize,
}) {
  final g = min(guarantee.hits, min(drawnSize, combinationSize));
  final game = drawnSize == 6 ? 'SuperEnalotto' : 'Lotto';
  final sorte = switch (g) {
    3 => 'terno / 3',
    4 => 'quaterna / 4',
    5 => 'cinquina / 5',
    _ => '$g',
  };
  return 'Se i $drawnSize estratti del $game sono tutti nel pronostico, '
      'almeno una colonna da $combinationSize ne contiene $g o più ($sorte).';
}

/// Riepilogo spesa stile Sisal: colonne, posta, totale, confronto integrale, consiglio.
class SisalSpendSummary {
  const SisalSpendSummary({
    required this.columns,
    required this.unitCostCents,
    required this.totalCents,
    required this.integralColumns,
    required this.integralCents,
    required this.advice,
    required this.overContestBudget,
    required this.overMonthlyBudget,
  });

  final int columns;
  final int unitCostCents;
  final int totalCents;
  final int integralColumns;
  final int integralCents;
  final String advice;
  final bool overContestBudget;
  final bool overMonthlyBudget;

  int get savedCents => max(0, integralCents - totalCents);
}

SisalSpendSummary buildSisalSpendSummary({
  required int columns,
  required int combinationSize,
  required int poolSize,
  required int unitCostCents,
  required AppSettings settings,
}) {
  final integral = estimateCombinations(poolSize: poolSize, combinationSize: combinationSize).total;
  final integralCols = integral > BigInt.from(1 << 30) ? 1 << 30 : integral.toInt();
  final total = hypotheticalCostCents(columns, unitCostCents);
  final integralCost = hypotheticalCostCents(integralCols, unitCostCents);
  final overContest = settings.budgetMode.enforcesLimits && total > settings.contestBudgetCents;
  final overMonth = settings.budgetMode.enforcesLimits && total > settings.monthlyBudgetCents;

  final buffer = StringBuffer();
  if (columns == 0) {
    buffer.write('Nessuna colonna: non spendi nulla finché non sviluppi il sistema.');
  } else {
    buffer.write(
      'Spendi ${formatEuro(total)} per $columns colonne '
      '(${formatEuro(unitCostCents)} ciascuna). ',
    );
    if (integralCols > columns) {
      buffer.write(
        'L\'integrale avrebbe $integralCols colonne (${formatEuro(integralCost)}): '
        'risparmi ${formatEuro(max(0, integralCost - total))} sulla stessa garanzia combinatoria. ',
      );
    }
    if (overContest) {
      buffer.write(
        'Attenzione: supera il budget concorso (${formatEuro(settings.contestBudgetCents)}). '
        'Riduci i numeri, passa a una garanzia più bassa (G3) o alza il limite in Soldi. ',
      );
    } else if (overMonth) {
      buffer.write(
        'Attenzione: supera il budget mensile (${formatEuro(settings.monthlyBudgetCents)}). ',
      );
    } else if (total <= settings.contestBudgetCents && settings.budgetMode.enforcesLimits) {
      buffer.write('Entro il budget concorso: puoi “spendere” in simulazione senza sforare. ');
    } else if (total > 5000) {
      buffer.write('Spesa alta: valuta G3 o meno numeri se vuoi contenere il laboratorio. ');
    } else {
      buffer.write('Posta contenuta per uno studio: registra le colonne solo se ti servono. ');
    }
    buffer.write('Nessun acquisto reale: i soldi restano simulati.');
  }

  return SisalSpendSummary(
    columns: columns,
    unitCostCents: unitCostCents,
    totalCents: total,
    integralColumns: integralCols,
    integralCents: integralCost,
    advice: buffer.toString().trim(),
    overContestBudget: overContest,
    overMonthlyBudget: overMonth,
  );
}

/// Costi tipici Sisal SE (pannello A, 0 ruotanti) per confronto didattico.
/// Fonte: tabelle pubbliche sistemi ridotti SuperEnalotto (€1/colonna).
const Map<SisalGuarantee, Map<int, int>> sisalSeReferenceColumns = {
  SisalGuarantee.g5: {10: 14, 11: 22, 12: 38},
  SisalGuarantee.g4: {13: 10, 14: 14, 15: 19, 16: 26, 17: 34},
  SisalGuarantee.g3: {20: 10, 21: 12, 22: 14, 23: 16, 24: 19, 25: 22, 26: 26, 27: 30, 28: 34, 29: 38, 30: 43},
};

int? sisalSeReferenceCostCents(SisalGuarantee g, int poolSize) {
  final cols = sisalSeReferenceColumns[g]?[poolSize];
  return cols == null ? null : cols * seUnitCostCents;
}

/// Binomiale C(n,k) come intero se entra in int, altrimenti null.
int? binomialAsInt(int n, int k) {
  final v = binomial(n, k);
  if (v > BigInt.from(1 << 30)) return null;
  return v.toInt();
}
