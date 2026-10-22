// lib/core/lotto/prize_table.dart

import 'hypergeometric.dart';

/// Tabella premi del Gioco del Lotto per giocata su una singola ruota.
///
/// Fonti verificate il 2026-10-10:
/// - ADM, «Come si gioca» (adm.gov.it/portale/monopoli/giochi/gioco-del-lotto/lotto_g/lotto_gioca):
///   posta moltiplicata per 11,233 (estratto), 250 (ambo), 4.500 (terno),
///   120.000 (quaterna), 6.000.000 (cinquina); giocata minima 1 €, incrementi
///   di 0,50 €, massima 200 €; vincita massima 6.000.000 € per scontrino;
///   ritenuta dell'8% sulle vincite.
/// - ADM, «Come riscuotere»: ritenuta 8% ai sensi dell'art. 6 c. 2 del
///   d.l. 24 aprile 2017 n. 50, convertito dalla l. 21 giugno 2017 n. 96.
/// - lotto-italia.it, «Premi del Lotto»: con più numeri giocati il premio
///   si divide per le combinazioni della sorte (es. ambo su 5 numeri 25,00 €);
///   la ruota TUTTE non comprende la Nazionale e divide i premi per 10.
///
/// Non sono modellati l'estratto determinato, l'ambetto e il Numero Oro.
enum LottoSorte {
  estratto(1, 11.233, 'Estratto'),
  ambo(2, 250, 'Ambo'),
  terno(3, 4500, 'Terno'),
  quaterna(4, 120000, 'Quaterna'),
  cinquina(5, 6000000, 'Cinquina');

  const LottoSorte(this.hitsRequired, this.coefficient, this.label);

  final int hitsRequired;

  /// Moltiplicatore della posta per euro giocato su una ruota, con tutti
  /// i numeri giocati pari alla sorte.
  final double coefficient;
  final String label;
}

const int minTicketStakeCents = 100;
const int maxTicketStakeCents = 20000;
const int stakeStepCents = 50;
const int maxTicketWinCents = 600000000;
const double withholdingRate = 0.08;
const int maxTicketNumbers = 10;

/// Codice usato per la giocata su tutte le dieci ruote tranne la Nazionale.
const String allWheelsCode = 'TUTTE';

String? stakeProblem(int totalStakeCents) {
  if (totalStakeCents < minTicketStakeCents) return 'La giocata minima è di 1,00 €.';
  if (totalStakeCents > maxTicketStakeCents) return 'La giocata massima è di 200,00 €.';
  if (totalStakeCents % stakeStepCents != 0) return 'La posta cresce a passi di 0,50 €.';
  return null;
}

/// Premio lordo in centesimi per una sorte, dati numeri giocati e centri
/// su una ruota. Più centri della sorte producono più combinazioni vincenti.
int grossPrizeCents({
  required LottoSorte sorte,
  required int numbersPlayed,
  required int hits,
  required int stakeCents,
  int wheelsCovered = 1,
}) {
  if (stakeCents <= 0 || hits < sorte.hitsRequired || numbersPlayed < sorte.hitsRequired) return 0;
  final winning = binomial(hits, sorte.hitsRequired).toDouble();
  final possible = binomial(numbersPlayed, sorte.hitsRequired).toDouble();
  final gross = stakeCents * sorte.coefficient * winning / possible / wheelsCovered;
  return gross.round();
}

/// Premio lordo per 1 € con tutti i centri possibili, come nella tabella
/// pubblicata (es. ambo su 5 numeri: 25,00 €).
int tablePrizeCentsPerEuro({required LottoSorte sorte, required int numbersPlayed}) {
  return grossPrizeCents(sorte: sorte, numbersPlayed: numbersPlayed, hits: sorte.hitsRequired, stakeCents: 100);
}

int applyTicketCap(int grossCents) => grossCents > maxTicketWinCents ? maxTicketWinCents : grossCents;

/// Ritenuta dell'8% sull'importo lordo, arrotondata al centesimo.
int netFromGrossCents(int grossCents) => (grossCents * (1 - withholdingRate)).round();

class SorteOutcome {
  const SorteOutcome({required this.sorte, required this.stakeCents, required this.grossCents});

  final LottoSorte sorte;
  final int stakeCents;
  final int grossCents;
}

class TicketOutcome {
  const TicketOutcome({
    required this.hitsByWheel,
    required this.bestHits,
    required this.perSorte,
    required this.grossCents,
    required this.netCents,
    required this.stakeCents,
  });

  /// Centri su ciascuna ruota valutata (una, oppure le dieci di TUTTE).
  final Map<String, int> hitsByWheel;
  final int bestHits;
  final List<SorteOutcome> perSorte;
  final int grossCents;
  final int netCents;
  final int stakeCents;

  int get balanceCents => netCents - stakeCents;
}

/// Valuta una schedina contro i numeri estratti sulle ruote coperte.
/// [drawnByWheel] contiene solo le ruote coperte dalla giocata.
TicketOutcome evaluateTicket({
  required List<int> played,
  required Map<LottoSorte, int> stakes,
  required Map<String, List<int>> drawnByWheel,
}) {
  final hitsByWheel = <String, int>{};
  for (final entry in drawnByWheel.entries) {
    final drawn = entry.value.toSet();
    hitsByWheel[entry.key] = played.where(drawn.contains).length;
  }
  final wheels = drawnByWheel.length;
  final perSorte = <SorteOutcome>[];
  var gross = 0;
  for (final sorte in LottoSorte.values) {
    final stake = stakes[sorte] ?? 0;
    if (stake <= 0) continue;
    var sorteGross = 0;
    for (final hits in hitsByWheel.values) {
      sorteGross += grossPrizeCents(
        sorte: sorte,
        numbersPlayed: played.length,
        hits: hits,
        stakeCents: stake,
        wheelsCovered: wheels,
      );
    }
    perSorte.add(SorteOutcome(sorte: sorte, stakeCents: stake, grossCents: sorteGross));
    gross += sorteGross;
  }
  gross = applyTicketCap(gross);
  final totalStake = stakes.values.fold<int>(0, (sum, value) => sum + value);
  return TicketOutcome(
    hitsByWheel: hitsByWheel,
    bestHits: hitsByWheel.values.fold<int>(0, (best, value) => value > best ? value : best),
    perSorte: perSorte,
    grossCents: gross,
    netCents: netFromGrossCents(gross),
    stakeCents: totalStake,
  );
}

/// «E se avessi puntato…»: per ogni sorte, il netto che la stessa schedina
/// avrebbe reso con [stakeCents] su quella sola sorte, dati i centri reali.
List<SorteOutcome> whatIfBySorte({
  required int numbersPlayed,
  required Map<String, int> hitsByWheel,
  required int stakeCents,
}) {
  final wheels = hitsByWheel.length;
  return [
    for (final sorte in LottoSorte.values)
      if (numbersPlayed >= sorte.hitsRequired)
        SorteOutcome(
          sorte: sorte,
          stakeCents: stakeCents,
          grossCents: applyTicketCap(hitsByWheel.values.fold<int>(
            0,
            (sum, hits) =>
                sum +
                grossPrizeCents(
                  sorte: sorte,
                  numbersPlayed: numbersPlayed,
                  hits: hits,
                  stakeCents: stakeCents,
                  wheelsCovered: wheels,
                ),
          )),
        ),
  ];
}
