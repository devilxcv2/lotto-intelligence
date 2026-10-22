// lib/features/superenalotto/data/superenalotto_repository.dart

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import 'superenalotto_parser.dart';

class SuperenalottoDraw {
  const SuperenalottoDraw({
    required this.date,
    required this.contestNumber,
    required this.numbers,
    required this.jolly,
    required this.superstar,
    required this.officiallyVerified,
  });

  final DateTime date;
  final int contestNumber;
  final List<int> numbers;
  final int jolly;
  final int superstar;
  final bool officiallyVerified;
}

class SuperenalottoImportReport {
  const SuperenalottoImportReport({
    required this.parsed,
    required this.inserted,
    required this.duplicates,
    required this.conflicts,
    required this.invalid,
  });

  final int parsed;
  final int inserted;
  final int duplicates;
  final int conflicts;
  final int invalid;

  SuperenalottoImportReport operator +(SuperenalottoImportReport other) {
    return SuperenalottoImportReport(
      parsed: parsed + other.parsed,
      inserted: inserted + other.inserted,
      duplicates: duplicates + other.duplicates,
      conflicts: conflicts + other.conflicts,
      invalid: invalid + other.invalid,
    );
  }
}

class SuperenalottoRepository {
  SuperenalottoRepository(this._db);

  final AppDatabase _db;

  Future<SuperenalottoImportReport> importParsed({
    required List<ParsedSuperenalottoDraw> draws,
    required String provenance,
  }) async {
    var inserted = 0, duplicates = 0, conflicts = 0, invalid = 0;
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      for (final draw in draws) {
        if (!draw.isValid) {
          invalid++;
          continue;
        }
        final hash = superenalottoHash(
          date: draw.date!,
          contestNumber: draw.contestNumber!,
          numbers: draw.numbers!,
          jolly: draw.jolly!,
          superstar: draw.superstar!,
        );
        final existing = await (_db.select(_db.superenalottoDraws)..where((row) => row.contestNumber.equals(draw.contestNumber!))).getSingleOrNull();
        if (existing != null) {
          if (existing.contentHash == hash) {
            duplicates++;
          } else {
            conflicts++;
          }
          continue;
        }
        await _db.into(_db.superenalottoDraws).insert(SuperenalottoDrawsCompanion.insert(
              drawDate: draw.date!,
              contestNumber: draw.contestNumber!,
              n1: draw.numbers![0],
              n2: draw.numbers![1],
              n3: draw.numbers![2],
              n4: draw.numbers![3],
              n5: draw.numbers![4],
              n6: draw.numbers![5],
              jolly: draw.jolly!,
              superstar: draw.superstar!,
              contentHash: hash,
              provenance: provenance,
              importedAt: now,
            ));
        inserted++;
      }
    });
    return SuperenalottoImportReport(parsed: draws.length, inserted: inserted, duplicates: duplicates, conflicts: conflicts, invalid: invalid);
  }

  Future<List<SuperenalottoDraw>> latest({int limit = 30}) async {
    final rows = await (_db.select(_db.superenalottoDraws)
          ..orderBy([(row) => OrderingTerm.desc(row.drawDate), (row) => OrderingTerm.desc(row.contestNumber)])
          ..limit(limit))
        .get();
    return [for (final row in rows) _map(row)];
  }

  Future<List<SuperenalottoDraw>> history() async {
    final rows = await (_db.select(_db.superenalottoDraws)
          ..orderBy([(row) => OrderingTerm.asc(row.drawDate), (row) => OrderingTerm.asc(row.contestNumber)]))
        .get();
    return [for (final row in rows) _map(row)];
  }

  Future<int> count() async {
    final row = await _db.customSelect('SELECT COUNT(*) AS c FROM superenalotto_draws', readsFrom: {_db.superenalottoDraws}).getSingle();
    return row.read<int>('c');
  }

  SuperenalottoDraw _map(SuperenalottoDrawRow row) {
    return SuperenalottoDraw(
      date: row.drawDate.toUtc(),
      contestNumber: row.contestNumber,
      numbers: [row.n1, row.n2, row.n3, row.n4, row.n5, row.n6],
      jolly: row.jolly,
      superstar: row.superstar,
      officiallyVerified: row.officiallyVerified,
    );
  }
}

final superenalottoRepositoryProvider = Provider<SuperenalottoRepository>((ref) {
  return SuperenalottoRepository(ref.watch(databaseProvider));
});

final superenalottoDrawsProvider = FutureProvider<List<SuperenalottoDraw>>((ref) {
  return ref.watch(superenalottoRepositoryProvider).latest();
});

final superenalottoHistoryProvider = FutureProvider<List<SuperenalottoDraw>>((ref) {
  return ref.watch(superenalottoRepositoryProvider).history();
});
