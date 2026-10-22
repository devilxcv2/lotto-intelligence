// lib/features/backtesting/data/backtest_repository.dart

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../domain/backtest_engine.dart';

class StoredBacktest {
  const StoredBacktest({required this.id, required this.label, required this.wheelCode, required this.createdAt, required this.summaryJson});

  final int id;
  final String label;
  final String wheelCode;
  final DateTime createdAt;
  final String summaryJson;
}

class BacktestRepository {
  BacktestRepository(this._db);

  final AppDatabase _db;

  Future<int> save({
    required String label,
    required String wheelCode,
    required int seed,
    required BacktestReport report,
  }) {
    final now = DateTime.now().toUtc();
    return _db.transaction(() async {
      final id = await _db.into(_db.backtestRuns).insert(BacktestRunsCompanion.insert(
            label: label,
            wheelCode: wheelCode,
            seed: seed,
            fromDate: Value(report.rows.isEmpty ? null : report.rows.first.date),
            toDate: Value(report.rows.isEmpty ? null : report.rows.last.date),
            warmupDraws: Value(report.warmupDraws),
            scoredDraws: Value(report.scoredDraws),
            status: 'completed',
            summaryJson: jsonEncode(report.toJson()),
            createdAt: now,
          ));
      const chunk = 500;
      for (var offset = 0; offset < report.rows.length; offset += chunk) {
        final slice = report.rows.skip(offset).take(chunk);
        await _db.batch((batch) {
          batch.insertAll(_db.backtestResults, [
            for (final row in slice)
              BacktestResultsCompanion.insert(
                runId: id,
                drawDate: row.date,
                hits: row.hits,
                baselineHits: row.baselineHits,
                proposedNumbers: row.proposed.join(','),
              ),
          ]);
        });
      }
      return id;
    });
  }

  Future<List<StoredBacktest>> list() async {
    final rows = await (_db.select(_db.backtestRuns)..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();
    return [
      for (final row in rows)
        StoredBacktest(
          id: row.id,
          label: row.label,
          wheelCode: row.wheelCode,
          createdAt: row.createdAt,
          summaryJson: row.summaryJson,
        ),
    ];
  }

  Future<StoredBacktest?> find(int id) async {
    final row = await (_db.select(_db.backtestRuns)..where((item) => item.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return StoredBacktest(
      id: row.id,
      label: row.label,
      wheelCode: row.wheelCode,
      createdAt: row.createdAt,
      summaryJson: row.summaryJson,
    );
  }

  Future<int> count() async {
    final row = await _db.customSelect('SELECT COUNT(*) AS c FROM backtest_runs', readsFrom: {_db.backtestRuns}).getSingle();
    return row.read<int>('c');
  }
}

String reportCsv(BacktestReport report) {
  final buffer = StringBuffer('data,centri,centri_baseline,numeri\n');
  for (final row in report.rows) {
    buffer.writeln('${formatIsoDate(row.date)},${row.hits},${row.baselineHits},${row.proposed.join(' ')}');
  }
  return buffer.toString();
}

Future<Uint8List> reportPdf({
  required String title,
  required String body,
}) async {
  final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
  final font = pw.Font.ttf(fontData);
  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: font),
      build: (context) => [
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.Text(body, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    ),
  );
  return document.save();
}

final backtestRepositoryProvider = Provider<BacktestRepository>((ref) {
  return BacktestRepository(ref.watch(databaseProvider));
});

final backtestsProvider = FutureProvider<List<StoredBacktest>>((ref) {
  return ref.watch(backtestRepositoryProvider).list();
});
