// test/database_test.dart

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/core/lotto/archive_parser.dart';
import 'package:lotto_intelligence/core/settings/app_settings.dart';
import 'package:lotto_intelligence/features/draws/data/draw_repository.dart';
import 'package:lotto_intelligence/features/virtual_wallet/data/wallet_repository.dart';

void main() {
  test('il database semina le ruote e non duplica le estrazioni', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DrawRepository(db);
    expect(await db.select(db.wheels).get(), hasLength(11));
    const text = '1939/01/07\tBA\t58\t22\t47\t49\t69\n1939/01/07\tFI\t27\t57\t81\t43\t61\n';
    final batch = parseOfficialArchiveText(text);
    final first = await repository.importParsed(
      draws: batch.draws,
      sourceCode: 'lotto_italia_archive',
      provenance: 'fixture',
    );
    final second = await repository.importParsed(
      draws: batch.draws,
      sourceCode: 'lotto_italia_archive',
      provenance: 'fixture',
    );
    expect(first.inserted, 2);
    expect(second.duplicates, 2);
    expect(second.inserted, 0);
    expect((await repository.loadWheel('BA')).single.numbers, [58, 22, 47, 49, 69]);
    expect(await repository.countStructuralIssues(), 0);
    final stored = await db.select(db.draws).get();
    expect(stored, hasLength(2));
    expect(stored.every((row) => !row.officiallyVerified), isTrue);

    final changed = parseOfficialArchiveText('1939/01/07\tBA\t1\t2\t3\t4\t5\n1939/01/14\tBA\t10\t20\t30\t40\t50\n');
    final third = await repository.importParsed(
      draws: changed.draws,
      sourceCode: 'manual_import',
      provenance: 'fixture-2',
    );
    expect(third.conflicts, 1);
    expect(third.inserted, 1);
    expect(third.samples.single, contains('non sovrascritta'));
    final bari = await repository.loadWheel('BA');
    expect(bari.map((draw) => draw.date).toList(), [DateTime.utc(1939, 1, 7), DateTime.utc(1939, 1, 14)]);
    expect(bari.map((draw) => draw.numbers).toList(), [
      [58, 22, 47, 49, 69],
      [10, 20, 30, 40, 50],
    ]);
    expect(await repository.countStructuralIssues(), 0);
  });

  test('un file con la stessa riga due volte conta un duplicato', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DrawRepository(db);
    final report = await repository.importParsed(
      draws: parseOfficialArchiveText('2020/01/02\tRM\t1\t2\t3\t4\t5\n2020/01/02\tRM\t1\t2\t3\t4\t5\n').draws,
      sourceCode: 'manual_import',
      provenance: 'fixture',
    );
    expect(report.inserted, 1);
    expect(report.duplicates, 1);
  });

  test('il portafoglio blocca la spesa oltre i limiti', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final wallet = WalletRepository(db);
    const settings = AppSettings(
      onboardingCompleted: true,
      themeMode: ThemeMode.dark,
      selectedWheelCode: 'BA',
      liveSyncEnabled: false,
      notificationsEnabled: true,
      budgetMode: BudgetMode.limits,
      virtualCapitalCents: 200,
      contestBudgetCents: 100,
      monthlyBudgetCents: 150,
      unitCostCents: 100,
    );
    expect(wallet.assess(settings: settings, spentThisMonthCents: 0, stakeCents: 100).allowed, isTrue);
    expect(wallet.assess(settings: settings, spentThisMonthCents: 100, stakeCents: 100).allowed, isFalse);
    expect(wallet.assess(settings: settings, spentThisMonthCents: 0, stakeCents: 150).message, contains('concorso'));

    final infinite = settings.copyWith(budgetMode: BudgetMode.unlimited);
    expect(wallet.assess(settings: infinite, spentThisMonthCents: 99999, stakeCents: 500).allowed, isTrue);
    final off = settings.copyWith(budgetMode: BudgetMode.off);
    expect(wallet.assess(settings: off, spentThisMonthCents: 99999, stakeCents: 500).allowed, isTrue);
  });
}
