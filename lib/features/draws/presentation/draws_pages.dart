// lib/features/draws/presentation/draws_pages.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/draw_validation.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../superenalotto/data/superenalotto_sync.dart';
import '../../superenalotto/presentation/superenalotto_page.dart';
import '../data/archive_sync.dart';
import '../data/draw_repository.dart';

final drawsGameProvider = StateProvider<int>((ref) => 0);

class DrawsPage extends ConsumerWidget {
  const DrawsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(drawsGameProvider);
    final summary = ref.watch(archiveSummaryProvider);
    final sync = ref.watch(archiveSyncProvider);
    final superSync = ref.watch(superenalottoSyncProvider);
    final busy = game == 1 ? superSync.running : sync.running;
    return PageScaffold(
      title: game == 1 ? 'SuperEnalotto' : 'Gioco del Lotto',
      actions: [
        IconButton(tooltip: 'Archivio', onPressed: () => context.push('/draws/archive'), icon: const Icon(Icons.schedule)),
        IconButton(
          tooltip: 'Aggiorna',
          onPressed: busy
              ? null
              : () {
                  if (game == 1) {
                    ref.read(superenalottoSyncProvider.notifier).syncLatest();
                  } else {
                    ref.read(archiveSyncProvider.notifier).syncOfficial();
                  }
                },
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Lotto'), icon: Icon(Icons.table_chart_outlined)),
                ButtonSegment(value: 1, label: Text('SuperEnalotto'), icon: Icon(Icons.stars_outlined)),
              ],
              selected: {game},
              onSelectionChanged: (value) => ref.read(drawsGameProvider.notifier).state = value.first,
            ),
          ),
          Expanded(child: game == 1 ? const SuperenalottoBoard() : _LottoDraws(summary: summary)),
        ],
      ),
    );
  }
}

class _LottoDraws extends ConsumerWidget {
  const _LottoDraws({required this.summary});

