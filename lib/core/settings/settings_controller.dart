// lib/core/settings/settings_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'app_settings.dart';
import 'settings_repository.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> completeOnboarding() => _update((settings) => settings.copyWith(onboardingCompleted: true));

  Future<void> setThemeMode(ThemeMode mode) => _update((settings) => settings.copyWith(themeMode: mode));

  Future<void> selectWheel(String code) => _update((settings) => settings.copyWith(selectedWheelCode: code));

  Future<void> setLiveSync(bool enabled) => _update((settings) => settings.copyWith(liveSyncEnabled: enabled));

  Future<void> setNotifications(bool enabled) => _update((settings) => settings.copyWith(notificationsEnabled: enabled));

  Future<void> setBudgets({
    required int virtualCapitalCents,
    required int contestBudgetCents,
    required int monthlyBudgetCents,
    required int unitCostCents,
  }) {
    return _update((settings) => settings.copyWith(
          virtualCapitalCents: virtualCapitalCents,
          contestBudgetCents: contestBudgetCents,
          monthlyBudgetCents: monthlyBudgetCents,
          unitCostCents: unitCostCents,
        ));
  }

  Future<void> _update(AppSettings Function(AppSettings current) transform) async {
    final current = state.value ?? await future;
    final next = transform(current);
    await ref.read(settingsRepositoryProvider).save(next);
    state = AsyncData(next);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);
