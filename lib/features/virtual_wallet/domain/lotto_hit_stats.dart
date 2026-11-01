// lib/features/virtual_wallet/domain/lotto_hit_stats.dart
//
// Numeri con cui le schedine Lotto hanno preso qualcosa, e dove sono
// ricomparsi nelle ultime estrazioni (per pensate nuove giocate di studio).

import '../data/wallet_repository.dart';

class LottoHitNumberStat {
  const LottoHitNumberStat({
    required this.number,
    required this.payingTickets,
    required this.hitTickets,
    required this.netCents,
    required this.playedWheels,
    required this.recentByWheel,
    required this.recentAppearances,
  });

  final int number;

  /// Schedine con vincita simulata in cui questo numero era tra i centri.
  final int payingTickets;

  /// Schedine valutate in cui il numero era un centro (anche senza euro).
  final int hitTickets;
  final int netCents;

  /// Ruote delle schedine quando ha centrato (codice → conteggio).
  final Map<String, int> playedWheels;

  /// Conteggi per ruota nelle ultime estrazioni dell'archivio.
  final Map<String, int> recentByWheel;
  final List<({DateTime date, String wheelCode})> recentAppearances;

  int get recentTotal => recentByWheel.values.fold(0, (a, b) => a + b);
}

class LottoHitStatsReport {
  const LottoHitStatsReport({
    required this.numbers,
    required this.payingTicketCount,
    required this.drawDays,
  });

  final List<LottoHitNumberStat> numbers;
  final int payingTicketCount;
  final int drawDays;

  List<int> get topNumbers => [for (final n in numbers.take(10)) n.number];
}

/// Aggrega i centri delle schedine vincenti e li incrocia con le ultime uscite.
LottoHitStatsReport buildLottoHitStats({
  required List<StoredTicket> tickets,
  required Map<int, List<({DateTime date, String wheelCode})>> recent,
  int drawDays = 12,
}) {
  final paying = tickets.where((t) => t.evaluation?.isWin == true).toList();
  final hitAcc = <int, _Acc>{};
  for (final ticket in tickets) {
    final evaluation = ticket.evaluation;
    if (evaluation == null || evaluation.hitNumbers.isEmpty) continue;
    final pays = evaluation.isWin;
    for (final number in evaluation.hitNumbers) {
      final acc = hitAcc.putIfAbsent(number, _Acc.new);
      acc.hitTickets++;
      if (pays) {
        acc.payingTickets++;
        acc.netByTicket[ticket.id] = evaluation.netCents;
        acc.playedWheels[ticket.wheelCode] = (acc.playedWheels[ticket.wheelCode] ?? 0) + 1;
      }
    }
  }

  final stats = <LottoHitNumberStat>[
    for (final entry in hitAcc.entries)
      LottoHitNumberStat(
        number: entry.key,
        payingTickets: entry.value.payingTickets,
        hitTickets: entry.value.hitTickets,
        netCents: entry.value.netByTicket.values.fold(0, (a, b) => a + b),
        playedWheels: Map<String, int>.unmodifiable(entry.value.playedWheels),
        recentByWheel: _countWheels(recent[entry.key] ?? const []),
        recentAppearances: List.unmodifiable(recent[entry.key] ?? const []),
      ),
  ]..sort((a, b) {
      final byPay = b.payingTickets.compareTo(a.payingTickets);
      if (byPay != 0) return byPay;
      final byNet = b.netCents.compareTo(a.netCents);
      if (byNet != 0) return byNet;
      final byHit = b.hitTickets.compareTo(a.hitTickets);
      if (byHit != 0) return byHit;
      return a.number.compareTo(b.number);
    });

  return LottoHitStatsReport(
    numbers: stats,
    payingTicketCount: paying.length,
    drawDays: drawDays,
  );
}

Map<String, int> _countWheels(List<({DateTime date, String wheelCode})> rows) {
  final out = <String, int>{};
  for (final row in rows) {
    out[row.wheelCode] = (out[row.wheelCode] ?? 0) + 1;
  }
  return out;
}

class _Acc {
  var payingTickets = 0;
  var hitTickets = 0;
  final netByTicket = <int, int>{};
  final playedWheels = <String, int>{};
}
