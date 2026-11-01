// lib/features/virtual_wallet/presentation/ticket_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/widgets/common_widgets.dart';
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
            icon: const Icon(Icons.add_circle_outline),
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
                  for (final t in lotto) _HistoryRow.lotto(t),
                  for (final t in se) _HistoryRow.se(t),
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
                              (_HistoryFilter.all, 'Tutte', rows.length),
                              (_HistoryFilter.lotto, 'Lotto', lotto.length),
                              (_HistoryFilter.se, 'SE', se.length),
                              (_HistoryFilter.open, 'Attesa', rows.where((r) => r.isOpen).length),
                              (_HistoryFilter.wins, 'Vincite', rows.where((r) => r.isWin).length),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: _filter == entry.$1,
                                  label: Text('${entry.$2} ${entry.$3}'),
                                  onSelected: (_) => setState(() => _filter = entry.$1),
                                  selectedColor: AppColors.navy.withValues(alpha: 0.14),
                                  checkmarkColor: AppColors.navy,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _filter == entry.$1 ? AppColors.navy : AppColors.ink.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: shown.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Nessuna schedina in questo filtro.',
                                  style: TextStyle(color: AppColors.ink.withValues(alpha: 0.55)),
                                ),
                              ),
                            )
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

  bool get isWin => isSe ? (se!.match?.isCategoryWin == true) : (lotto!.evaluation?.isWin == true);
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row});

  final _HistoryRow row;

  @override
  Widget build(BuildContext context) {
    if (row.isSe) {
      final t = row.se!;
      final money = t.match == null ? null : estimateSeWin(t.match!);
      return _TicketCard(
        accent: SeColors.forest,
        badge: 'SE',
        title: formatItalianDate(t.targetDrawDate),
        status: t.isOpen
            ? 'In attesa'
            : (t.match?.label ?? 'Valutata'),
        win: row.isWin,
        numbers: t.numbers,
        gold: true,
        meta: [
          if (money != null && (money.estimatedCents > 0 || money.isJackpot)) money.shortEuro,
          t.origin,
        ].where((s) => s.isNotEmpty).join(' · '),
        onReplay: () => context.push(seStudioRoute(numbers: t.numbers)),
        onOpen: () => context.push('/more/se/tickets'),
      );
    }

    final t = row.lotto!;
    final wheel = t.coversAllWheels ? 'Tutte' : (wheelByCode(t.wheelCode)?.name ?? t.wheelCode);
    final eval = t.evaluation;
    return _TicketCard(
      accent: AppColors.navy,
      badge: 'Lotto',
      title: '$wheel · ${formatItalianDate(t.targetDrawDate ?? t.createdAt)}',
      status: t.isOpen
          ? 'In attesa'
          : (eval?.isWin == true ? 'Netto ${formatEuro(eval!.netCents)}' : 'Nessuna vincita'),
      win: row.isWin,
      numbers: t.numbers,
      gold: false,
      meta: formatEuro(t.stakeCents),
      onReplay: () => context.push(newTicketRoute(numbers: t.numbers, wheel: t.wheelCode, stakes: t.stakes)),
      onOpen: () => context.push('/tickets/${t.id}'),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.accent,
    required this.badge,
    required this.title,
    required this.status,
    required this.win,
    required this.numbers,
    required this.gold,
    required this.meta,
    required this.onReplay,
    required this.onOpen,
  });

  final Color accent;
  final String badge;
  final String title;
  final String status;
  final bool win;
  final List<int> numbers;
  final bool gold;
  final String meta;
  final VoidCallback onReplay;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: win ? AppColors.banner.withValues(alpha: 0.55) : AppColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onOpen,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(badge, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: accent)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                            IconButton(
                              tooltip: 'Rigioca',
                              onPressed: onReplay,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.replay, color: accent, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        NumberBalls(numbers: numbers, gold: gold, compact: true),
                        const SizedBox(height: 8),
                        Text(
                          '$status${meta.isEmpty ? '' : ' · $meta'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: win ? FontWeight.w700 : FontWeight.w500,
                                color: win ? AppColors.wheel : AppColors.ink.withValues(alpha: 0.65),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
