// lib/features/virtual_wallet/presentation/wallet_pages.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/prize_table.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/archive_sync.dart';
import '../../draws/data/draw_repository.dart';
import '../../statistics/data/statistics_providers.dart';
import '../../systems/domain/zoppe_system.dart';
import '../../../app/result_notice.dart';
import '../data/auto_study_service.dart';
import '../data/wallet_repository.dart';
import '../domain/auto_study.dart';

/// Rotta della pagina «Nuova schedina», con numeri e ruota precompilati.
String newTicketRoute({List<int>? numbers, String? wheel}) {
  final query = <String>[
    if (numbers != null && numbers.isNotEmpty) 'numbers=${numbers.join(',')}',
    if (wheel != null) 'wheel=$wheel',
  ];
  return query.isEmpty ? '/tickets/new' : '/tickets/new?${query.join('&')}';
}

const String _noChaseNote = 'Capitale, poste e vincite sono simulati. Perdere è l\'esito atteso nel lungo periodo: '
    'il laboratorio serve a misurarlo, non a recuperarlo.';

// ---------------------------------------------------------------------------
// Portafoglio
// ---------------------------------------------------------------------------

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    return PageScaffold(
      title: 'Portafoglio virtuale',
      child: AsyncBody<WalletSummary>(
        value: summary,
        onRetry: () => ref.invalidate(walletSummaryProvider),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceHeader(summary: data, settings: settings),
            const SizedBox(height: 16),
            if (data.timeline.length >= 2) ...[
              SectionCard(
                title: 'Andamento del saldo simulato',
                child: SizedBox(height: 200, child: _BalanceChart(points: data.timeline)),
              ),
              const SizedBox(height: 16),
            ],
            SectionCard(
              title: 'Conteggi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row('Schedine in attesa', '${data.openCount} · posta ${formatEuro(data.openStakeCents)}'),
                  _Row('Schedine valutate', '${data.evaluatedCount}'),
                  _Row('Con vincita simulata', '${data.winningTickets}'),
                  _Row('Miglior netto', formatEuro(data.bestNetCents)),
                  if (data.legacyCount > 0) _Row('Schedine senza poste (versioni precedenti)', '${data.legacyCount}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LimitsCard(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/tickets'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Schedine'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(newTicketRoute(wheel: settings?.selectedWheelCode)),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuova schedina'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(_noChaseNote),
          ],
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.summary, required this.settings});

  final WalletSummary summary;
  final AppSettings? settings;

  @override
  Widget build(BuildContext context) {
    final balance = summary.balanceCents;
    final color = balance > 0 ? AppColors.gold : (balance < 0 ? Theme.of(context).colorScheme.error : null);
    final capital = settings?.virtualCapitalCents;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo delle schedine valutate', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              '${balance > 0 ? '+' : ''}${formatEuro(balance)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _Stat('Giocato', formatEuro(summary.stakedCents)),
                _Stat('Vinto lordo', formatEuro(summary.grossCents)),
                _Stat('Vinto netto (−8%)', formatEuro(summary.netCents)),
                _Stat(
                  'Ritorno',
                  summary.returnRatio == null ? '—' : '${(summary.returnRatio! * 100).toStringAsFixed(0)}%',
                ),
                if (capital != null) _Stat('Capitale simulato residuo', formatEuro(capital + balance - summary.openStakeCents)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BalanceChart extends StatelessWidget {
  const _BalanceChart({required this.points});

  final List<({DateTime date, int balanceCents})> points;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].balanceCents / 100),
    ];
    final primary = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (points.length / 4).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                final date = points[index].date.toUtc();
                return Text('${date.day}/${date.month}', style: Theme.of(context).textTheme.labelSmall);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)} €', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Theme.of(context).dividerColor)]),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: primary,
            barWidth: 2,
            dotData: FlDotData(show: points.length <= 30),
            belowBarData: BarAreaData(show: true, color: primary.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}

class _LimitsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LimitsCard> createState() => _LimitsCardState();
}

class _LimitsCardState extends ConsumerState<_LimitsCard> {
  final _capital = TextEditingController();
  final _contest = TextEditingController();
  final _month = TextEditingController();
  var _ready = false;

