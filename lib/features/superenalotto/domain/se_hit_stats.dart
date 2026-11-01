// lib/features/superenalotto/domain/se_hit_stats.dart

import '../../../core/lotto/wheel_catalog.dart';
import '../data/se_ticket_repository.dart';
import '../data/superenalotto_repository.dart';
import 'se_prize_estimates.dart';

class SeHitNumberStat {
  const SeHitNumberStat({
    required this.number,
    required this.categoryTickets,
    required this.estimatedCents,
    required this.asMainHits,
    required this.asJolly,
    required this.asSuperstar,
    required this.recentMain,
    required this.recentJolly,
    required this.recentSuperstar,
  });

  final int number;
  final int categoryTickets;
  final int estimatedCents;
  final int asMainHits;
  final int asJolly;
  final int asSuperstar;
  final int recentMain;
  final int recentJolly;
  final int recentSuperstar;

  int get recentTotal => recentMain + recentJolly + recentSuperstar;
}

class SeHitStatsReport {
  const SeHitStatsReport({
    required this.numbers,
    required this.categoryTicketCount,
    required this.lookbackDraws,
  });

  final List<SeHitNumberStat> numbers;
  final int categoryTicketCount;
  final int lookbackDraws;

  List<int> get topNumbers => [for (final n in numbers.take(10)) n.number];
}

/// Numeri con cui le schedine SE hanno preso una categoria (o SuperStar),
/// incrociati con le ultime uscite dell'archivio.
SeHitStatsReport buildSeHitStats({
  required List<SeTicket> tickets,
  required List<SuperenalottoDraw> historyChronological,
  int lookbackDraws = 12,
}) {
  final window = historyChronological.length <= lookbackDraws
      ? historyChronological
      : historyChronological.sublist(historyChronological.length - lookbackDraws);
  final recentMain = <int, int>{};
  final recentJolly = <int, int>{};
  final recentStar = <int, int>{};
  for (final draw in window) {
    for (final n in draw.numbers) {
      recentMain[n] = (recentMain[n] ?? 0) + 1;
    }
    recentJolly[draw.jolly] = (recentJolly[draw.jolly] ?? 0) + 1;
    recentStar[draw.superstar] = (recentStar[draw.superstar] ?? 0) + 1;
  }

  final byDay = <String, SuperenalottoDraw>{
    for (final draw in historyChronological) formatIsoDate(draw.date.toUtc()): draw,
  };

  final categoryTickets = tickets.where((t) => t.match?.isCategoryWin == true).toList();
  final acc = <int, _SeAcc>{};

  for (final ticket in tickets) {
    final match = ticket.match;
    if (match == null) continue;
    if (!match.isCategoryWin && !match.superstarMatched) continue;
    final estimate = estimateSeWin(match).estimatedCents;
    final draw = byDay[formatIsoDate(ticket.targetDrawDate.toUtc())];
    final hitMain = draw == null
        ? <int>{}
        : ticket.numbers.toSet().intersection(draw.numbers.toSet());

    if (match.isCategoryWin && hitMain.isNotEmpty) {
      for (final n in hitMain) {
        final row = acc.putIfAbsent(n, _SeAcc.new);
        row.categoryTickets++;
        row.asMain++;
        row.netByTicket[ticket.id] = estimate;
      }
      if (match.jollyMatched && draw != null) {
        final row = acc.putIfAbsent(draw.jolly, _SeAcc.new);
        row.asJolly++;
        row.netByTicket.putIfAbsent(ticket.id, () => estimate);
      }
    }
    if (match.superstarMatched && ticket.superstar != null) {
      final row = acc.putIfAbsent(ticket.superstar!, _SeAcc.new);
      if (!match.isCategoryWin) row.categoryTickets++;
      row.asSuperstar++;
      row.netByTicket.putIfAbsent(ticket.id, () => estimate);
    }
  }

  final stats = <SeHitNumberStat>[
    for (final entry in acc.entries)
      SeHitNumberStat(
        number: entry.key,
        categoryTickets: entry.value.categoryTickets,
        estimatedCents: entry.value.netByTicket.values.fold(0, (a, b) => a + b),
        asMainHits: entry.value.asMain,
        asJolly: entry.value.asJolly,
        asSuperstar: entry.value.asSuperstar,
        recentMain: recentMain[entry.key] ?? 0,
        recentJolly: recentJolly[entry.key] ?? 0,
        recentSuperstar: recentStar[entry.key] ?? 0,
      ),
  ]..sort((a, b) {
      final byCat = b.categoryTickets.compareTo(a.categoryTickets);
      if (byCat != 0) return byCat;
      final byEst = b.estimatedCents.compareTo(a.estimatedCents);
      if (byEst != 0) return byEst;
      return a.number.compareTo(b.number);
    });

  return SeHitStatsReport(
    numbers: stats,
    categoryTicketCount: categoryTickets.length,
    lookbackDraws: window.length,
  );
}

class _SeAcc {
  var categoryTickets = 0;
  var asMain = 0;
  var asJolly = 0;
  var asSuperstar = 0;
  final netByTicket = <int, int>{};
}
