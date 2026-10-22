// lib/core/database/tables.dart

import 'package:drift/drift.dart';

@DataClassName('WheelRow')
class Wheels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 2, max: 8).unique()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
}

@DataClassName('DataSourceRow')
class DataSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get pageUrl => text().nullable()();
  TextColumn get archiveUrl => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get httpLastModified => text().nullable()();
  TextColumn get notes => text().nullable()();
}

@TableIndex(name: 'idx_draws_wheel_date', columns: {#wheelId, #drawDate})
@TableIndex(name: 'idx_draws_date', columns: {#drawDate})
@DataClassName('DrawRow')
class Draws extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get drawDate => dateTime()();
  IntColumn get contestNumber => integer().nullable()();
  IntColumn get wheelId => integer().references(Wheels, #id)();
  IntColumn get sourceId => integer().references(DataSources, #id)();
  BoolColumn get structuralIntegrityOk => boolean().withDefault(const Constant(true))();

  /// Resta falso finché una seconda fonte indipendente non conferma la riga.
  BoolColumn get officiallyVerified => boolean().withDefault(const Constant(false))();
  TextColumn get provenance => text()();
  TextColumn get contentHash => text()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {drawDate, wheelId},
      ];
}

@TableIndex(name: 'idx_draw_numbers_draw', columns: {#drawId})
@DataClassName('DrawNumberRow')
class DrawNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get drawId => integer().references(Draws, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get number => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {drawId, position},
        {drawId, number},
      ];

  @override
  List<String> get customConstraints => [
        'CHECK (position BETWEEN 1 AND 5)',
        'CHECK (number BETWEEN 1 AND 90)',
      ];
}

@DataClassName('SyncLogRow')
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer().references(DataSources, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get status => text()();
  IntColumn get parsedCount => integer().withDefault(const Constant(0))();
  IntColumn get insertedCount => integer().withDefault(const Constant(0))();
  IntColumn get duplicateCount => integer().withDefault(const Constant(0))();
  IntColumn get conflictCount => integer().withDefault(const Constant(0))();
  IntColumn get invalidCount => integer().withDefault(const Constant(0))();
  TextColumn get message => text().nullable()();
}

@DataClassName('StrategyRow')
class Strategies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get wheelCode => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('StrategyParameterRow')
class StrategyParameters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get strategyId => integer().references(Strategies, #id, onDelete: KeyAction.cascade)();
  TextColumn get paramKey => text()();
  TextColumn get paramValue => text()();
}

@DataClassName('AiModelRow')
class AiModels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text()();
  TextColumn get displayName => text()();
  TextColumn get endpoint => text()();
  TextColumn get modelName => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get timeoutSeconds => integer().withDefault(const Constant(30))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('PredictionRow')
class Predictions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get strategyId => integer().nullable().references(Strategies, #id)();
  IntColumn get modelId => integer().nullable().references(AiModels, #id)();
  TextColumn get wheelCode => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get engineId => text()();
  TextColumn get engineVersion => text()();
  TextColumn get method => text()();
  TextColumn get rationale => text()();
  TextColumn get limitations => text()();
  TextColumn get datasetNote => text()();
  TextColumn get configJson => text()();
}

@TableIndex(name: 'idx_prediction_numbers', columns: {#predictionId})
@DataClassName('PredictionNumberRow')
class PredictionNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predictionId => integer().references(Predictions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get number => integer()();

  @override
  List<String> get customConstraints => [
        'CHECK (position BETWEEN 1 AND 5)',
        'CHECK (number BETWEEN 1 AND 90)',
      ];
}

@DataClassName('AiExecutionLogRow')
class AiExecutionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get modelId => integer().nullable().references(AiModels, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  BoolColumn get success => boolean()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get requestSummary => text()();
}

@DataClassName('BacktestRunRow')
class BacktestRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get strategyId => integer().nullable().references(Strategies, #id)();
  TextColumn get label => text()();
  TextColumn get wheelCode => text()();
  IntColumn get seed => integer()();
  DateTimeColumn get fromDate => dateTime().nullable()();
  DateTimeColumn get toDate => dateTime().nullable()();
  IntColumn get warmupDraws => integer().withDefault(const Constant(0))();
  IntColumn get scoredDraws => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get summaryJson => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@TableIndex(name: 'idx_backtest_results_run', columns: {#runId})
@DataClassName('BacktestResultRow')
class BacktestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId => integer().references(BacktestRuns, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get drawDate => dateTime()();
  IntColumn get hits => integer()();
  IntColumn get baselineHits => integer()();
  TextColumn get proposedNumbers => text()();
}

/// Schedina ipotetica. [wheelCode] è una ruota oppure `TUTTE`.
/// [stakeCents] è la posta totale; le colonne per sorte la scompongono
/// (schema 2). Le schedine create con lo schema 1 hanno sorti a zero e
/// stato `legacy`: per loro si contano solo i centri.
@DataClassName('VirtualTicketRow')
class VirtualTickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get strategyId => integer().nullable().references(Strategies, #id)();
  TextColumn get wheelCode => text()();
  IntColumn get stakeCents => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get stakeEstrattoCents => integer().withDefault(const Constant(0))();
  IntColumn get stakeAmboCents => integer().withDefault(const Constant(0))();
  IntColumn get stakeTernoCents => integer().withDefault(const Constant(0))();
  IntColumn get stakeQuaternaCents => integer().withDefault(const Constant(0))();
  IntColumn get stakeCinquinaCents => integer().withDefault(const Constant(0))();

  /// Giorno di estrazione a cui la schedina partecipa (mezzanotte UTC).
  DateTimeColumn get targetDrawDate => dateTime().nullable()();

  /// `open`, `evaluated`, `legacy`.
  TextColumn get status => text().withDefault(const Constant('open'))();
}

@TableIndex(name: 'idx_ticket_numbers', columns: {#ticketId})
@DataClassName('TicketNumberRow')
class TicketNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(VirtualTickets, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get number => integer()();

  @override
  List<String> get customConstraints => [
        'CHECK (position BETWEEN 1 AND 10)',
        'CHECK (number BETWEEN 1 AND 90)',
      ];
}

@DataClassName('TicketResultRow')
class TicketResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(VirtualTickets, #id, onDelete: KeyAction.cascade)();
  IntColumn get drawId => integer().nullable().references(Draws, #id)();
  DateTimeColumn get evaluatedAt => dateTime()();
  IntColumn get hits => integer().nullable()();
  IntColumn get grossCents => integer().nullable()();
  IntColumn get netCents => integer().nullable()();
  TextColumn get outcomeNote => text()();

  /// JSON con centri per ruota e lordo per sorte (schema 2).
  TextColumn get detailJson => text().nullable()();
}

/// Combinazione del SuperEnalotto pubblicata sull'archivio ufficiale.
/// Sei numeri, Jolly e SuperStar. `officially_verified` resta falso:
/// la pagina è una fonte sola, non un bollettino confrontato con un'altra.
@DataClassName('SuperenalottoDrawRow')
class SuperenalottoDraws extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get drawDate => dateTime()();
  IntColumn get contestNumber => integer().unique()();
  IntColumn get n1 => integer()();
  IntColumn get n2 => integer()();
  IntColumn get n3 => integer()();
  IntColumn get n4 => integer()();
  IntColumn get n5 => integer()();
  IntColumn get n6 => integer()();
  IntColumn get jolly => integer()();
  IntColumn get superstar => integer()();
  TextColumn get contentHash => text()();
  BoolColumn get officiallyVerified => boolean().withDefault(const Constant(false))();
  TextColumn get provenance => text()();
  DateTimeColumn get importedAt => dateTime()();
}

/// Schedina ipotetica del SuperEnalotto: sei numeri e, se presente, la SuperStar.
/// I premi sono a montepremi: qui non si salvano importi.
@DataClassName('SuperenalottoTicketRow')
class SuperenalottoTickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get n1 => integer()();
  IntColumn get n2 => integer()();
  IntColumn get n3 => integer()();
  IntColumn get n4 => integer()();
  IntColumn get n5 => integer()();
  IntColumn get n6 => integer()();
  IntColumn get superstar => integer().nullable()();
  DateTimeColumn get targetDrawDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get origin => text().withDefault(const Constant('manuale'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('SuperenalottoTicketResultRow')
class SuperenalottoTicketResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(SuperenalottoTickets, #id, onDelete: KeyAction.cascade)();
  IntColumn get contestNumber => integer()();
  DateTimeColumn get drawDate => dateTime()();
  IntColumn get hits => integer()();
  BoolColumn get jollyMatched => boolean()();
  BoolColumn get superstarMatched => boolean()();
  TextColumn get category => text()();
  DateTimeColumn get evaluatedAt => dateTime()();
}

@DataClassName('UserSettingRow')
class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
