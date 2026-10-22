// lib/core/settings/settings_repository.dart

import 'package:flutter/material.dart';

import '../database/app_database.dart';
import 'app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const onboardingKey = 'onboarding_completed';
  static const themeKey = 'theme_mode';
  static const wheelKey = 'selected_wheel';
  static const liveSyncKey = 'live_sync_enabled';
  static const notificationsKey = 'notifications_enabled';
  static const capitalKey = 'virtual_capital_cents';
  static const contestBudgetKey = 'contest_budget_cents';
  static const monthlyBudgetKey = 'monthly_budget_cents';
  static const unitCostKey = 'unit_cost_cents';
  static const boardThemeKey = 'board_theme';
  static const updateManifestKey = 'update_manifest_url';
  static const updateDismissedKey = 'update_dismissed_code';

  Future<AppSettings> load() async {
    final rows = await _db.select(_db.userSettings).get();
    final values = {for (final row in rows) row.key: row.value};
    // Chi aveva il tema scuro di default della 0.2 passa una volta sola alla bacheca chiara.
    if (values[boardThemeKey] != '1') {
      await _write(boardThemeKey, '1');
      if (values[themeKey] == null || values[themeKey] == 'dark') {
        await _write(themeKey, 'light');
        values[themeKey] = 'light';
      }
    }
    return AppSettings(
      onboardingCompleted: values[onboardingKey] == 'true',
      themeMode: _theme(values[themeKey]),
      selectedWheelCode: values[wheelKey] ?? AppSettings.initial.selectedWheelCode,
      liveSyncEnabled: values[liveSyncKey] == 'true',
      notificationsEnabled: values[notificationsKey] != 'false',
      virtualCapitalCents: int.tryParse(values[capitalKey] ?? '') ?? AppSettings.initial.virtualCapitalCents,
      contestBudgetCents: int.tryParse(values[contestBudgetKey] ?? '') ?? AppSettings.initial.contestBudgetCents,
      monthlyBudgetCents: int.tryParse(values[monthlyBudgetKey] ?? '') ?? AppSettings.initial.monthlyBudgetCents,
      unitCostCents: int.tryParse(values[unitCostKey] ?? '') ?? AppSettings.initial.unitCostCents,
    );
  }

  Future<String> updateManifestUrl() async {
    final row = await (_db.select(_db.userSettings)..where((item) => item.key.equals(updateManifestKey))).getSingleOrNull();
    return row?.value.trim() ?? '';
  }

  Future<void> setUpdateManifestUrl(String url) => _write(updateManifestKey, url.trim());

  Future<int> dismissedUpdateCode() async {
    final row = await (_db.select(_db.userSettings)..where((item) => item.key.equals(updateDismissedKey))).getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<void> dismissUpdate(int versionCode) => _write(updateDismissedKey, '$versionCode');

  Future<void> save(AppSettings settings) async {
    await _write(onboardingKey, settings.onboardingCompleted ? 'true' : 'false');
    await _write(themeKey, settings.themeMode.name);
    await _write(wheelKey, settings.selectedWheelCode);
    await _write(liveSyncKey, settings.liveSyncEnabled ? 'true' : 'false');
    await _write(notificationsKey, settings.notificationsEnabled ? 'true' : 'false');
    await _write(capitalKey, '${settings.virtualCapitalCents}');
    await _write(contestBudgetKey, '${settings.contestBudgetCents}');
    await _write(monthlyBudgetKey, '${settings.monthlyBudgetCents}');
    await _write(unitCostKey, '${settings.unitCostCents}');
  }

  Future<void> _write(String key, String value) {
    return _db.into(_db.userSettings).insertOnConflictUpdate(UserSettingsCompanion.insert(key: key, value: value));
  }

  ThemeMode _theme(String? raw) {
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }
}
