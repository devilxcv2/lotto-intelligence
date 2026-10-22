// lib/features/superenalotto/presentation/superenalotto_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../data/superenalotto_repository.dart';
import '../data/superenalotto_sync.dart';
import 'se_studio_page.dart';

class SuperenalottoBoard extends ConsumerWidget {
  const SuperenalottoBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draws = ref.watch(superenalottoDrawsProvider);
    final sync = ref.watch(superenalottoSyncProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const ResultsBanner('SuperEnalotto'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Le combinazioni arrivano dalle pagine dell\'archivio ufficiale. Non esiste uno ZIP unico da scaricare: l\'app legge quelle pagine. I premi in euro sono a montepremi e non stanno in questa tabella.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (sync.running) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sync.message ?? 'Scarico'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: sync.progress == 0 ? null : sync.progress),
              ],
            ),
          ),
        ],
        if (sync.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(sync.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        if (sync.report != null && !sync.running)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Inseriti ${sync.report!.inserted}, già presenti ${sync.report!.duplicates}, conflitti ${sync.report!.conflicts}, righe scartate ${sync.report!.invalid}.'),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: sync.running ? null : () => ref.read(superenalottoSyncProvider.notifier).syncLatest(),
                icon: const Icon(Icons.refresh),
                label: const Text('Ultimi concorsi'),
              ),
              OutlinedButton.icon(
                onPressed: sync.running ? null : () => ref.read(superenalottoSyncProvider.notifier).syncMonths(),
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('Dal 2023'),
              ),
              if (sync.running)
                TextButton(onPressed: () => ref.read(superenalottoSyncProvider.notifier).cancel(), child: const Text('Annulla')),
              OutlinedButton.icon(
                onPressed: () => context.push(seStudioRoute()),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Studio e schedine'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        draws.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$error')),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nessun concorso in archivio. «Ultimi concorsi» scarica la pagina ufficiale di oggi.'),
              );
            }
            final latest = items.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultsBanner('Concorso ${latest.contestNumber} del ${formatItalianDate(latest.date)}'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NumberBalls(numbers: latest.numbers, gold: true),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Jolly', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      NumberBalls(numbers: [latest.jolly]),
                      const SizedBox(width: 16),
                      const Text('SuperStar', style: TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      NumberBalls(numbers: [latest.superstar], gold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Combinazione non marcata come verificata con un secondo bollettino.'),
                ),
                const SizedBox(height: 12),
                for (final draw in items)
                  ColoredBox(
                    color: items.indexOf(draw).isOdd ? AppColors.rowAlt : Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 118,
                            child: Text(
                              '${formatItalianDate(draw.date)}\nNº ${draw.contestNumber}',
                              style: const TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w700, height: 1.2),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${draw.numbers.join('  ')}   J ${draw.jolly}   S ${draw.superstar}',
                              style: const TextStyle(color: AppColors.numberBlue, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
