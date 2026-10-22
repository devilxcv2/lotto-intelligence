// lib/features/systems/data/strategy_repository.dart

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

class SavedStrategy {
  const SavedStrategy({
    required this.id,
    required this.name,
    required this.kind,
    required this.wheelCode,
    required this.createdAt,
    required this.notes,
    required this.parameters,
  });

  final int id;
  final String name;
  final String kind;
  final String wheelCode;
  final DateTime createdAt;
  final String? notes;
  final Map<String, String> parameters;
}

class StrategyRepository {
  StrategyRepository(this._db);

  final AppDatabase _db;

  Future<int> save({
    required String name,
    required String kind,
    required String wheelCode,
    required String notes,
    required Map<String, String> parameters,
  }) {
    final now = DateTime.now().toUtc();
    return _db.transaction(() async {
      final id = await _db.into(_db.strategies).insert(StrategiesCompanion.insert(
            name: name,
            kind: kind,
            wheelCode: wheelCode,
            createdAt: now,
            updatedAt: now,
            notes: Value(notes),
          ));
      await _db.batch((batch) {
        batch.insertAll(_db.strategyParameters, [
          for (final entry in parameters.entries)
            StrategyParametersCompanion.insert(
              strategyId: id,
              paramKey: entry.key,
              paramValue: entry.value,
            ),
        ]);
      });
      return id;
    });
  }

  Future<List<SavedStrategy>> list() async {
    final rows = await (_db.select(_db.strategies)..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();
    final parameters = await _db.select(_db.strategyParameters).get();
    return [
      for (final row in rows)
        SavedStrategy(
          id: row.id,
          name: row.name,
          kind: row.kind,
          wheelCode: row.wheelCode,
          createdAt: row.createdAt,
          notes: row.notes,
          parameters: {
            for (final parameter in parameters.where((item) => item.strategyId == row.id)) parameter.paramKey: parameter.paramValue,
          },
        ),
    ];
  }

  Future<int> count() async {
    final row = await _db.customSelect('SELECT COUNT(*) AS c FROM strategies', readsFrom: {_db.strategies}).getSingle();
    return row.read<int>('c');
  }
}

final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  return StrategyRepository(ref.watch(databaseProvider));
});

final strategiesProvider = FutureProvider<List<SavedStrategy>>((ref) {
  return ref.watch(strategyRepositoryProvider).list();
});
