// lib/app/result_notice.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_settings.dart';
import '../features/draws/data/archive_sync.dart';
import '../features/superenalotto/data/superenalotto_sync.dart';
import 'theme/app_theme.dart';

/// Avviso a schermo, oltre alla notifica di sistema: compare quando uno
/// scarico è finito e le schedine sono state controllate.
class ResultNotice {
  const ResultNotice({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  ResultNotice merge(ResultNotice other) {
    return ResultNotice(title: title, lines: [...lines, ...other.lines]);
  }
}

final resultNoticeProvider = StateProvider<ResultNotice?>((ref) => null);

class ResultNoticeHost extends ConsumerWidget {
  const ResultNoticeHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(archiveSyncProvider, (previous, next) {
      if (previous?.running != true || next.running || next.report == null || next.message != null) return;
      final report = next.report!;
      final tickets = next.evaluatedTickets;
      if (report.inserted == 0 && tickets.isEmpty) {
        _quiet(context, 'Archivio Lotto controllato: nessuna estrazione nuova e nessuna schedina da aggiornare.');
        return;
      }
      final lines = <String>[
        'Archivio Lotto scaricato. Nuove cinquine: ${report.inserted}. Già presenti: ${report.duplicates}.',
        if (tickets.isEmpty)
          'Schedine ipotetiche controllate: nessuna da aggiornare con questa estrazione.'
        else
          'Schedine confrontate: ${tickets.length}.',
        for (final ticket in tickets)
          '${ticket.coversAllWheels ? 'Tutte' : ticket.wheelCode}: ${ticket.evaluation?.hits ?? 0} centri, netto ${formatEuro(ticket.evaluation?.netCents ?? 0)} su ${formatEuro(ticket.stakeCents)}.',
      ];
      _publish(ref, ResultNotice(title: 'Controllo Lotto completato', lines: lines));
    });
    ref.listen(superenalottoSyncProvider, (previous, next) {
      if (previous?.running != true || next.running || next.report == null || next.message != null) return;
      final report = next.report!;
      if (report.inserted == 0 && report.conflicts == 0 && next.evaluatedTickets == 0) {
        _quiet(context, 'SuperEnalotto controllato: nessun concorso nuovo.');
        return;
      }
      _publish(
        ref,
        ResultNotice(
          title: 'Controllo SuperEnalotto completato',
          lines: [
            'Pagine ufficiali scaricate. Concorsi nuovi: ${report.inserted}. Già presenti: ${report.duplicates}.',
            if (next.evaluatedTickets == 0)
              'Schedine SuperEnalotto da aggiornare con questo concorso: nessuna.'
            else
              'Schedine SuperEnalotto confrontate: ${next.evaluatedTickets}. L\'esito è la categoria, non un importo in euro.',
          ],
        ),
      );
    });
    final notice = ref.watch(resultNoticeProvider);
    return Stack(
      children: [
        child,
        if (notice != null)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xCC0E1624),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(notice.title, textAlign: TextAlign.center, style: Theme.of(context).appBarTheme.titleTextStyle),
                            const SizedBox(height: 8),
                            Container(height: 8, color: AppColors.banner),
                            const SizedBox(height: 12),
                            for (final line in notice.lines)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(line),
                              ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () {
                                ref.read(resultNoticeProvider.notifier).state = null;
                                context.go('/tickets');
                              },
                              child: const Text('Vedi le schedine'),
                            ),
                            TextButton(
                              onPressed: () => ref.read(resultNoticeProvider.notifier).state = null,
                              child: const Text('Chiudi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _quiet(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _publish(WidgetRef ref, ResultNotice incoming) {
    final current = ref.read(resultNoticeProvider);
    ref.read(resultNoticeProvider.notifier).state = current == null ? incoming : current.merge(incoming);
  }
}
