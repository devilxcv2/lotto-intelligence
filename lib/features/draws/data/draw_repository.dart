// lib/features/draws/data/draw_repository.dart

import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/lotto/draw_validation.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/parsed_draw.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../statistics/domain/statistics_engine.dart';
import 'import_preparation.dart';

class ImportReport {
  const ImportReport({
    required this.parsed,
    required this.inserted,
    required this.duplicates,
    required this.conflicts,
    required this.invalid,
    required this.samples,
    required this.cancelled,
    this.earliest,
    this.latest,
  });

  final int parsed;
  final int inserted;
  final int duplicates;
  final int conflicts;
  final int invalid;
  final List<String> samples;
  final bool cancelled;
  final DateTime? earliest;
  final DateTime? latest;
}

class ArchiveSummary {
  const ArchiveSummary({
    required this.drawCount,
    required this.latestDate,
    required this.sourceStatus,
    required this.sourceNotes,
    required this.lastSuccessAt,
    required this.lastError,
    required this.httpLastModified,
    required this.freshness,
  });

  final int drawCount;
  final DateTime? latestDate;
  final String sourceStatus;
  final String? sourceNotes;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final String? httpLastModified;
  final SourceFreshness freshness;
}

class DatedWheelDraw {
  const DatedWheelDraw({
    required this.date,
    required this.wheelCode,
    required this.wheelName,
    required this.numbers,
    required this.officiallyVerified,
    required this.provenance,
  });

  final DateTime date;
  final String wheelCode;
  final String wheelName;
  final List<int> numbers;
  final bool officiallyVerified;
  final String provenance;
}

class DrawRepository {
  DrawRepository(this._db);

  final AppDatabase _db;

