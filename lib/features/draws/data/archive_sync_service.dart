// lib/features/draws/data/archive_sync_service.dart

import 'dart:convert';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';

import '../../../core/lotto/archive_parser.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/parsed_draw.dart';
import '../../virtual_wallet/data/wallet_repository.dart';
import 'draw_repository.dart';
import 'import_preparation.dart';

typedef SyncLoader = Future<({PreparedImport prepared, String? lastModified})> Function();
typedef SyncProgress = void Function(String message, double progress);

class SyncOutcome {
  const SyncOutcome({required this.report, required this.freshnessLabel, required this.evaluatedTickets});

  final ImportReport report;
  final String freshnessLabel;

  /// Schedine ipotetiche valutate grazie alle estrazioni appena importate.
  final List<StoredTicket> evaluatedTickets;
}

/// Scarica, prepara e importa un archivio aggiornando fonte e log.
/// Non conosce Riverpod: lo usano il controller in primo piano e il task
/// WorkManager a app chiusa.
class ArchiveSyncService {
  ArchiveSyncService({required this.repository, required this.wallet, required this.dio});

  final DrawRepository repository;
  final WalletRepository wallet;
  final Dio dio;

  Future<SyncOutcome> syncOfficial({SyncProgress? onProgress, bool Function()? isCancelled}) {
    return run(
      sourceCode: 'lotto_italia_archive',
      provenance: OfficialArchiveLocations.archiveUrl,
      load: () => downloadOfficial(onProgress: onProgress),
      onProgress: onProgress,
      isCancelled: isCancelled,
    );
  }

  Future<({PreparedImport prepared, String? lastModified})> downloadOfficial({SyncProgress? onProgress}) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await dio.get<List<int>>(
          OfficialArchiveLocations.archiveUrl,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'User-Agent': OfficialArchiveLocations.userAgent},
          ),
          onReceiveProgress: (received, total) {
            final fraction = total <= 0 ? null : received / total;
            onProgress?.call('Scarico l\'archivio pubblicato', fraction == null ? 0.05 : 0.05 + fraction * 0.25);
          },
        );
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          throw StateError('Il file scaricato è vuoto.');
        }
        onProgress?.call('Apro lo ZIP e controllo le righe', 0.32);
        final prepared = await prepareBytes(bytes, zipped: true, parser: parseOfficialArchiveText);
        return (prepared: prepared, lastModified: response.headers.value('last-modified'));
      } on DioException catch (error) {
        lastError = error;
        final code = error.response?.statusCode ?? 0;
        final retryable = code == 0 || code == 429 || code >= 500;
        if (!retryable || attempt == 2) {
          throw StateError(publicDioError(error));
        }
        await Future<void>.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw StateError('$lastError');
  }

  Future<SyncOutcome> run({
    required String sourceCode,
    required String provenance,
    required SyncLoader load,
    SyncProgress? onProgress,
    bool Function()? isCancelled,
  }) async {
    final started = DateTime.now().toUtc();
    onProgress?.call('Preparazione', 0.02);
    try {
      final loaded = await load();
      if (isCancelled?.call() ?? false) {
        return SyncOutcome(
          report: _cancelledReport(loaded.prepared),
          freshnessLabel: freshnessLabel((await repository.summary()).freshness),
          evaluatedTickets: const [],
        );
      }
      onProgress?.call('Confronto con l\'archivio locale', 0.4);
      final report = await repository.importPrepared(
        prepared: loaded.prepared,
        sourceCode: sourceCode,
        provenance: provenance,
        isCancelled: isCancelled ?? () => false,
        onProgress: (done, total) {
          final fraction = total == 0 ? 1.0 : done / total;
          onProgress?.call(
            done < total ? 'Controllate $done di $total cinquine' : 'Scrivo le cinquine nuove',
            0.4 + fraction * 0.55,
          );
        },
      );
      final summary = await repository.summary();
      final storedStatus = sourceCode == 'lotto_italia_archive' && !report.cancelled && report.invalid == 0
          ? switch (summary.freshness) {
              SourceFreshness.updated => 'updated',
              SourceFreshness.delayed => 'delayed',
              SourceFreshness.unavailable => 'unavailable',
              SourceFreshness.unverified => 'unverified',
            }
          : 'unverified';
      if (!report.cancelled) {
        await repository.updateSource(
          code: sourceCode,
          status: storedStatus,
          error: report.invalid == 0 ? null : 'Importazione con ${report.invalid} righe non valide.',
          httpLastModified: loaded.lastModified,
          success: report.invalid == 0 || report.inserted > 0,
        );
      }
      await repository.writeSyncLog(
        sourceCode: sourceCode,
        startedAt: started,
        status: report.cancelled ? 'cancelled' : 'completed',
        report: report,
        message: report.samples.isEmpty ? null : report.samples.join('\n'),
      );
      var evaluated = const <StoredTicket>[];
      if (!report.cancelled) {
        onProgress?.call('Confronto le schedine ipotetiche', 0.97);
        evaluated = await wallet.evaluateOpenTickets();
      }
      return SyncOutcome(report: report, freshnessLabel: freshnessLabel(summary.freshness), evaluatedTickets: evaluated);
    } catch (error) {
      final message = error is StateError ? error.message : 'Aggiornamento non riuscito.';
      await repository.updateSource(code: sourceCode, status: 'unavailable', error: message, success: false);
      await repository.writeSyncLog(
        sourceCode: sourceCode,
        startedAt: started,
        status: 'failed',
        report: null,
        message: message,
      );
      throw StateError(message);
    }
  }

  ImportReport _cancelledReport(PreparedImport prepared) => ImportReport(
        parsed: prepared.parsed,
        inserted: 0,
        duplicates: 0,
        conflicts: 0,
        invalid: prepared.invalid,
        samples: const [],
        cancelled: true,
      );
}

// Funzioni top-level: la closura inviata all'isolate deve catturare solo
// questi argomenti, non il servizio o il controller.
Future<PreparedImport> prepareBytes(
  List<int> bytes, {
  required bool zipped,
  required ParseBatch Function(String text) parser,
}) {
  return Isolate.run(() => prepareImport(parser(zipped ? textFromZip(bytes) : utf8.decode(bytes)).draws));
}

Future<PreparedImport> prepareText(String text, ParseBatch Function(String text) parser) {
  return Isolate.run(() => prepareImport(parser(text).draws));
}

String textFromZip(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  ArchiveFile? chosen;
  for (final file in archive) {
    if (!file.isFile || !file.name.toLowerCase().endsWith('.txt')) continue;
    if (file.size > 20 * 1024 * 1024) {
      throw StateError('Il file interno supera il limite di 20 MB.');
    }
    if (chosen == null || file.size > chosen.size) chosen = file;
  }
  if (chosen == null) throw StateError('Lo ZIP non contiene un file di testo.');
  return utf8.decode(chosen.content);
}

ParseBatch Function(String text) parserForName(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.json')) return parseManualJson;
  if (lower.endsWith('.csv')) return parseManualCsv;
  return parseOfficialArchiveText;
}

String publicDioError(DioException error) {
  final code = error.response?.statusCode;
  if (code == 401 || code == 403) return 'Accesso rifiutato (HTTP $code).';
  if (code == 404) return 'Archivio non trovato (HTTP 404). L\'indirizzo pubblicato potrebbe essere cambiato.';
  if (code == 429) return 'La fonte ha limitato le richieste (HTTP 429).';
  if (code != null) return 'Risposta HTTP $code dalla fonte dell\'archivio.';
  return 'Connessione all\'archivio non riuscita.';
}
