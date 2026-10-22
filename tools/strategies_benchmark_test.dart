// tools/strategies_benchmark_test.dart
//
// Confronto dei metodi classici sull'archivio reale di una ruota.
// Non fa parte della suite: richiede lo ZIP scaricato.
//
//   LOTTO_ZIP=/percorso/storico.zip flutter test tools/strategies_benchmark_test.dart

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/lotto/archive_parser.dart';
import 'package:lotto_intelligence/features/backtesting/domain/study_strategies.dart';
import 'package:lotto_intelligence/features/statistics/domain/statistics_engine.dart';

void main() {
  final zipPath = Platform.environment['LOTTO_ZIP'];

  test('confronto metodi su Bari', () {
    final archive = ZipDecoder().decodeBytes(File(zipPath!).readAsBytesSync());
    final file = archive.files.firstWhere((item) => item.name.toLowerCase().endsWith('.txt'));
    final parsed = parseOfficialArchiveText(String.fromCharCodes(file.content));
    final bari = [
      for (final draw in parsed.draws)
        if (draw.isValid && draw.wheelCode == 'BA') ArchivedDraw(date: draw.date!, numbers: draw.numbers!),
    ]..sort((a, b) => a.date.compareTo(b.date));

    for (final scored in [100, 1000]) {
      final clock = Stopwatch()..start();
      final rows = compareStrategies(draws: bari, seed: 42, scoreFromIndex: bari.length - scored, window: 100);
      // ignore: avoid_print
      print('\nUltimi $scored concorsi di Bari in ${clock.elapsedMilliseconds} ms, teoria ${rows.first.report.expectedMeanHits.toStringAsFixed(3)}');
      for (final row in rows) {
        // ignore: avoid_print
        print('${row.info.name.padRight(34)} media ${row.report.strategyMeanHits.toStringAsFixed(3)}  ≥1 centro ${row.report.drawsWithAtLeastOneHit}');
      }
    }
  }, skip: zipPath == null ? 'Imposta LOTTO_ZIP' : null, timeout: const Timeout(Duration(minutes: 5)));
}