  Future<ArchiveSummary> summary({DateTime? now}) async {
    final countRow = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM draws',
      readsFrom: {_db.draws},
    ).getSingle();
    final latest = await (_db.select(_db.draws)
          ..orderBy([(row) => OrderingTerm.desc(row.drawDate)])
          ..limit(1))
        .getSingleOrNull();
    final source = await (_db.select(_db.dataSources)..where((row) => row.code.equals('lotto_italia_archive'))).getSingle();
    final clock = now ?? DateTime.now();
    return ArchiveSummary(
      drawCount: countRow.read<int>('c'),
      latestDate: latest?.drawDate,
      sourceStatus: source.status,
      sourceNotes: source.notes,
      lastSuccessAt: source.lastSuccessAt,
      lastError: source.lastError,
      httpLastModified: source.httpLastModified,
      freshness: evaluateFreshness(
        latestDrawDate: latest?.drawDate,
        now: clock,
        hasSuccessfulSync: source.lastSuccessAt != null,
        lastAttemptFailed: source.lastError != null && source.lastSuccessAt == null,
      ),
    );
  }

  /// Una ruota ha migliaia di estrazioni: decodificarle riga per riga dal
  /// canale del database blocca i frame. SQLite le restituisce come
  /// un'unica stringa compatta, decodificata e ordinata su un isolate.
  Future<List<ArchivedDraw>> loadWheel(String code) async {
    final row = await _db.customSelect(
      "SELECT group_concat(x, ';') AS packed FROM ("
      "SELECT d.draw_date || ':' || group_concat(n.position || '=' || n.number, ',') AS x "
      'FROM draws d JOIN wheels w ON w.id = d.wheel_id JOIN draw_numbers n ON n.draw_id = d.id '
      'WHERE w.code = ? GROUP BY d.id HAVING COUNT(*) = 5)',
      variables: [Variable.withString(code)],
      readsFrom: {_db.draws, _db.wheels, _db.drawNumbers},
    ).getSingle();
    final packed = row.read<String?>('packed');
    if (packed == null || packed.isEmpty) return const [];
    return _unpackWheel(packed);
  }

  Future<List<DatedWheelDraw>> drawsOn(DateTime date) async {
    final start = DateTime.utc(date.toUtc().year, date.toUtc().month, date.toUtc().day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.drawNumbers).join([
      innerJoin(_db.draws, _db.draws.id.equalsExp(_db.drawNumbers.drawId)),
      innerJoin(_db.wheels, _db.wheels.id.equalsExp(_db.draws.wheelId)),
    ])
          ..where(_db.draws.drawDate.isBiggerOrEqualValue(start) & _db.draws.drawDate.isSmallerThanValue(end))
          ..orderBy([
            OrderingTerm.asc(_db.wheels.sortOrder),
            OrderingTerm.asc(_db.drawNumbers.position),
          ]))
        .get();
    final grouped = <String, DatedWheelDraw>{};
    final ordered = <String>[];
    for (final row in rows) {
      final draw = row.readTable(_db.draws);
      final wheel = row.readTable(_db.wheels);
      final number = row.readTable(_db.drawNumbers).number;
      final existing = grouped[wheel.code];
      if (existing == null) {
        ordered.add(wheel.code);
        grouped[wheel.code] = DatedWheelDraw(
          date: draw.drawDate,
          wheelCode: wheel.code,
          wheelName: wheel.name,
          numbers: [number],
          officiallyVerified: draw.officiallyVerified,
          provenance: draw.provenance,
        );
      } else {
        grouped[wheel.code] = DatedWheelDraw(
          date: existing.date,
          wheelCode: existing.wheelCode,
          wheelName: existing.wheelName,
          numbers: [...existing.numbers, number],
          officiallyVerified: existing.officiallyVerified,
          provenance: existing.provenance,
        );
      }
    }
    return [for (final code in ordered) grouped[code]!];
  }

  Future<List<DateTime>> datesInMonth(int year, int month) async {
    final start = DateTime.utc(year, month);
    final end = DateTime.utc(year, month + 1);
    final rows = await _db.customSelect(
      'SELECT DISTINCT draw_date AS d FROM draws WHERE draw_date >= ? AND draw_date < ? ORDER BY draw_date',
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
      readsFrom: {_db.draws},
    ).get();
    return [for (final row in rows) row.read<DateTime>('d')];
  }

  Future<({DateTime? first, DateTime? last})> dateBounds() async {
    final row = await _db.customSelect(
      'SELECT MIN(draw_date) AS first, MAX(draw_date) AS last FROM draws',
      readsFrom: {_db.draws},
    ).getSingle();
    return (first: row.read<DateTime?>('first'), last: row.read<DateTime?>('last'));
  }

  Future<List<WheelDateGap>> wheelGaps() async {
    final rows = await _db.customSelect(
      'SELECT w.code AS c, d.draw_date AS d FROM draws d JOIN wheels w ON w.id = d.wheel_id',
      readsFrom: {_db.draws, _db.wheels},
    ).get();
    final map = <String, Set<DateTime>>{};
    for (final row in rows) {
      map.putIfAbsent(row.read<String>('c'), () => {}).add(dateOnlyUtc(row.read<DateTime>('d')));
    }
    return _gapsInBackground(map);
  }

  Future<int> countStructuralIssues() async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM (SELECT draw_id FROM draw_numbers GROUP BY draw_id HAVING COUNT(*) <> 5)',
      readsFrom: {_db.drawNumbers},
    ).getSingle();
    return row.read<int>('c');
  }

  /// Comodo per file piccoli e test. Per l'archivio completo il chiamante
  /// esegue [prepareImport] su un isolate e usa [importPrepared].
  Future<ImportReport> importParsed({
    required List<ParsedDraw> draws,
    required String sourceCode,
    required String provenance,
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) {
    return importPrepared(
      prepared: prepareImport(draws),
      sourceCode: sourceCode,
      provenance: provenance,
      onProgress: onProgress,
      isCancelled: isCancelled,
    );
  }

  /// Le righe passano per una tabella temporanea; deduplica, conflitti e
  /// inserimento sono query SQL eseguite sull'isolate del database, così
  /// l'archivio già presente non viene mai caricato nella memoria della UI.
  Future<ImportReport> importPrepared({
    required PreparedImport prepared,
    required String sourceCode,
    required String provenance,
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final source = await (_db.select(_db.dataSources)..where((row) => row.code.equals(sourceCode))).getSingle();
    final wheels = await _db.select(_db.wheels).get();
    final wheelIds = {for (final wheel in wheels) wheel.code: wheel.id};
    final samples = [...prepared.samples];
    final rows = prepared.rows;
    var duplicates = prepared.duplicatesInFile;
    var conflicts = prepared.conflictsInFile;
    var inserted = 0;
    var cancelled = false;

    if (rows.isNotEmpty) {
      try {
        await _db.transaction(() async {
          await _db.customStatement(
            'CREATE TEMP TABLE IF NOT EXISTS import_staging ('
            'draw_date INTEGER NOT NULL, wheel_id INTEGER NOT NULL, content_hash TEXT NOT NULL, '
            'contest_number INTEGER, n1 INTEGER NOT NULL, n2 INTEGER NOT NULL, n3 INTEGER NOT NULL, '
            'n4 INTEGER NOT NULL, n5 INTEGER NOT NULL)',
          );
          await _db.customStatement('DELETE FROM import_staging');
          // Blocchi piccoli: ognuno viene costruito e serializzato sul thread
          // della UI prima di passare all'isolate del database.
          const chunk = 250;
          for (var offset = 0; offset < rows.length; offset += chunk) {
            if (isCancelled?.call() == true) throw const _ImportCancelled();
            final end = offset + chunk > rows.length ? rows.length : offset + chunk;
            await _db.batch((batch) {
              for (var i = offset; i < end; i++) {
                final row = rows[i];
                batch.customStatement(
                  'INSERT INTO import_staging VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                  [
                    _db.typeMapping.mapToSqlVariable(row.date),
                    wheelIds[row.wheelCode]!,
                    row.hash,
                    row.contestNumber,
                    ...row.numbers,
                  ],
                );
              }
            });
            onProgress?.call(end, rows.length);
          }
          if (isCancelled?.call() == true) throw const _ImportCancelled();

          const matchExisting = 'FROM import_staging s JOIN draws d ON d.draw_date = s.draw_date AND d.wheel_id = s.wheel_id';
          final duplicateRow = await _db
              .customSelect('SELECT COUNT(*) AS c $matchExisting WHERE d.content_hash = s.content_hash')
              .getSingle();
          duplicates += duplicateRow.read<int>('c');
          final conflictRows = await _db
              .customSelect(
                'SELECT s.draw_date AS d, w.code AS w $matchExisting JOIN wheels w ON w.id = s.wheel_id '
                'WHERE d.content_hash <> s.content_hash',
              )
              .get();
          conflicts += conflictRows.length;
          for (final row in conflictRows) {
            if (samples.length >= 8) break;
            samples.add(
              '${formatItalianDate(row.read<DateTime>('d'))} ${row.read<String>('w')}: numeri diversi da quelli già archiviati, riga non sovrascritta.',
            );
          }

          final importedAt = DateTime.now().toUtc();
          final lastIdRow = await _db.customSelect('SELECT COALESCE(MAX(id), 0) AS m FROM draws').getSingle();
          final lastId = lastIdRow.read<int>('m');
          inserted = await _db.customUpdate(
            'INSERT INTO draws (draw_date, contest_number, wheel_id, source_id, provenance, content_hash, '
            'imported_at, officially_verified, structural_integrity_ok) '
            'SELECT s.draw_date, s.contest_number, s.wheel_id, ?, ?, s.content_hash, ?, 0, 1 FROM import_staging s '
            'WHERE NOT EXISTS (SELECT 1 FROM draws d WHERE d.draw_date = s.draw_date AND d.wheel_id = s.wheel_id)',
            variables: [Variable.withInt(source.id), Variable.withString(provenance), Variable.withDateTime(importedAt)],
            updates: {_db.draws},
            updateKind: UpdateKind.insert,
          );
          final perPosition = [
            for (var position = 1; position <= 5; position++)
              'SELECT d.id, $position, s.n$position $matchExisting AND d.content_hash = s.content_hash WHERE d.id > ?',
          ];
          await _db.customUpdate(
            'INSERT INTO draw_numbers (draw_id, position, number) ${perPosition.join(' UNION ALL ')}',
            variables: [for (var i = 0; i < 5; i++) Variable.withInt(lastId)],
            updates: {_db.drawNumbers},
            updateKind: UpdateKind.insert,
          );
          await _db.customStatement('DELETE FROM import_staging');
        });
      } on _ImportCancelled {
        cancelled = true;
        inserted = 0;
      }
    }

    return ImportReport(
      parsed: prepared.parsed,
      inserted: inserted,
      duplicates: cancelled ? prepared.duplicatesInFile : duplicates,
      conflicts: cancelled ? prepared.conflictsInFile : conflicts,
      invalid: prepared.invalid,
      samples: samples,
      cancelled: cancelled,
      earliest: prepared.earliest,
      latest: prepared.latest,
    );
  }

  Future<void> writeSyncLog({
    required String sourceCode,
    required DateTime startedAt,
    required String status,
    required ImportReport? report,
    String? message,
  }) async {
    final source = await (_db.select(_db.dataSources)..where((row) => row.code.equals(sourceCode))).getSingle();
    await _db.into(_db.syncLogs).insert(SyncLogsCompanion.insert(
          sourceId: source.id,
          startedAt: startedAt,
          finishedAt: Value(DateTime.now().toUtc()),
          status: status,
          parsedCount: Value(report?.parsed ?? 0),
          insertedCount: Value(report?.inserted ?? 0),
          duplicateCount: Value(report?.duplicates ?? 0),
          conflictCount: Value(report?.conflicts ?? 0),
          invalidCount: Value(report?.invalid ?? 0),
          message: Value(message),
        ));
  }

  Future<void> updateSource({
    required String code,
    required String status,
    String? error,
    String? httpLastModified,
    bool success = false,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.dataSources)..where((row) => row.code.equals(code))).write(DataSourcesCompanion(
          status: Value(status),
          lastCheckedAt: Value(now),
          lastSuccessAt: success ? Value(now) : const Value.absent(),
          lastError: Value(error),
          httpLastModified: httpLastModified == null ? const Value.absent() : Value(httpLastModified),
        ));
  }

  Future<List<DataSourceRow>> sources() => _db.select(_db.dataSources).get();

  Future<List<SyncLogRow>> recentLogs() {
    return (_db.select(_db.syncLogs)..orderBy([(row) => OrderingTerm.desc(row.startedAt)])..limit(8)).get();
  }
}

