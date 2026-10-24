// lib/features/virtual_wallet/domain/targeted_ticket.dart

import '../../../core/lotto/prize_table.dart';

/// Quanti numeri proporre per una giocata mirata su una sola sorte.
/// Di default il minimo della sorte; si può allargare di poco per più combinazioni.
int targetedNumberCount(LottoSorte sorte, {int extra = 0}) {
  final n = sorte.hitsRequired + extra.clamp(0, 3);
  return n.clamp(sorte.hitsRequired, maxTicketNumbers);
}

Map<LottoSorte, int> stakesForTargeted(LottoSorte sorte, {int stakeCents = 100}) {
  final stepped = (stakeCents / stakeStepCents).round() * stakeStepCents;
  final cents = stepped.clamp(stakeStepCents, maxTicketStakeCents);
  return {sorte: cents};
}

String targetedNote(LottoSorte sorte, String wheelLabel) =>
    'Mirata · ${sorte.label} su $wheelLabel. Studio ipotetico, nessun acquisto.';
