// lib/features/virtual_wallet/presentation/ticket_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../superenalotto/data/se_ticket_repository.dart';
import '../../superenalotto/domain/se_prize_estimates.dart';
import '../../superenalotto/presentation/se_chrome.dart';
import '../../superenalotto/presentation/se_studio_page.dart';
import '../data/wallet_repository.dart';
import 'wallet_pages.dart';

enum _HistoryFilter { all, lotto, se, open, wins }

class TicketHistoryPage extends ConsumerStatefulWidget {
  const TicketHistoryPage({super.key});

  @override
  ConsumerState<TicketHistoryPage> createState() => _TicketHistoryPageState();
}

class _TicketHistoryPageState extends ConsumerState<TicketHistoryPage> {
  var _filter = _HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(walletRepositoryProvider).evaluateOpenTickets();
      await ref.read(seTicketRepositoryProvider).evaluateOpen();
      ref.invalidate(ticketsProvider);
      ref.invalidate(seTicketsProvider);
      ref.invalidate(walletSummaryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lottoAsync = ref.watch(ticketsProvider);
    final seAsync = ref.watch(seTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Storico schedine'),
        actions: [
          IconButton(
            tooltip: 'Crea',
            onPressed: () => context.push('/tickets/quick'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: lottoAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (lotto) {
                final se = seAsync.value ?? const <SeTicket>[];
                final rows = <_HistoryRow>[
                  for (final t in lotto)
                    _HistoryRow.lotto(t),
                  for (final t in se)
                    _HistoryRow.se(t),
                ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));

                final shown = rows.where((row) {
                  return switch (_filter) {
                    _HistoryFilter.all => true,
                    _HistoryFilter.lotto => !row.isSe,
                    _HistoryFilter.se => row.isSe,
                    _HistoryFilter.open => row.isOpen,
                    _HistoryFilter.wins => row.isWin,
                  };
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final entry in [
                              (_HistoryFilter.all, 'Tutte (${rows.length})'),
                              (_HistoryFilter.lotto, 'Lotto (${lotto.length})'),
                              (_HistoryFilter.se, 'SE (${se.length})'),
                              (_HistoryFilter.open, 'In attesa (${rows.where((r) => r.isOpen).length})'),
                              (_HistoryFilter.wins, 'Vincite (${rows.where((r) => r.isWin).length})'),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(entry.$2),
                                  selected: _filter == entry.$1,
                                  onSelected: (_) => setState(() => _filter = entry.$1),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: shown.isEmpty
                          ? const Center(child: Text('Nessuna schedina in questo filtro.'))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: shown.length,
                              itemBuilder: (context, index) => _HistoryTile(row: shown[index]),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow {
  _HistoryRow.lotto(StoredTicket ticket)
      : isSe = false,
        lotto = ticket,
        se = null,
        sortDate = ticket.targetDrawDate ?? ticket.createdAt;

  _HistoryRow.se(SeTicket ticket)
      : isSe = true,
        lotto = null,
        se = ticket,
        sortDate = ticket.targetDrawDate;

  final bool isSe;
  final StoredTicket? lotto;
  final SeTicket? se;
  final DateTime sortDate;

  bool get isOpen => isSe ? se!.isOpen : lotto!.isOpen;

  bool get isWin => isSe
      ? (se!.match?.isCategoryWin == true)
      : (lotto!.evaluation?.isWin == true);
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row});

  final _HistoryRow row;

  @override
  Widget build(BuildContext context) {
    if (row.isSe) {
      final t = row.se!;
      final money = t.match == null ? null : estimateSeWin(t.match!);
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: SeColors.forest.withValues(alpha: 0.12),
            child: const Icon(Icons.stars, color: SeColors.forest, size: 20),
          ),
          title: Text(
            'SE · ${formatItalianDate(t.targetDrawDate)}'
            '${t.match == null ? '' : ' · ${t.match!.label}'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            [
              t.numbers.join(' · '),
              if (money != null && (money.estimatedCents > 0 || money.isJackpot)) money.shortEuro,
              if (t.isOpen) 'in attesa',
            ].join(' · '),
          ),
          trailing: IconButton(
            tooltip: 'Rigioca',
            onPressed: () => context.push(seStudioRoute(numbers: t.numbers)),
            icon: const Icon(Icons.replay),
          ),
          onTap: () => context.push('/more/se/tickets'),
        ),
      );
    }

    final t = row.lotto!;
    final wheel = t.coversAllWheels ? 'Tutte' : (wheelByCode(t.wheelCode)?.name ?? t.wheelCode);
    final eval = t.evaluation;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.navy.withValues(alpha: 0.12),
          child: const Icon(Icons.confirmation_number_outlined, color: AppColors.navy, size: 20),
        ),
        title: Text(
          'Lotto · $wheel · ${formatItalianDate(t.targetDrawDate ?? t.createdAt)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            t.numbers.join(' · '),
            formatEuro(t.stakeCents),
            if (eval != null && eval.isWin) 'netto ${formatEuro(eval.netCents)}',
            if (t.isOpen) 'in attesa',
          ].join(' · '),
        ),
        trailing: IconButton(
          tooltip: 'Rigioca',
          onPressed: () => context.push(newTicketRoute(numbers: t.numbers, wheel: t.wheelCode, stakes: t.stakes)),
          icon: const Icon(Icons.replay),
        ),
        onTap: () => context.push('/tickets/${t.id}'),
      ),
    );
  }
}