  @override
  void dispose() {
    _capital.dispose();
    _contest.dispose();
    _month.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    if (settings == null) return const SizedBox.shrink();
    if (!_ready) {
      _capital.text = _euro(settings.virtualCapitalCents);
      _contest.text = _euro(settings.contestBudgetCents);
      _month.text = _euro(settings.monthlyBudgetCents);
      _ready = true;
    }
    final mode = settings.budgetMode;
    return ExpansionTile(
      title: const Text('Budget simulato'),
      subtitle: Text(
        mode == BudgetMode.limits
            ? 'Concorso ${formatEuro(settings.contestBudgetCents)} · mese ${formatEuro(settings.monthlyBudgetCents)} · capitale ${formatEuro(settings.virtualCapitalCents)}'
            : mode.label,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(mode.hint),
        const SizedBox(height: 8),
        SegmentedButton<BudgetMode>(
          segments: const [
            ButtonSegment(value: BudgetMode.limits, label: Text('Limiti')),
            ButtonSegment(value: BudgetMode.off, label: Text('Spento')),
            ButtonSegment(value: BudgetMode.unlimited, label: Text('Infinito')),
          ],
          selected: {mode},
          onSelectionChanged: (selection) {
            ref.read(settingsControllerProvider.notifier).setBudgetMode(selection.first);
          },
        ),
        if (mode == BudgetMode.limits) ...[
          const SizedBox(height: 12),
          const Text('I tetti bloccano la registrazione quando vengono superati. Non si alzano da soli.'),
          TextField(controller: _capital, decoration: const InputDecoration(labelText: 'Capitale iniziale simulato, euro'), keyboardType: TextInputType.number),
          TextField(controller: _contest, decoration: const InputDecoration(labelText: 'Budget per concorso, euro'), keyboardType: TextInputType.number),
          TextField(controller: _month, decoration: const InputDecoration(labelText: 'Budget mensile, euro'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                await ref.read(settingsControllerProvider.notifier).setBudgets(
                      virtualCapitalCents: _cents(_capital.text),
                      contestBudgetCents: _cents(_contest.text),
                      monthlyBudgetCents: _cents(_month.text),
                      unitCostCents: settings.unitCostCents,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limiti simulati aggiornati.')));
                }
              },
              child: const Text('Salva limiti'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/more/settings'),
            child: const Text('Apri Impostazioni'),
          ),
        ],
      ],
    );
  }
}

String _euro(int cents) => (cents / 100).toStringAsFixed(2);

int _cents(String raw) {
  final value = double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  return (value * 100).round();
}

// ---------------------------------------------------------------------------
// Elenco schedine
// ---------------------------------------------------------------------------

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  var _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final evaluated = await ref.read(walletRepositoryProvider).evaluateOpenTickets();
      if (evaluated.isNotEmpty) {
        ref.invalidate(ticketsProvider);
        ref.invalidate(walletSummaryProvider);
        if (mounted) publishTicketEvaluations(ref, evaluated);
      }
      final settings = ref.read(settingsControllerProvider).value;
      if (settings?.autoStudyEnabled == true) {
        final created = await ref.read(autoStudyServiceProvider).ensureTicket(settings: settings);
        if (created.created) {
          ref.invalidate(ticketsProvider);
          ref.invalidate(walletSummaryProvider);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketsProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    final sync = ref.watch(archiveSyncProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedine ipotetiche'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna archivio e controlla vincite',
            onPressed: sync.running ? null : () => ref.read(archiveSyncProvider.notifier).syncOfficial(),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(newTicketRoute(wheel: settings?.selectedWheelCode)),
        icon: const Icon(Icons.add),
        label: const Text('Nuova schedina'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AsyncBody<List<StoredTicket>>(
              value: tickets,
              onRetry: () => ref.invalidate(ticketsProvider),
              data: (items) {
                final wins = items.where((t) => t.evaluation?.isWin == true).length;
                final autos = items.where((t) => t.isAutoStudy).length;
                final shown = switch (_filter) {
                  'open' => items.where((t) => t.isOpen).toList(),
                  'evaluated' => items.where((t) => !t.isOpen).toList(),
                  'wins' => items.where((t) => t.evaluation?.isWin == true).toList(),
                  'auto' => items.where((t) => t.isAutoStudy).toList(),
                  _ => items,
                };
                final catalog = _catalogByDraw(shown);
                return Column(
                  children: [
                    if (settings?.autoStudyEnabled == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Creazione automatica attiva (${settings!.autoStudyMethod.label} su ${settings.selectedWheelCode}): '
                          'l\'app prepara una schedina per il prossimo concorso e ti notifica gli esiti.',
                          style: Theme.of(context).textTheme.bodySmall,
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
                              ('evaluated', 'Valutate (${items.where((t) => !t.isOpen).length})'),
                              ('wins', 'Vincite ($wins)'),
                              ('auto', 'Auto ($autos)'),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(entry.$2),
                                  selected: _filter == entry.$1,
                                  onSelected: (_) => setState(() => _filter = entry.$1),
                                  showCheckmark: false,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.push('/more/se-studio'),
                        icon: const Icon(Icons.stars_outlined),
                        label: const Text('Schedine SuperEnalotto'),
                      ),
                    ),
                    Expanded(
                      child: shown.isEmpty
                          ? const _EmptyTickets()
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
                                      child: ResultsBanner(section.title),
                                    ),
                                    if (section.subtitle != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(section.subtitle!, style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                    for (final ticket in section.tickets) _TicketCard(ticket: ticket),
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
  final List<StoredTicket> tickets;
}

List<_CatalogSection> _catalogByDraw(List<StoredTicket> tickets) {
  final open = tickets.where((t) => t.isOpen).toList();
  final byDate = <DateTime, List<StoredTicket>>{};
  for (final ticket in tickets.where((t) => !t.isOpen)) {
    final raw = ticket.evaluation?.drawDate ?? ticket.targetDrawDate ?? ticket.createdAt;
    final key = DateTime.utc(raw.toUtc().year, raw.toUtc().month, raw.toUtc().day);
    byDate.putIfAbsent(key, () => []).add(ticket);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    if (open.isNotEmpty)
      _CatalogSection(
        title: 'In attesa del concorso',
        subtitle: '${open.length} schedine: saranno confrontate quando lo ZIP ufficiale avrà quella data.',
        tickets: open,
      ),
    for (final date in dates)
      _CatalogSection(
        title: 'Concorso del ${formatItalianDate(date)}',
        subtitle: () {
          final group = byDate[date]!;
          final wins = group.where((t) => t.evaluation?.isWin == true).length;
          final net = group.fold<int>(0, (sum, t) => sum + (t.evaluation?.netCents ?? 0));
          final stake = group.fold<int>(0, (sum, t) => sum + t.stakeCents);
          return wins == 0
              ? '${group.length} schedine · nessuna vincita simulata · posta ${formatEuro(stake)}'
              : '${group.length} schedine · $wins vincite · netto ${formatEuro(net)} su ${formatEuro(stake)}';
        }(),
        tickets: byDate[date]!,
      ),
  ];
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48),
          SizedBox(height: 12),
          Text('Nessuna schedina in questo elenco.', textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            'Registra una giocata ipotetica: la sera dell\'estrazione l\'app la confronta con i numeri usciti e calcola la vincita simulata con la tabella premi pubblicata.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final StoredTicket ticket;

  @override
  Widget build(BuildContext context) {
    final evaluation = ticket.evaluation;
    final theme = Theme.of(context);
    final wheelName = ticket.coversAllWheels ? 'Tutte le ruote' : (wheelByCode(ticket.wheelCode)?.name ?? ticket.wheelCode);
    final hits = evaluation?.hitNumbers ?? const <int>{};
    Widget status;
    if (ticket.isOpen) {
      status = Chip(
        avatar: const Icon(Icons.schedule, size: 16),
        label: Text(ticket.targetDrawDate == null ? 'In attesa' : 'Concorso del ${formatItalianDate(ticket.targetDrawDate!)}'),
      );
    } else if (ticket.isLegacy) {
      status = Chip(label: Text(evaluation == null ? 'Solo centri, non valutata' : 'Centri: ${evaluation.hits}'));
    } else if (evaluation != null && evaluation.isWin) {
      status = Chip(
        avatar: const Icon(Icons.emoji_events_outlined, size: 16, color: AppColors.gold),
        label: Text('Netto ${formatEuro(evaluation.netCents)} · ${evaluation.hits} centri'),
        side: const BorderSide(color: AppColors.gold),
      );
    } else {
      status = Chip(label: Text('Nessuna vincita · ${evaluation?.hits ?? 0} centri'));
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/tickets/${ticket.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${ticket.isAutoStudy ? 'Auto · ' : ''}$wheelName · ${formatEuro(ticket.stakeCents)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(formatItalianDate(ticket.createdAt), style: theme.textTheme.labelSmall),
                ],
              ),
              if (ticket.isAutoStudy && ticket.note != null) ...[
                const SizedBox(height: 4),
                Text(ticket.note!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 8),
              NumberBalls(numbers: ticket.numbers, hits: hits, compact: true),
              const SizedBox(height: 8),
              Row(
                children: [
                  status,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _stakesLabel(ticket.stakes),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _stakesLabel(Map<LottoSorte, int> stakes) {
  final parts = [
    for (final entry in stakes.entries)
      if (entry.value > 0) '${entry.key.label} ${formatEuro(entry.value)}',
  ];
  return parts.isEmpty ? 'Senza poste per sorte' : parts.join(' · ');
}

class _Ball extends StatelessWidget {
  const _Ball({required this.number, required this.hit});

  final int number;
  final bool hit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hit ? AppColors.ballGold : AppColors.ball,
        border: Border.all(color: hit ? AppColors.ballGold : AppColors.ball),
      ),
      child: Text(
        '$number',
        style: TextStyle(fontWeight: FontWeight.w800, color: hit ? AppColors.navy : AppColors.ballText),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nuova schedina
// ---------------------------------------------------------------------------

class NewTicketPage extends ConsumerStatefulWidget {
  const NewTicketPage({this.initialNumbers = const [], this.initialWheel, super.key});

  final List<int> initialNumbers;
  final String? initialWheel;

  @override
  ConsumerState<NewTicketPage> createState() => _NewTicketPageState();
}

class _NewTicketPageState extends ConsumerState<NewTicketPage> {
  late final List<int> _numbers = [...widget.initialNumbers.where((n) => n >= 1 && n <= 90).toSet().take(maxTicketNumbers)];
  late String _wheel;
  var _appliedSettingsWheel = false;
  final Map<LottoSorte, int> _stakes = {LottoSorte.ambo: 100};
  String? _message;
  String? _hint;
  var _busy = false;
  var _suggestBusy = false;
  List<List<int>> _zoppeColumns = const [];
  var _zoppeIndex = 0;
  ZoppeResult? _zoppePreview;

  @override
  void initState() {
    super.initState();
    _wheel = widget.initialWheel ?? 'BA';
  }

  TicketDraft get _draft => TicketDraft(wheelCode: _wheel, numbers: [..._numbers]..sort(), stakes: {..._stakes});

  String get _statsWheel =>
      _wheel == allWheelsCode ? (ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA') : _wheel;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    if (!_appliedSettingsWheel && widget.initialWheel == null && settings != null) {
      _wheel = settings.selectedWheelCode;
      _appliedSettingsWheel = true;
    }
    final draft = _draft;
    final problem = draft.problem();
    final target = nextOpenDrawDate(DateTime.now());
    final sortedNumbers = [..._numbers]..sort();
    final wheelName = _wheel == allWheelsCode ? 'Tutte (÷10)' : (wheelByCode(_wheel)?.name ?? _wheel);
    final budgetNote = settings == null
        ? null
        : switch (settings.budgetMode) {
            BudgetMode.limits => 'Budget con limiti attivi (Impostazioni).',
            BudgetMode.off => 'Budget spento: nessun blocco in registrazione.',
            BudgetMode.unlimited => 'Budget infinito: nessun blocco in registrazione.',
          };
    return PageScaffold(
      title: 'Nuova schedina',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: DisclaimerBanner()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Quattro passi: scegli la ruota, i numeri (anche con suggerimenti), le poste e registra. '
              'È una giocata di studio: non parte nessun biglietto reale.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (budgetNote != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(budgetNote, style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          const ResultsBanner('1 · Ruota'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giocata su: $wheelName', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.wheel)),
                const SizedBox(height: 4),
                Text(
                  'I suggerimenti sotto leggono l\'archivio di questa ruota. «Tutte» divide il premio per 10 (senza Nazionale).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                WheelSelector(
                  selectedCode: _wheel,
                  includeAllWheels: true,
                  onChanged: (code) => setState(() {
                    _wheel = code;
                    _zoppeColumns = const [];
                    _zoppePreview = null;
                    _hint = null;
                    if (code != allWheelsCode) {
                      ref.read(settingsControllerProvider.notifier).selectWheel(code);
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ResultsBanner('2 · Numeri e suggerimenti'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sortedNumbers.isEmpty ? 'Nessun numero scelto (massimo $maxTicketNumbers).' : 'Scelti ${sortedNumbers.length} · ${sortedNumbers.join(' · ')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.numberBlue),
                ),
                if (sortedNumbers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  NumberBalls(numbers: sortedNumbers),
                ],
                const SizedBox(height: 12),
                Text('Suggerimenti su ${_statsWheel == _wheel ? wheelName : (wheelByCode(_statsWheel)?.name ?? _statsWheel)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  'Descrivono il passato. Ogni numero ha la stessa probabilità equa 5/90.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                _SuggestionCard(
                  title: 'Sistemone Zoppe',
                  how: _zoppePreview == null
                      ? 'Cinque gambe: gettonato, ritardatario, fasce 30–45 / 50–65 / 70–85. Tocca per riempire; di nuovo per un\'altra colonna.'
                      : 'Colonna ${_zoppeIndex + 1} di ${_zoppeColumns.length}. ${_zoppePreview!.legend}',
                  numbers: _zoppePreview?.leadColumn ?? const [],
                  busy: _suggestBusy,
                  actionLabel: _zoppeColumns.isEmpty ? 'Usa Zoppe' : 'Altra colonna',
                  onUse: _fillZoppe,
                  extra: TextButton(
                    onPressed: () => context.push('/lab/zoppe'),
                    child: const Text('Apri laboratorio Zoppe'),
                  ),
                ),
                const SizedBox(height: 8),
                _SuggestionCard(
                  title: 'Ritardatari',
                  how: 'I cinque più assenti nelle ultime 100 estrazioni. Il ritardo non alza la probabilità.',
                  numbers: const [],
                  busy: _suggestBusy,
                  actionLabel: 'Usa ritardatari',
                  onUse: () => _fill(_Fill.delays),
                ),
                const SizedBox(height: 8),
                _SuggestionCard(
                  title: 'Frequenti',
                  how: 'I cinque più usciti nelle ultime 100 estrazioni. La frequenza non alza la probabilità.',
                  numbers: const [],
                  busy: _suggestBusy,
                  actionLabel: 'Usa frequenti',
                  onUse: () => _fill(_Fill.frequent),
                ),
                if (_hint != null) ...[
                  const SizedBox(height: 8),
                  Text(_hint!, style: Theme.of(context).textTheme.bodySmall),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _numbers.isEmpty
                        ? null
                        : () => setState(() {
                              _numbers.clear();
                              _hint = null;
                            }),
                    child: const Text('Svuota numeri'),
                  ),
                ),
                const SizedBox(height: 8),
                _NumberGrid(selected: _numbers.toSet(), onToggle: _toggle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ResultsBanner('3 · Poste'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                Text(
                  'Attiva le sorti con i pulsanti + e −. Restano tutte disponibili: quelle che i numeri non permettono restano a zero.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (final sorte in LottoSorte.values)
                  _StakeRow(
                    sorte: sorte,
                    numbersPlayed: _numbers.length,
                    wheels: _wheel == allWheelsCode ? 10 : 1,
                    stakeCents: _stakes[sorte] ?? 0,
                    onChanged: (value) => setState(() {
                      if (value <= 0) {
                        _stakes.remove(sorte);
                      } else {
                        _stakes[sorte] = value;
                      }
                    }),
                  ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(child: Text('Totale posta', style: TextStyle(fontWeight: FontWeight.w700))),
                    Text(formatEuro(draft.stakeCents), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimo 1,00 €, massimo 200,00 €, passi di 0,50 €. Cap 6.000.000 €. Ritenuta 8% sul lordo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ResultsBanner('4 · Registra'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Concorso del ${formatItalianDate(target)} · raccolta chiusa alle '
                  '$salesCloseHour:${salesCloseMinute.toString().padLeft(2, '0')}. '
                  'Risultati tipici verso le $typicalResultsHour:${typicalResultsMinute.toString().padLeft(2, '0')}; '
                  'l\'app scarica lo ZIP dalle $archiveCheckHour:${archiveCheckMinute.toString().padLeft(2, '0')}.',
                ),
                const SizedBox(height: 6),
                Text('$wheelName · ${sortedNumbers.isEmpty ? 'nessun numero' : sortedNumbers.join(' · ')} · posta ${formatEuro(draft.stakeCents)}'),
                const SizedBox(height: 8),
                if (problem == null) ...[
                  Text('Vincita lorda massima teorica: ${formatEuro(_maxGross(draft))}'),
                  const SizedBox(height: 4),
                  Text(_expectationLine(draft), style: Theme.of(context).textTheme.bodySmall),
                ] else
                  Text(problem, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: problem != null || _busy || settings == null ? null : () => _register(settings),
                  icon: const Icon(Icons.save_alt),
                  label: Text(_busy ? 'Registro…' : 'Registra schedina ipotetica'),
                ),
                const SizedBox(height: 8),
                Text(_noChaseNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(int number) {
    setState(() {
      _hint = null;
      if (_numbers.contains(number)) {
        _numbers.remove(number);
      } else if (_numbers.length < maxTicketNumbers) {
        _numbers.add(number);
      } else {
        _message = 'Massimo $maxTicketNumbers numeri su una schedina del Lotto.';
      }
    });
  }

  Future<void> _fill(_Fill kind) async {
    setState(() {
      _suggestBusy = true;
      _message = null;
    });
    try {
      final stats = await ref.read(wheelStatisticsProvider((wheel: _statsWheel, window: 100)).future);
      if (stats == null || !mounted) {
        setState(() => _message = 'Statistiche non disponibili: archivio vuoto per questa ruota.');
        return;
      }
      final sorted = [...stats.numbers];
      if (kind == _Fill.delays) {
        sorted.sort((a, b) => b.currentDelay.compareTo(a.currentDelay));
      } else {
        sorted.sort((a, b) => b.absoluteFrequency.compareTo(a.absoluteFrequency));
      }
      setState(() {
        _zoppeColumns = const [];
        _numbers
          ..clear()
          ..addAll(sorted.take(5).map((item) => item.number));
        _hint = kind == _Fill.delays
            ? 'Cinque ritardatari delle ultime 100 estrazioni su $_statsWheel. Il ritardo non alza la probabilità.'
            : 'Cinque più frequenti delle ultime 100 estrazioni su $_statsWheel. La frequenza non alza la probabilità.';
      });
    } finally {
      if (mounted) setState(() => _suggestBusy = false);
    }
  }

  Future<void> _fillZoppe() async {
    setState(() {
      _suggestBusy = true;
      _message = null;
    });
    try {
      if (_zoppeColumns.isNotEmpty) {
        _zoppeIndex = (_zoppeIndex + 1) % _zoppeColumns.length;
        final column = _zoppeColumns[_zoppeIndex];
        setState(() {
          _numbers
            ..clear()
            ..addAll(column);
          _hint =
              'Zoppe colonna ${_zoppeIndex + 1} di ${_zoppeColumns.length} su $_statsWheel. '
              'Probabilità equa 5/90 per ogni numero.';
        });
        return;
      }
      final draws = await ref.read(wheelDrawsProvider(_statsWheel).future);
      if (!mounted) return;
      if (draws.length < 30) {
        setState(() => _message = 'Servono almeno 30 estrazioni su $_statsWheel per lo Zoppe.');
        return;
      }
      final window = draws.length < zoppeWindowDraws ? draws.length : zoppeWindowDraws;
      final counted = frequencyAndDelay(draws, window: window);
      final result = buildZoppeSystem(
        hits: counted.hits,
        delays: counted.delay,
        columnSize: 5,
        seed: DateTime.now().millisecondsSinceEpoch % 9973,
        windowDraws: window,
      );
      if (!mounted) return;
      if (result.columns.isEmpty) {
        setState(() => _message = result.error ?? 'Zoppe non disponibile su questa ruota.');
        return;
      }
      setState(() {
        _zoppePreview = result;
        _zoppeColumns = result.columns;
        _zoppeIndex = 0;
        _numbers
          ..clear()
          ..addAll(result.leadColumn);
        _hint =
            'Sistemone Zoppe su $_statsWheel: ${result.leadColumn.join(' · ')}. '
            'Tocca di nuovo «Altra colonna» per la successiva.';
      });
    } finally {
      if (mounted) setState(() => _suggestBusy = false);
    }
  }

  int _maxGross(TicketDraft draft) {
    var total = 0;
    for (final entry in draft.stakes.entries) {
      if (entry.value <= 0) continue;
      total += grossPrizeCents(
        sorte: entry.key,
        numbersPlayed: draft.numbers.length,
        hits: draft.numbers.length,
        stakeCents: entry.value,
        wheelsCovered: draft.wheelCode == allWheelsCode ? 10 : 1,
      );
    }
    return applyTicketCap(total);
  }

  String _expectationLine(TicketDraft draft) {
    // Valore atteso per euro: somma su k>=sorte di P(k centri) × premio.
    // Serve a ricordare che il gioco rende meno della posta, in media.
    final n = draft.numbers.length;
    var expected = 0.0;
    for (final entry in draft.stakes.entries) {
      if (entry.value <= 0) continue;
      for (var hits = entry.key.hitsRequired; hits <= n && hits <= 5; hits++) {
        final probability = _hypergeometric(n, hits);
        expected += probability * grossPrizeCents(sorte: entry.key, numbersPlayed: n, hits: hits, stakeCents: entry.value);
      }
    }
    final net = expected * (1 - withholdingRate);
    final ratio = draft.stakeCents == 0 ? 0 : net / draft.stakeCents;
    return 'Ritorno atteso su una ruota: ${formatEuro(net.round())} per ${formatEuro(draft.stakeCents)} giocati (${(ratio * 100).toStringAsFixed(0)}%). '
        'La media di lungo periodo è una perdita.';
  }

  double _hypergeometric(int played, int hits) {
    // P(esattamente `hits` dei `played` numeri escono fra i 5 estratti su 90).
    double binom(int a, int b) {
      if (b < 0 || b > a) return 0;
      var result = 1.0;
      for (var i = 1; i <= b; i++) {
        result = result * (a - b + i) / i;
      }
      return result;
    }

    return binom(played, hits) * binom(90 - played, 5 - hits) / binom(90, 5);
  }

  Future<void> _register(AppSettings settings) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final wallet = ref.read(walletRepositoryProvider);
    final draft = _draft;
    try {
      final spent = await wallet.spentThisMonthCents(DateTime.now());
      final decision = wallet.assess(settings: settings, spentThisMonthCents: spent, stakeCents: draft.stakeCents);
      if (!decision.allowed) {
        setState(() => _message = decision.message);
        return;
      }
      final id = await wallet.addTicket(draft);
      ref.invalidate(ticketsProvider);
      ref.invalidate(walletSummaryProvider);
      if (!mounted) return;
      if (settings.liveSyncEnabled && settings.notificationsEnabled) {
        await NotificationService.instance.requestPermission();
      }
      if (!mounted) return;
      context.pushReplacement('/tickets/$id');
    } on StateError catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

enum _Fill { delays, frequent }

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.title,
    required this.how,
    required this.numbers,
    required this.busy,
    required this.actionLabel,
    required this.onUse,
    this.extra,
  });

  final String title;
  final String how;
  final List<int> numbers;
  final bool busy;
  final String actionLabel;
  final Future<void> Function() onUse;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.wheel)),
            const SizedBox(height: 4),
            Text(how, style: Theme.of(context).textTheme.bodySmall),
            if (numbers.isNotEmpty) ...[
              const SizedBox(height: 8),
              NumberBalls(numbers: numbers, compact: true),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: busy ? null : () => onUse(),
                  child: Text(busy ? 'Calcolo…' : actionLabel),
                ),
                ?extra,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 15 : 10;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: 90,
          itemBuilder: (context, index) {
            final number = index + 1;
            final isSelected = selected.contains(number);
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onToggle(number),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? primary : primary.withValues(alpha: 0.08),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StakeRow extends StatelessWidget {
  const _StakeRow({
    required this.sorte,
    required this.numbersPlayed,
    required this.wheels,
    required this.stakeCents,
    required this.onChanged,
  });

  final LottoSorte sorte;
  final int numbersPlayed;
  final int wheels;
  final int stakeCents;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = numbersPlayed >= sorte.hitsRequired;
    final perEuro = enabled
        ? grossPrizeCents(sorte: sorte, numbersPlayed: numbersPlayed, hits: sorte.hitsRequired, stakeCents: 100, wheelsCovered: wheels)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sorte.label, style: TextStyle(color: enabled ? null : Theme.of(context).disabledColor)),
                Text(
                  !enabled
                      ? 'Servono almeno ${sorte.hitsRequired} numeri'
                      : 'Paga ${formatEuro(perEuro!)} per 1 € con ${sorte.hitsRequired} centri',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: !enabled || stakeCents <= 0 ? null : () => onChanged(stakeCents - stakeStepCents),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(width: 64, child: Text(formatEuro(stakeCents), textAlign: TextAlign.center)),
          IconButton(
            onPressed: !enabled ? null : () => onChanged(stakeCents + stakeStepCents),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dettaglio
// ---------------------------------------------------------------------------

class TicketDetailPage extends ConsumerWidget {
  const TicketDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);
    return PageScaffold(
      title: 'Schedina #$id',
      actions: [
        IconButton(
          tooltip: 'Elimina',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminare la schedina?'),
                content: const Text('L\'esito registrato va perso. L\'operazione non riguarda denaro reale.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina')),
                ],
              ),
            );
            if (confirmed != true) return;
            await ref.read(walletRepositoryProvider).deleteTicket(id);
            ref.invalidate(ticketsProvider);
            ref.invalidate(walletSummaryProvider);
            if (context.mounted) context.pop();
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
      child: AsyncBody<List<StoredTicket>>(
        value: tickets,
        onRetry: () => ref.invalidate(ticketsProvider),
        data: (items) {
          final match = items.where((t) => t.id == id);
          if (match.isEmpty) return const Center(child: Text('Schedina non trovata.'));
          return _TicketDetail(ticket: match.first);
        },
      ),
    );
  }
}

class _TicketDetail extends ConsumerWidget {
  const _TicketDetail({required this.ticket});

  final StoredTicket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evaluation = ticket.evaluation;
    final drawDate = evaluation?.drawDate ?? ticket.targetDrawDate;
    final drawn = drawDate == null ? null : ref.watch(_drawsOnProvider(drawDate));
    final wheelName = ticket.coversAllWheels ? 'Tutte le ruote (senza Nazionale)' : (wheelByCode(ticket.wheelCode)?.name ?? ticket.wheelCode);
    final wheels = ticket.coversAllWheels ? [for (final w in officialWheels) if (w.code != 'RN') w.code] : [ticket.wheelCode];
    final published = drawn?.value ?? const <DatedWheelDraw>[];
    final hitSet = <int>{};
    for (final draw in published) {
      if (wheels.contains(draw.wheelCode)) hitSet.addAll(ticket.numbers.where(draw.numbers.contains));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: wheelName,
          trailing: Text(formatEuro(ticket.stakeCents), style: Theme.of(context).textTheme.titleMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final number in ticket.numbers) _Ball(number: number, hit: hitSet.contains(number))],
              ),
              const SizedBox(height: 10),
              Text(_stakesLabel(ticket.stakes)),
              const SizedBox(height: 4),
              Text('Registrata il ${formatItalianDate(ticket.createdAt)}'
                  '${ticket.targetDrawDate == null ? '' : ' per il concorso del ${formatItalianDate(ticket.targetDrawDate!)}'}.'),
              if (ticket.note != null) Text(ticket.note!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (ticket.isOpen) _WaitingCard(ticket: ticket),
        if (evaluation != null) _OutcomeCard(ticket: ticket, evaluation: evaluation),
        if (evaluation != null && !ticket.isLegacy) ...[
          const SizedBox(height: 16),
          _WhatIfCard(ticket: ticket, evaluation: evaluation),
        ],
        if (drawDate != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            title: 'Estrazione del ${formatItalianDate(drawDate)}',
            child: switch (drawn) {
              AsyncData(:final value) when value.isEmpty => const Text('Non ancora in archivio. Arriverà con l\'aggiornamento serale.'),
              AsyncData(:final value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final draw in value.where((d) => wheels.contains(d.wheelCode)))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(width: 90, child: Text(draw.wheelName)),
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                children: [
                                  for (final n in draw.numbers)
                                    Text(
                                      '$n',
                                      style: TextStyle(
                                        fontWeight: ticket.numbers.contains(n) ? FontWeight.w800 : FontWeight.w400,
                                        color: ticket.numbers.contains(n) ? AppColors.gold : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text('Le righe provengono dall\'archivio importato e non sono marcate come ufficialmente verificate.', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              AsyncError(:final error) => Text('Estrazione non leggibile: $error'),
              _ => const LinearProgressIndicator(),
            },
          ),
        ],
      ],
    );
  }
}

final _drawsOnProvider = FutureProvider.family<List<DatedWheelDraw>, DateTime>((ref, date) {
  ref.watch(archiveSummaryProvider);
  return ref.watch(drawRepositoryProvider).drawsOn(date);
});

class _WaitingCard extends ConsumerWidget {
  const _WaitingCard({required this.ticket});

  final StoredTicket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).value;
    final sync = ref.watch(archiveSyncProvider);
    final target = ticket.targetDrawDate;
    final check = target == null ? null : resultCheckTime(target);
    return SectionCard(
      title: 'In attesa dell\'estrazione',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(drawEveningTimeline, style: Theme.of(context).textTheme.bodySmall),
          if (check != null) ...[
            const SizedBox(height: 8),
            Text(
              'Prossimo controllo automatico: ${formatItalianDate(target!)} alle '
              '${check.hour}:${check.minute.toString().padLeft(2, '0')}'
              '${settings?.liveSyncEnabled == true ? ' (attivo).' : ' — ora spento in Impostazioni.'}',
            ),
          ],
          if (settings != null && !settings.liveSyncEnabled) ...[
            const SizedBox(height: 8),
            const Text('Senza aggiornamento serale l\'esito arriva solo se aggiorni l\'archivio a mano.'),
            TextButton(onPressed: () => context.push('/more/settings'), child: const Text('Apri impostazioni')),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: sync.running ? null : () => ref.read(archiveSyncProvider.notifier).syncOfficial(),
            icon: const Icon(Icons.sync),
            label: const Text('Controlla adesso'),
          ),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.ticket, required this.evaluation});

  final StoredTicket ticket;
  final TicketEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (ticket.isLegacy) {
      return SectionCard(
        title: 'Esito',
        child: Text('Centri: ${evaluation.hits}. Schedina creata prima della tabella premi: nessun importo calcolato.'),
      );
    }
    final balance = evaluation.netCents - ticket.stakeCents;
    return SectionCard(
      title: evaluation.netCents > 0 ? 'Vincita simulata' : 'Nessuna vincita',
      trailing: Icon(evaluation.netCents > 0 ? Icons.emoji_events_outlined : Icons.close, color: evaluation.netCents > 0 ? AppColors.gold : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (evaluation.hitsByWheel.length == 1)
            Text('${evaluation.hits} centri su ${ticket.numbers.length} numeri.')
          else
            Text('Centri per ruota: ${evaluation.hitsByWheel.entries.where((e) => e.value > 0).map((e) => '${e.key} ${e.value}').join(', ')}'
                '${evaluation.hitsByWheel.values.every((v) => v == 0) ? 'nessuno' : ''}.'),
          const SizedBox(height: 8),
          for (final entry in evaluation.grossBySorte.entries)
            _Row('${entry.key.label} (posta ${formatEuro(ticket.stakes[entry.key] ?? 0)})', formatEuro(entry.value)),
          const Divider(),
          _Row('Lordo', formatEuro(evaluation.grossCents)),
          _Row('Ritenuta 8%', '− ${formatEuro(evaluation.grossCents - evaluation.netCents)}'),
          _Row('Netto', formatEuro(evaluation.netCents)),
          _Row('Posta', '− ${formatEuro(ticket.stakeCents)}'),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Expanded(child: Text('Saldo della schedina', style: TextStyle(fontWeight: FontWeight.w700))),
                Text(
                  '${balance > 0 ? '+' : ''}${formatEuro(balance)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: balance > 0 ? AppColors.gold : (balance < 0 ? theme.colorScheme.error : null),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(evaluation.note, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WhatIfCard extends StatefulWidget {
  const _WhatIfCard({required this.ticket, required this.evaluation});

  final StoredTicket ticket;
  final TicketEvaluation evaluation;

  @override
  State<_WhatIfCard> createState() => _WhatIfCardState();
}

class _WhatIfCardState extends State<_WhatIfCard> {
  var _stakeCents = 100;

  @override
  Widget build(BuildContext context) {
    final rows = whatIfBySorte(
      numbersPlayed: widget.ticket.numbers.length,
      hitsByWheel: widget.evaluation.hitsByWheel,
      stakeCents: _stakeCents,
    );
    return SectionCard(
      title: 'E se avessi puntato…',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stessi numeri, stessa estrazione, ${formatEuro(_stakeCents)} su una sola sorte.'),
          Slider(
            value: _stakeCents.toDouble(),
            min: minTicketStakeCents.toDouble(),
            max: 5000,
            divisions: (5000 - minTicketStakeCents) ~/ stakeStepCents,
            label: formatEuro(_stakeCents),
            onChanged: (value) => setState(() => _stakeCents = (value / stakeStepCents).round() * stakeStepCents),
          ),
          for (final row in rows)
            _Row(
              row.sorte.label,
              row.grossCents == 0
                  ? 'niente'
                  : '${formatEuro(netFromGrossCents(row.grossCents))} netti (saldo ${formatEuro(netFromGrossCents(row.grossCents) - _stakeCents)})',
            ),
          const SizedBox(height: 8),
          Text(
            'È un conto a posteriori sull\'estrazione già uscita: non dice nulla sulla sorte da scegliere la prossima volta.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
