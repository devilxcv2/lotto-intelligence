// lib/features/superenalotto/domain/se_prize_estimates.dart
//
// Quote medie attese pubblicate da Sisal (totalizzatore): non sono premi fissi.
// Usate solo per studio, per capire «quanto avrei vinto circa».

import '../../../core/settings/app_settings.dart';
import 'superenalotto_studio.dart';

/// Costo di una combinazione SuperEnalotto in studio.
const int seCombinationCostCents = 100;

/// Stima in centesimi da quote medie attese Sisal (senza SuperStar).
/// `null` = jackpot / non stimabile con cifra fissa.
int? seCategoryEstimateCents(String category) => switch (category) {
      'sei' => null,
      'cinque_jolly' => 62000000, // 620.000 €
      'cinque' => 3200000, // 32.000 €
      'quattro' => 30000, // 300 €
      'tre' => 2500, // 25 €
      'due' => 500, // 5 €
      _ => 0,
    };

/// SuperStar: per 0/1/2 punti Sisal indica premi fissi tipici; sopra è moltiplicatore / montepremi.
int seSuperStarExtraCents({required int hits, required bool matched}) {
  if (!matched) return 0;
  return switch (hits) {
    0 => 500, // 5 €
    1 => 1000, // 10 €
    2 => 10000, // 100 €
    // 3+ : stima grezza = 100× la categoria base (ordine di grandezza codice vincita)
    _ => 0,
  };
}

class SeMoneyEstimate {
  const SeMoneyEstimate({
    required this.label,
    required this.estimatedCents,
    required this.isJackpot,
    required this.disclaimer,
  });

  final String label;
  final int estimatedCents;
  final bool isJackpot;
  final String disclaimer;

  String get shortEuro {
    if (isJackpot) return 'Jackpot';
    if (estimatedCents <= 0) return '—';
    return formatEuro(estimatedCents);
  }
}

SeMoneyEstimate estimateSeWin(SeMatch match) {
  if (!match.isCategoryWin && !match.superstarMatched) {
    return const SeMoneyEstimate(
      label: 'Nessuna categoria',
      estimatedCents: 0,
      isJackpot: false,
      disclaimer: 'Nessun premio di categoria. Le quote medie Sisal non si applicano.',
    );
  }
  if (match.category == 'sei') {
    return SeMoneyEstimate(
      label: match.superstarMatched ? 'Sei + SuperStar (Jackpot)' : 'Sei (Jackpot)',
      estimatedCents: 0,
      isJackpot: true,
      disclaimer: 'Il 6 è jackpot a totalizzatore: non c’è un importo fisso da simulare.',
    );
  }

  final base = seCategoryEstimateCents(match.category) ?? 0;
  final int cents;
  if (match.superstarMatched && match.hits >= 3 && base > 0) {
    // Ordine di grandezza tipico dei codici vincita Sisal: ×100 sulla categoria.
    cents = base * 100;
  } else if (match.isCategoryWin) {
    cents = base + seSuperStarExtraCents(hits: match.hits, matched: match.superstarMatched);
  } else {
    cents = seSuperStarExtraCents(hits: match.hits, matched: match.superstarMatched);
  }

  return SeMoneyEstimate(
    label: match.superstarMatched ? '${match.label} + SuperStar' : match.label,
    estimatedCents: cents,
    isJackpot: false,
    disclaimer: 'Stima da quote medie attese Sisal (totalizzatore). L’importo reale del concorso può essere diverso.',
  );
}

String sePrizeGuideLines() => [
      'Quote medie attese Sisal (studio, non premio fisso):',
      '· 6 → Jackpot',
      '· 5+Jolly → ~620.000 €',
      '· 5 → ~32.000 €',
      '· 4 → ~300 €',
      '· 3 → ~25 €',
      '· 2 → ~5 €',
      'SuperStar 0/1/2: tipici 5 / 10 / 100 €; da 3 in su spesso ×100 sulla categoria.',
    ].join('\n');
