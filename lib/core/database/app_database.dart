// lib/core/database/app_database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../lotto/archive_parser.dart';
import '../lotto/wheel_catalog.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Wheels,
  DataSources,
  Draws,
  DrawNumbers,
  SyncLogs,
  Strategies,
  StrategyParameters,
  AiModels,
  Predictions,
  PredictionNumbers,
  AiExecutionLogs,
  BacktestRuns,
  BacktestResults,
  VirtualTickets,
  TicketNumbers,
  TicketResults,
  SuperenalottoDraws,
  SuperenalottoTickets,
  SuperenalottoTicketResults,
  UserSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Il task serale può aprire il file mentre l'app è in primo piano:
          // meglio attendere il lock che fallire con «database is locked».
          await customStatement('PRAGMA busy_timeout = 8000');
        },
        onCreate: (migrator) async {
          await migrator.createAll();
          await _seed(this);
        },
        onUpgrade: (migrator, from, to) async {
          // Le migrazioni girano con i vincoli esterni spenti: alterTable
          // ricrea ticket_numbers copiando le righe.
          await customStatement('PRAGMA foreign_keys = OFF');
          if (from < 2) {
            await migrator.addColumn(virtualTickets, virtualTickets.stakeEstrattoCents);
            await migrator.addColumn(virtualTickets, virtualTickets.stakeAmboCents);
            await migrator.addColumn(virtualTickets, virtualTickets.stakeTernoCents);
            await migrator.addColumn(virtualTickets, virtualTickets.stakeQuaternaCents);
            await migrator.addColumn(virtualTickets, virtualTickets.stakeCinquinaCents);
            await migrator.addColumn(virtualTickets, virtualTickets.targetDrawDate);
            await migrator.addColumn(virtualTickets, virtualTickets.status);
            // Le schedine precedenti non hanno poste per sorte: restano «legacy».
            await customStatement("UPDATE virtual_tickets SET status = 'legacy'");
            // ignore: experimental_member_use
            await migrator.alterTable(TableMigration(ticketNumbers));
            await migrator.addColumn(ticketResults, ticketResults.detailJson);
          }
          if (from < 3) {
            await migrator.createTable(superenalottoDraws);
            await _seedSuperenalotto(this);
          }
          if (from < 4) {
            await migrator.createTable(superenalottoTickets);
            await migrator.createTable(superenalottoTicketResults);
          }
        },
      );

  static Future<AppDatabase> openDefault() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lotto_intelligence.sqlite'));
    // SQLite gira su un isolate dedicato: import e query lunghe non bloccano i frame.
    return AppDatabase(NativeDatabase.createInBackground(file));
  }
}

Future<void> _seed(AppDatabase db) async {
  for (final wheel in officialWheels) {
    await db.into(db.wheels).insert(WheelsCompanion.insert(
          code: wheel.code,
          name: wheel.name,
          sortOrder: wheel.sortOrder,
        ));
  }
  await db.into(db.dataSources).insert(DataSourcesCompanion.insert(
        code: 'lotto_italia_archive',
        name: 'Archivio ZIP collegato da Lotto Italia',
        kind: 'official_archive',
        pageUrl: const Value(OfficialArchiveLocations.pageUrl),
        archiveUrl: const Value(OfficialArchiveLocations.archiveUrl),
        status: 'unverified',
        notes: const Value(
          'File ZIP indicato nella pagina delle estrazioni di lotto-italia.it. '
          'L\'integrità strutturale viene controllata in importazione. '
          'Le righe non sono marcate come ufficialmente verificate finché non esiste un confronto con una seconda fonte.',
        ),
      ));
  await db.into(db.dataSources).insert(DataSourcesCompanion.insert(
        code: 'manual_import',
        name: 'Importazione manuale CSV/JSON',
        kind: 'manual',
        status: 'unverified',
        notes: const Value('File scelti dall\'utente. Non sono una fonte ufficiale.'),
      ));
  await _seedSuperenalotto(db);
}

Future<void> _seedSuperenalotto(AppDatabase db) async {
  final existing = await (db.select(db.dataSources)..where((row) => row.code.equals('superenalotto_archive'))).getSingleOrNull();
  if (existing != null) return;
  await db.into(db.dataSources).insert(DataSourcesCompanion.insert(
        code: 'superenalotto_archive',
        name: 'Archivio estrazioni SuperEnalotto',
        kind: 'official_archive',
        pageUrl: const Value('https://www.superenalotto.it/archivio-estrazioni'),
        status: 'unverified',
        notes: const Value(
          'Pagine dell\'archivio ufficiale superenalotto.it, verificate il 22 ottobre 2026. '
          'Il sito non pubblica uno ZIP unico: ogni pagina elenca le combinazioni del mese o gli ultimi concorsi. '
          'Le righe non sono marcate come ufficialmente verificate finché non esiste un secondo bollettino confrontato.',
        ),
      ));
}
