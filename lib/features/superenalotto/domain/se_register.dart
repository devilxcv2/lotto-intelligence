// lib/features/superenalotto/domain/se_register.dart

import '../../../core/settings/app_settings.dart';
import '../../virtual_wallet/data/wallet_repository.dart';
import '../data/se_ticket_repository.dart';
import 'se_prize_estimates.dart';

class SeRegisterOutcome {
  const SeRegisterOutcome.ok(this.saved) : error = null;
  const SeRegisterOutcome.fail(this.error) : saved = 0;

  final int saved;
  final String? error;

  bool get ok => error == null && saved > 0;
}

/// Controlla budget e registra le sestine nel catalogo SE (1 € ciascuna).
Future<SeRegisterOutcome> registerSeColumns({
  required List<List<int>> columns,
  required String origin,
  String? note,
  int? superstar,
  required AppSettings settings,
  required WalletRepository wallet,
  required SeTicketRepository seTickets,
  int limit = 200,
}) async {
  if (columns.isEmpty) return const SeRegisterOutcome.fail('Nessuna sestina da registrare.');
  if (columns.length > limit) {
    return SeRegisterOutcome.fail(
      'Sono ${columns.length} sestine: registra al massimo $limit per volta (budget e catalogo).',
    );
  }
  final cost = columns.length * seCombinationCostCents;
  final spent = await wallet.spentThisMonthCents(DateTime.now());
  final decision = wallet.assess(settings: settings, spentThisMonthCents: spent, stakeCents: cost);
  if (!decision.allowed) {
    return SeRegisterOutcome.fail(decision.message ?? 'Budget insufficiente.');
  }
  try {
    final saved = await seTickets.addMany(
      columns: columns,
      superstar: superstar,
      origin: origin,
      note: note ?? 'Sistema di studio · posta ${formatEuro(seCombinationCostCents)} a sestina.',
    );
    return SeRegisterOutcome.ok(saved);
  } on StateError catch (e) {
    return SeRegisterOutcome.fail(e.message);
  } catch (e) {
    return SeRegisterOutcome.fail('$e');
  }
}
