// lib/features/superenalotto/presentation/se_tickets_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lotto/wheel_catalog.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../data/se_ticket_repository.dart';
import '../data/superenalotto_sync.dart';
import 'se_chrome.dart';

/// Catalogo delle sole schedine SuperEnalotto (categorie, non euro).
class SeTicketsPage extends ConsumerStatefulWidget {
  const SeTicketsPage({super.key});

  @override
  ConsumerState<SeTicketsPage> createState() => _SeTicketsPageState();
}

class _SeTicketsPageState extends ConsumerState<SeTicketsPage> {
  var _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final closed = await ref.read(seTicketRepositoryProvider).evaluateOpen();
      if (closed > 0) ref.invalidate(seTicketsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(seTicketsProvider);
    final sync = ref.watch(superenalottoSyncProvider);
    return Scaffold(
      backgroundColor: SeColors.cream,
      appBar: AppBar(
        backgroundColor: SeColors.forest,
        foregroundColor: Colors.white,
        title: const Text('Schedine SuperEnalotto'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna e confronta',
            onPressed: sync.running ? null : () => ref.read(superenalottoSyncProvider.notifier).syncLatest(),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SeColors.forest,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/more/se/studio'),
        icon: const Icon(Icons.add),
        label: const Text('Nuova'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AsyncBody<List<SeTicket>>(
              value: tickets,
              onRetry: () => ref.invalidate(seTicketsProvider),
              data: (items) {
                final wins = items.where((t) => t.match?.isCategoryWin == true).length;
                final none = items.where((t) => t.match != null && !t.match!.isCategoryWin).length;
                final autos = items.where((t) => t.isAutoStudy).length;
                final shown = switch (_filter) {
                  'open' => items.where((t) => t.isOpen).toList(),
                  'wins' => items.where((t) => t.match?.isCategoryWin == true).toList(),
                  'none' => items.where((t) => t.match != null && !t.match!.isCategoryWin).toList(),
                  'evaluated' => items.where((t) => !t.isOpen).toList(),
                  'auto' => items.where((t) => t.isAutoStudy).toList(),
                  _ => items,
                };
                final catalog = _catalogByContest(shown);
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        'Solo SuperEnalotto. Le schedine del Lotto restano nella scheda Schedine, con le poste in euro.',
                        style: TextStyle(color: SeColors.ink),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final entry in [
                              ('all', 'Tutte (${items.length})'),
                              ('open', 'In attesa (${items.where((t) => t.isOpen).length})'),
                              ('wins', 'Categorie ($wins)'),
                              ('none', 'Nessuna ($none)'),
                              ('auto', 'Auto ($autos)'),
                              ('evaluated', 'Valutate (${items.where((t) => !t.isOpen).length})'),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(entry.$2),
                                  selected: _filter == entry.$1,
                                  onSelected: (_) => setState(() => _filter = entry.$1),
                                  showCheckmark: false,
                                  selectedColor: SeColors.gold.withValues(alpha: 0.45),
                                  side: BorderSide(color: SeColors.forest.withValues(alpha: 0.25)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: shown.isEmpty
                          ? const _EmptySeTickets()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: catalog.length,
                              itemBuilder: (context, index) {
                                final section = catalog[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                                      child: ResultsBanner(section.title, color: SeColors.forest),
                                    ),
                                    if (section.subtitle != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(section.subtitle!, style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                    for (final ticket in section.tickets) _SeTicketCard(ticket: ticket),
                                  ],
                                );
                              },
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

class _CatalogSection {
  const _CatalogSection({required this.title, required this.tickets, this.subtitle});

  final String title;
  final String? subtitle;
  final List<SeTicket> tickets;
}

List<_CatalogSection> _catalogByContest(List<SeTicket> tickets) {
  final open = tickets.where((t) => t.isOpen).toList();
  final byDate = <DateTime, List<SeTicket>>{};
  for (final ticket in tickets.where((t) => !t.isOpen)) {
    final raw = ticket.targetDrawDate;
    final key = DateTime.utc(raw.year, raw.month, raw.day);
    byDate.putIfAbsent(key, () => []).add(ticket);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    if (open.isNotEmpty)
      _CatalogSection(
        title: 'In attesa del concorso',
        subtitle: '${open.length} schedine: la categoria arriva quando l\'archivio ha quella data.',
        tickets: open,
      ),
    for (final date in dates)
      _CatalogSection(
        title: 'Concorso del ${formatItalianDate(date)}',
        subtitle: () {
          final group = byDate[date]!;
          final wins = group.where((t) => t.match?.isCategoryWin == true).length;
          final contest = group.map((t) => t.contestNumber).whereType<int>().toSet();
          final contestLabel = contest.isEmpty ? '' : ' · Nº ${contest.join(', ')}';
          return wins == 0
              ? '${group.length} schedine · nessuna categoria$contestLabel'
              : '${group.length} schedine · $wins con categoria$contestLabel';
        }(),
        tickets: byDate[date]!,
      ),
  ];
}

class _EmptySeTickets extends StatelessWidget {
  const _EmptySeTickets();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars_outlined, size: 48, color: SeColors.forest),
          SizedBox(height: 12),
          Text('Nessuna schedina SuperEnalotto qui.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            'Registra sei numeri nello studio. Dopo il concorso vedi la categoria (due…sei), non un importo in euro.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SeTicketCard extends StatelessWidget {
  const _SeTicketCard({required this.ticket});

  final SeTicket ticket;

  @override
  Widget build(BuildContext context) {
    final match = ticket.match;
    final win = match?.isCategoryWin == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: win ? SeColors.gold : SeColors.forest.withValues(alpha: 0.14), width: win ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.isOpen
                          ? 'Per il ${formatItalianDate(ticket.targetDrawDate)}'
                          : (ticket.contestNumber == null
                              ? formatItalianDate(ticket.targetDrawDate)
                              : 'Nº ${ticket.contestNumber} · ${formatItalianDate(ticket.targetDrawDate)}'),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: SeColors.forest),
                    ),
                  ),
                  if (match != null)
                    SeCategoryBadge(label: match.label, win: win)
                  else
                    const SeCategoryBadge(label: 'In attesa', win: false),
                ],
              ),
              const SizedBox(height: 10),
              NumberBalls(numbers: ticket.numbers, gold: true),
              if (ticket.superstar != null) ...[
                const SizedBox(height: 8),
                Text(
                  'SuperStar ${ticket.superstar}${match?.superstarMatched == true ? ' · indovinata' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: match?.superstarMatched == true ? SeColors.mint : SeColors.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                [
                  if (ticket.isAutoStudy) 'Auto',
                  if (match != null) '${match.hits} numeri nei sei',
                  if (match?.jollyMatched == true) 'Jolly',
                  ticket.origin,
                ].where((part) => part.isNotEmpty).join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