  final AsyncValue<ArchiveSummary> summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (data) {
          if (data.latestDate == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EmptyArchive(onSync: () => ref.read(archiveSyncProvider.notifier).syncOfficial()),
                const SizedBox(height: 16),
                const _WheelList(),
              ],
            );
          }
          final day = ref.watch(_dayProvider(dateOnlyUtc(data.latestDate!)));
          return ListView(
            children: [
              day.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$error')),
                data: (items) => DrawBoard(
                  banner: 'Estrazione del ${formatItalianDate(data.latestDate!)}',
                  rows: [
                    for (final item in items) (wheel: item.wheelName, numbers: item.numbers, code: item.wheelCode),
                  ],
                  footer: 'Tocca una ruota per lo storico. Le cinquine vengono dall\'archivio importato e non sono marcate come ufficialmente verificate.',
                  onWheelTap: (code) => context.push('/draws/wheel/$code'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: OutlinedButton(
                  onPressed: () => context.push('/draws/day/${formatIsoDate(data.latestDate!)}'),
                  child: const Text('Apri il giorno'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Tutte le ruote', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const _WheelList(),
              ListTile(
                leading: const Icon(Icons.file_open, color: AppColors.navy),
                title: const Text('Importa un file'),
                onTap: () => _import(context, ref),
              ),
            ],
          );
        },
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Importa estrazioni',
      type: FileType.custom,
      allowedExtensions: const ['zip', 'txt', 'csv', 'json'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await ref.read(archiveSyncProvider.notifier).importPicked(filename: file.name, bytes: bytes);
  }
}

class _WheelList extends StatelessWidget {
  const _WheelList();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        for (var i = 0; i < officialWheels.length; i++)
          ColoredBox(
            color: i.isOdd ? (dark ? const Color(0xFF1A283C) : AppColors.rowAlt) : Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.banner,
                child: Text(
                  officialWheels[i].code,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              title: Text(officialWheels[i].name, style: const TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w700)),
              subtitle: const Text('Storico e ultime cinquine'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.numberBlue),
              onTap: () => context.push('/draws/wheel/${officialWheels[i].code}'),
            ),
          ),
      ],
    );
  }
}

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  DateTime? _month;

  @override
  Widget build(BuildContext context) {
    final bounds = ref.watch(_boundsProvider);
    return PageScaffold(
      title: 'Archivio',
      child: bounds.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (range) {
          if (range.last == null) {
            return const Center(child: Text('Archivio vuoto.'));
          }
          final last = range.last!.toUtc();
          final selected = _month ?? DateTime.utc(last.year, last.month);
          final dates = ref.watch(_monthProvider((selected.year, selected.month)));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _month = DateTime.utc(selected.year, selected.month - 1)),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(child: Text('${selected.month.toString().padLeft(2, '0')}/${selected.year}', textAlign: TextAlign.center)),
                  IconButton(
                    onPressed: () => setState(() => _month = DateTime.utc(selected.year, selected.month + 1)),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              dates.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('$error'),
                data: (items) {
                  if (items.isEmpty) return const Text('Nessuna estrazione in questo mese.');
                  return Column(
                    children: [
                      for (final date in items)
                        ListTile(
                          title: Text(formatItalianDate(date)),
                          onTap: () => context.push('/draws/day/${formatIsoDate(date)}'),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

final _boundsProvider = FutureProvider<({DateTime? first, DateTime? last})>((ref) {
  return ref.watch(drawRepositoryProvider).dateBounds();
});

final _monthProvider = FutureProvider.family<List<DateTime>, (int, int)>((ref, key) {
  return ref.watch(drawRepositoryProvider).datesInMonth(key.$1, key.$2);
});

class DrawDayPage extends ConsumerWidget {
  const DrawDayPage({required this.isoDate, super.key});

  final String isoDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = parseDrawDate(isoDate);
    if (date == null) {
      return const PageScaffold(title: 'Estrazione', child: Center(child: Text('Data non valida.')));
    }
    final draws = ref.watch(_dayProvider(date.toUtc()));
    return PageScaffold(
      title: formatItalianDate(date),
      child: AsyncBody<List<DatedWheelDraw>>(
        value: draws,
        onRetry: () => ref.invalidate(_dayProvider(date.toUtc())),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nessuna cinquina in questa data.'));
          }
          return ListView(
            children: [
              DrawBoard(
                banner: 'Estrazione del ${formatItalianDate(date)}',
                rows: [
                  for (final item in items) (wheel: item.wheelName, numbers: item.numbers, code: item.wheelCode),
                ],
                footer: 'Provenienza: ${items.first.provenance}. Tocca una ruota per lo storico. Nessuna estrazione è segnata come ufficialmente verificata.',
                onWheelTap: (code) => context.push('/draws/wheel/$code'),
              ),
            ],
          );
        },
      ),
    );
  }
}

final _dayProvider = FutureProvider.family<List<DatedWheelDraw>, DateTime>((ref, date) {
  return ref.watch(drawRepositoryProvider).drawsOn(date);
});

class WheelDetailPage extends ConsumerWidget {
  const WheelDetailPage({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wheel = wheelByCode(code);
    final draws = ref.watch(wheelDrawsProvider(code));
    return PageScaffold(
      title: wheel?.name ?? code,
      child: AsyncBody(
        value: draws,
        onRetry: () => ref.invalidate(wheelDrawsProvider(code)),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Nessuna estrazione per questa ruota.'));
          final latest = items.last;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Ultima data: ${formatItalianDate(latest.date)}'),
              const SizedBox(height: 8),
              NumberBalls(numbers: latest.numbers),
              const SizedBox(height: 12),
              Text('${items.length} estrazioni archiviate.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/more/statistics'),
                child: const Text('Apri le statistiche'),
              ),
            ],
          );
        },
      ),
    );
  }
}
