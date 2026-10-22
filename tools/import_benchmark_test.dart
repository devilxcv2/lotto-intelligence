// tools/import_benchmark_test.dart
//
// Misura l'import dell'archivio reale e il blocco massimo del thread
// principale. Non fa parte della suite: richiede lo ZIP scaricato.
//
//   LOTTO_ZIP=/percorso/storico.zip flutter test tools/import_benchmark_test.dart

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/core/lotto/archive_parser.dart';
import 'package:lotto_intelligence/features/draws/data/draw_repository.dart';
import 'package:lotto_intelligence/features/draws/data/import_preparation.dart';
import 'package:lotto_intelligence/features/statistics/domain/statistics_engine.dart';

void main() {
  final zipPath = Platform.environment['LOTTO_ZIP'];

  test('import completo dell\'archivio reale', () async {
    final bytes = File(zipPath!).readAsBytesSync();
    final dir = Directory.systemTemp.createTempSync('lotto-bench');
    final db = AppDatabase(NativeDatabase.createInBackground(File('${dir.path}/bench.sqlite')));
    addTearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });
    final repository = DrawRepository(db);

    final ticker = Stopwatch()..start();
    var last = 0;
    var worstGap = 0;
    final timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = ticker.elapsedMilliseconds;
      if (now - last > worstGap) worstGap = now - last;
      last = now;
    });

    final gaps = <String, int>{};
    Future<void> phase(String name) async {
      // Lascia scattare il ticker, così il ritardo finisce nella fase giusta.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      gaps[name] = worstGap;
      worstGap = 0;
    }

    final clock = Stopwatch()..start();
    final prepared = await _prepare(bytes);
    final prepareMs = clock.elapsedMilliseconds;
    await phase('preparazione');
    clock.reset();
    final first = await repository.importPrepared(prepared: prepared, sourceCode: 'lotto_italia_archive', provenance: 'bench');
    final firstMs = clock.elapsedMilliseconds;
    await phase('primo import');
    clock.reset();
    final second = await repository.importPrepared(prepared: prepared, sourceCode: 'lotto_italia_archive', provenance: 'bench');
    final secondMs = clock.elapsedMilliseconds;
    await phase('secondo import');
    clock.reset();
    final bari = await repository.loadWheel('BA');
    final loadMs = clock.elapsedMilliseconds;
    await phase('lettura ruota');
    clock.reset();
    final stats = await summarizeInBackground(bari);
    final statsMs = clock.elapsedMilliseconds;
    await phase('statistiche');
    timer.cancel();
    worstGap = gaps.values.reduce((a, b) => a > b ? a : b);
    // ignore: avoid_print
    print('blocchi per fase: $gaps');

    // ignore: avoid_print
    print('righe ${prepared.parsed}, valide ${prepared.rows.length}\n'
        'preparazione su isolate $prepareMs ms\n'
        'primo import ${first.inserted} nuove in $firstMs ms\n'
        'secondo import ${second.duplicates} duplicati in $secondMs ms\n'
        'Bari ${bari.length} estrazioni lette in $loadMs ms, statistiche in $statsMs ms\n'
        'blocco massimo del thread principale: $worstGap ms');

    expect(first.inserted, prepared.rows.length);
    expect(second.inserted, 0);
    expect(second.duplicates, prepared.rows.length);
    expect(await repository.countStructuralIssues(), 0);
    expect(stats.drawCount, bari.length);
  }, skip: zipPath == null ? 'Imposta LOTTO_ZIP' : null, timeout: const Timeout(Duration(minutes: 5)));
}

Future<PreparedImport> _prepare(List<int> bytes) {
  return Isolate.run(() {
    final archive = ZipDecoder().decodeBytes(bytes);
    final file = archive.files.firstWhere((item) => item.name.toLowerCase().endsWith('.txt'));
    return prepareImport(parseOfficialArchiveText(String.fromCharCodes(file.content)).draws);
  });
}
