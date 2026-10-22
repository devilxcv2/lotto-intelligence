// lib/features/draws/data/archive_sync.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/lotto/archive_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../../statistics/data/statistics_providers.dart';
import '../../virtual_wallet/data/wallet_repository.dart';
import 'archive_sync_service.dart';
import 'draw_repository.dart';

class ArchiveSyncController extends Notifier<ArchiveSyncState> {
  bool _cancel = false;

  @override
  ArchiveSyncState build() => const ArchiveSyncState.idle();

  void cancel() => _cancel = true;

  ArchiveSyncService get _service => ArchiveSyncService(
        repository: ref.read(drawRepositoryProvider),
        wallet: ref.read(walletRepositoryProvider),
        dio: ref.read(dioProvider),
      );

  Future<void> syncOfficial() {
    final service = _service;
    return _run(
      sourceCode: 'lotto_italia_archive',
      provenance: OfficialArchiveLocations.archiveUrl,
      load: () => service.downloadOfficial(onProgress: _progress),
    );
  }

  Future<void> importPicked({required String filename, required List<int> bytes}) {
    final lower = filename.toLowerCase();
    final zipped = lower.endsWith('.zip');
    final parser = parserForName(zipped ? '$filename.txt' : filename);
    return _run(
      sourceCode: 'manual_import',
      provenance: 'file:$filename',
      load: () async => (prepared: await prepareBytes(bytes, zipped: zipped, parser: parser), lastModified: null),
    );
  }

  Future<void> importText({
    required String filename,
    required String text,
    required bool zippedOfficialLayout,
  }) {
    final parser = zippedOfficialLayout ? parseOfficialArchiveText : parserForName(filename);
    return _run(
      sourceCode: zippedOfficialLayout ? 'lotto_italia_archive' : 'manual_import',
      provenance: 'file:$filename',
      load: () async => (prepared: await prepareText(text, parser), lastModified: null),
    );
  }

  void _progress(String message, double progress) {
    if (!state.running) return;
    state = ArchiveSyncState.running(message: message, progress: progress);
  }

  Future<void> _run({
    required String sourceCode,
    required String provenance,
    required SyncLoader load,
  }) async {
    if (state.running) return;
    _cancel = false;
    state = const ArchiveSyncState.running(message: 'Preparazione', progress: 0.02);
    try {
      final outcome = await _service.run(
        sourceCode: sourceCode,
        provenance: provenance,
        load: load,
        onProgress: _progress,
        isCancelled: () => _cancel,
      );
      _invalidate();
      if (outcome.evaluatedTickets.isNotEmpty) {
        ref.invalidate(ticketsProvider);
        ref.invalidate(walletSummaryProvider);
      }
      state = outcome.report.cancelled
          ? const ArchiveSyncState.idle(message: 'Aggiornamento annullato.')
          : ArchiveSyncState.done(outcome.report, outcome.freshnessLabel, outcome.evaluatedTickets);
    } catch (error) {
      _invalidate();
      state = ArchiveSyncState.failed(error is StateError ? error.message : 'Aggiornamento non riuscito.');
    }
  }

  void _invalidate() {
    ref.invalidate(archiveSummaryProvider);
    ref.invalidate(wheelDrawsProvider);
    ref.invalidate(wheelStatisticsProvider);
  }
}

class ArchiveSyncState {
  const ArchiveSyncState.idle({this.message})
      : running = false,
        progress = 0,
        report = null,
        error = null,
        evaluatedTickets = const [];
  const ArchiveSyncState.running({required this.message, required this.progress})
      : running = true,
        report = null,
        error = null,
        evaluatedTickets = const [];
  const ArchiveSyncState.done(this.report, this.message, this.evaluatedTickets)
      : running = false,
        progress = 1,
        error = null;
  const ArchiveSyncState.failed(this.error)
      : running = false,
        progress = 0,
        message = null,
        report = null,
        evaluatedTickets = const [];

  final bool running;
  final double progress;
  final String? message;
  final String? error;
  final ImportReport? report;
  final List<StoredTicket> evaluatedTickets;
}

final archiveSyncProvider = NotifierProvider<ArchiveSyncController, ArchiveSyncState>(ArchiveSyncController.new);