/// Formato `secondi:posizione=numero,...;...`. Drift salva le date come
/// secondi Unix; l'ordine di group_concat non è garantito, quindi si
/// ricostruiscono posizioni e cronologia.
Future<List<ArchivedDraw>> _unpackWheel(String packed) {
  return Isolate.run(() {
    final out = <ArchivedDraw>[];
    for (final item in packed.split(';')) {
      final colon = item.indexOf(':');
      final seconds = int.parse(item.substring(0, colon));
      final numbers = List<int>.filled(5, 0);
      for (final part in item.substring(colon + 1).split(',')) {
        final eq = part.indexOf('=');
        numbers[int.parse(part.substring(0, eq)) - 1] = int.parse(part.substring(eq + 1));
      }
      out.add(ArchivedDraw(
        date: DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true),
        numbers: List<int>.unmodifiable(numbers),
      ));
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  });
}

Future<List<WheelDateGap>> _gapsInBackground(Map<String, Set<DateTime>> map) {
  return Isolate.run(() => findWheelDateGaps(map));
}

class _ImportCancelled implements Exception {
  const _ImportCancelled();
}

final drawRepositoryProvider = Provider<DrawRepository>((ref) {
  return DrawRepository(ref.watch(databaseProvider));
});

final archiveSummaryProvider = FutureProvider<ArchiveSummary>((ref) {
  return ref.watch(drawRepositoryProvider).summary();
});

final wheelDrawsProvider = FutureProvider.family<List<ArchivedDraw>, String>((ref, code) {
  return ref.watch(drawRepositoryProvider).loadWheel(code);
});
