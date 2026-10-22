// lib/features/superenalotto/data/superenalotto_sync.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/database/database_provider.dart';
import 'se_ticket_repository.dart';
import 'superenalotto_parser.dart';
import 'superenalotto_repository.dart';

class SuperenalottoSyncController extends Notifier<SuperenalottoSyncState> {
  var _cancel = false;

  @override
  SuperenalottoSyncState build() => const SuperenalottoSyncState.idle();

  void cancel() => _cancel = true;

  /// Ultimi concorsi pubblicati sulla pagina principale.
  Future<void> syncLatest() => _pages(const [SuperenalottoArchiveLocations.pageUrl], label: 'ultimi concorsi');

  /// Pagine mensili ufficiali dall'anno [fromYear] fino a oggi.
  /// È il sostituto dello ZIP, che il sito non pubblica.
  Future<void> syncMonths({int fromYear = 2023}) async {
    final now = DateTime.now();
    final urls = <String>[];
    for (var year = fromYear; year <= now.year; year++) {
      final lastMonth = year == now.year ? now.month : 12;
      for (var month = 1; month <= lastMonth; month++) {
        urls.add(SuperenalottoArchiveLocations.monthUrl(year, month));
      }
    }
    await _pages(urls, label: 'archivio mensile');
  }

  Future<void> _pages(List<String> urls, {required String label}) async {
    if (state.running) return;
    _cancel = false;
    final repository = ref.read(superenalottoRepositoryProvider);
    final dio = ref.read(dioProvider);
    var total = const SuperenalottoImportReport(parsed: 0, inserted: 0, duplicates: 0, conflicts: 0, invalid: 0);
    state = const SuperenalottoSyncState.running(message: 'Scarico l\'archivio ufficiale', progress: 0.02);
    try {
      for (var i = 0; i < urls.length; i++) {
        if (_cancel) {
          state = SuperenalottoSyncState.idle(message: 'Scarico annullato.', report: total);
          return;
        }
        final html = await _download(dio, urls[i]);
        if (html == null) continue;
        final parsed = parseSuperenalottoArchiveHtml(html);
        final report = await repository.importParsed(draws: parsed, provenance: urls[i]);
        total += report;
        state = SuperenalottoSyncState.running(
          message: 'Pagine ${i + 1} di ${urls.length}',
          progress: (i + 1) / urls.length,
        );
      }
      ref.invalidate(superenalottoDrawsProvider);
      ref.invalidate(superenalottoHistoryProvider);
      var checked = 0;
      try {
        checked = await SeTicketRepository(ref.read(databaseProvider)).evaluateOpen();
        ref.invalidate(seTicketsProvider);
      } catch (_) {
        checked = 0;
      }
      state = SuperenalottoSyncState.done(total, evaluatedTickets: checked);
    } catch (error) {
      state = SuperenalottoSyncState.failed(error is StateError ? error.message : 'Archivio SuperEnalotto non scaricato.');
    }
  }
}

Future<String?> _download(Dio dio, String url) async {
  final response = await dio.get<String>(
    url,
    options: Options(
      responseType: ResponseType.plain,
      headers: {'User-Agent': SuperenalottoArchiveLocations.userAgent},
      validateStatus: (code) => code != null && code < 500,
    ),
  );
  final status = response.statusCode ?? 0;
  if (status >= 400 && status < 500) return null;
  if (status >= 500) throw StateError('Risposta HTTP $status dall\'archivio SuperEnalotto.');
  final body = response.data;
  if (body == null || body.isEmpty) throw StateError('La pagina ufficiale è vuota.');
  return body;
}

/// Usato dal task serale, senza Riverpod. Una pagina sola: gli ultimi concorsi.
Future<SuperenalottoImportReport> syncSuperenalottoLatest({required SuperenalottoRepository repository, required Dio dio}) async {
  final html = await _download(dio, SuperenalottoArchiveLocations.pageUrl);
  if (html == null) throw StateError('La pagina ufficiale degli ultimi concorsi non è disponibile.');
  return repository.importParsed(draws: parseSuperenalottoArchiveHtml(html), provenance: SuperenalottoArchiveLocations.pageUrl);
}

class SuperenalottoSyncState {
  const SuperenalottoSyncState.idle({this.message, this.report})
      : running = false,
        progress = 0,
        error = null,
        evaluatedTickets = 0;
  const SuperenalottoSyncState.running({required this.message, required this.progress})
      : running = true,
        report = null,
        error = null,
        evaluatedTickets = 0;
  const SuperenalottoSyncState.done(this.report, {this.evaluatedTickets = 0})
      : running = false,
        progress = 1,
        message = null,
        error = null;
  const SuperenalottoSyncState.failed(this.error)
      : running = false,
        progress = 0,
        message = null,
        report = null,
        evaluatedTickets = 0;

  final bool running;
  final double progress;
  final String? message;
  final String? error;
  final SuperenalottoImportReport? report;
  final int evaluatedTickets;
}

final superenalottoSyncProvider = NotifierProvider<SuperenalottoSyncController, SuperenalottoSyncState>(SuperenalottoSyncController.new);
