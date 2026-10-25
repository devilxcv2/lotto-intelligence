// lib/features/virtual_wallet/domain/study_review.dart

import '../../../core/settings/app_settings.dart';
import '../data/wallet_repository.dart';
import 'auto_study.dart';

/// Riepilogo di un metodo (Zoppe, ritardi, mirata…) sulle schedine già valutate.
class MethodScore {
  const MethodScore({
    required this.key,
    required this.label,
    required this.tickets,
    required this.wins,
    required this.hitsSum,
    required this.stakedCents,
    required this.netCents,
  });

  final String key;
  final String label;
  final int tickets;
  final int wins;
  final int hitsSum;
  final int stakedCents;
  final int netCents;

  double get avgHits => tickets == 0 ? 0 : hitsSum / tickets;
  int get balanceCents => netCents - stakedCents;
}

/// Lettura didattica di una schedina chiusa: cosa ha centrato e perché non è “sbagliato il sistema”.
class TicketLesson {
  const TicketLesson({
    required this.ticketId,
    required this.title,
    required this.headline,
    required this.body,
    required this.hitNumbers,
    required this.missedNumbers,
    required this.balanceCents,
  });

  final int ticketId;
  final String title;
  final String headline;
  final String body;
  final List<int> hitNumbers;
  final List<int> missedNumbers;
  final int balanceCents;
}

String _methodKey(StoredTicket ticket) {
  final note = ticket.note ?? '';
  if (isAutoStudyNote(note)) {
    for (final method in AutoStudyMethod.values) {
      if (note == method.noteTag || note.startsWith('${method.noteTag}.')) return method.noteTag;
    }
    return 'Auto';
  }
  if (note.startsWith('Mirata ·')) {
    final part = note.split('.').first;
    return part;
  }
  if (note.toLowerCase().contains('zoppe')) return 'Zoppe';
  return 'Manuale';
}

String _methodLabel(String key) {
  if (key.startsWith('Auto ·')) return key;
  if (key.startsWith('Mirata ·')) return key;
  return key;
}

List<MethodScore> scoreByMethod(List<StoredTicket> tickets) {
  final map = <String, MethodScore>{};
  for (final ticket in tickets) {
    if (ticket.isOpen || ticket.isLegacy || ticket.evaluation == null) continue;
    final key = _methodKey(ticket);
    final prev = map[key];
    final eval = ticket.evaluation!;
    map[key] = MethodScore(
      key: key,
      label: _methodLabel(key),
      tickets: (prev?.tickets ?? 0) + 1,
      wins: (prev?.wins ?? 0) + (eval.isWin ? 1 : 0),
      hitsSum: (prev?.hitsSum ?? 0) + eval.hits,
      stakedCents: (prev?.stakedCents ?? 0) + ticket.stakeCents,
      netCents: (prev?.netCents ?? 0) + eval.netCents,
    );
  }
  final list = map.values.toList()
    ..sort((a, b) {
      final byBal = a.balanceCents.compareTo(b.balanceCents);
      return byBal != 0 ? byBal : b.tickets.compareTo(a.tickets);
    });
  return list;
}

List<TicketLesson> lessonsFromTickets(List<StoredTicket> tickets, {int limit = 12}) {
  final evaluated = [
    for (final t in tickets)
      if (!t.isOpen && !t.isLegacy && t.evaluation != null) t,
  ]..sort((a, b) {
      final byDate = (b.targetDrawDate ?? b.createdAt).compareTo(a.targetDrawDate ?? a.createdAt);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  return [
    for (final ticket in evaluated.take(limit)) _lesson(ticket),
  ];
}

TicketLesson _lesson(StoredTicket ticket) {
  final eval = ticket.evaluation!;
  final hits = [...eval.hitNumbers]..sort();
  final missed = [for (final n in ticket.numbers) if (!eval.hitNumbers.contains(n)) n]..sort();
  final balance = eval.netCents - ticket.stakeCents;
  final key = _methodKey(ticket);
  final isZoppe = key.contains('Zoppe') || key == 'Zoppe';
  final isAuto = key.startsWith('Auto');
  final isMirata = key.startsWith('Mirata');

  String headline;
  if (eval.isWin) {
    headline = 'Vincita simulata · ${eval.hits} centri · netto ${formatEuro(eval.netCents)}';
  } else if (eval.hits == 0) {
    headline = 'Nessun centro sui numeri giocati';
  } else {
    headline = '${eval.hits} centri, nessuna sorte pagata (o posta insufficiente)';
  }

  final buffer = StringBuffer();
  if (hits.isNotEmpty) {
    buffer.writeln('Centrati: ${hits.join(' · ')}.');
  }
  if (missed.isNotEmpty) {
    buffer.writeln('Fuori: ${missed.join(' · ')}.');
  }
  if (isZoppe || (isAuto && key.contains('Zoppe'))) {
    buffer.writeln(
      'Il Sistemone Zoppe mescola gettonati, ritardi e fasce di frequenza del passato. '
      'Non “sbaglia” la probabilità: ogni numero resta 5 su 90. Se i centri sono pochi, '
      'è l\'esito atteso del caso, non un errore di costruzione della colonna.',
    );
  } else if (isAuto && key.contains('Ritardi')) {
    buffer.writeln(
      'I ritardatari descrivono chi manca da più estrazioni. Il ritardo non li rende più probabili: '
      'usare i ritardi è una scelta di studio, non un vantaggio matematico.',
    );
  } else if (isAuto && key.contains('Frequenti')) {
    buffer.writeln(
      'I frequenti sono i più usciti in una finestra. La frequenza passata non aumenta la probabilità futura (5/90).',
    );
  } else if (isMirata) {
    final sorte = ticket.stakes.entries.where((e) => e.value > 0).map((e) => e.key.label).join(', ');
    buffer.writeln(
      'Giocata mirata${sorte.isEmpty ? '' : ' ($sorte)'}: serve centrare abbastanza numeri per quella sorte. '
      'Con ${ticket.numbers.length} numeri su una ruota, molti esiti restano senza premio.',
    );
  } else {
    buffer.writeln(
      'Nel Lotto l\'estrazione è indipendente dal passato. Una colonna “ragionata” e una a caso '
      'hanno la stessa probabilità equa per ogni numero.',
    );
  }
  buffer.writeln('Saldo di questa schedina: ${balance >= 0 ? '+' : ''}${formatEuro(balance)}.');

  return TicketLesson(
    ticketId: ticket.id,
    title: '${_methodLabel(key)} · ${ticket.coversAllWheels ? 'Tutte' : ticket.wheelCode}',
    headline: headline,
    body: buffer.toString().trim(),
    hitNumbers: hits,
    missedNumbers: missed,
    balanceCents: balance,
  );
}

/// Credito simulato residuo rispetto al capitale e alle poste aperte.
int simulatedCreditCents({
  required AppSettings settings,
  required WalletSummary summary,
}) {
  return settings.virtualCapitalCents + summary.balanceCents - summary.openStakeCents;
}
