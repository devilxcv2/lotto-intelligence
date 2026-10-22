// lib/core/settings/app_settings.dart

import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.onboardingCompleted,
    required this.themeMode,
    required this.selectedWheelCode,
    required this.liveSyncEnabled,
    required this.notificationsEnabled,
    required this.virtualCapitalCents,
    required this.contestBudgetCents,
    required this.monthlyBudgetCents,
    required this.unitCostCents,
  });

  final bool onboardingCompleted;
  final ThemeMode themeMode;
  final String selectedWheelCode;
  final bool liveSyncEnabled;

  /// Notifica locale quando arriva una nuova estrazione (richiede liveSync).
  final bool notificationsEnabled;
  final int virtualCapitalCents;
  final int contestBudgetCents;
  final int monthlyBudgetCents;
  final int unitCostCents;

  static const initial = AppSettings(
    onboardingCompleted: false,
    themeMode: ThemeMode.light,
    selectedWheelCode: 'BA',
    liveSyncEnabled: false,
    notificationsEnabled: true,
    virtualCapitalCents: 10000,
    contestBudgetCents: 500,
    monthlyBudgetCents: 2000,
    unitCostCents: 100,
  );

  AppSettings copyWith({
    bool? onboardingCompleted,
    ThemeMode? themeMode,
    String? selectedWheelCode,
    bool? liveSyncEnabled,
    bool? notificationsEnabled,
    int? virtualCapitalCents,
    int? contestBudgetCents,
    int? monthlyBudgetCents,
    int? unitCostCents,
  }) {
    return AppSettings(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      themeMode: themeMode ?? this.themeMode,
      selectedWheelCode: selectedWheelCode ?? this.selectedWheelCode,
      liveSyncEnabled: liveSyncEnabled ?? this.liveSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      virtualCapitalCents: virtualCapitalCents ?? this.virtualCapitalCents,
      contestBudgetCents: contestBudgetCents ?? this.contestBudgetCents,
      monthlyBudgetCents: monthlyBudgetCents ?? this.monthlyBudgetCents,
      unitCostCents: unitCostCents ?? this.unitCostCents,
    );
  }
}

String formatEuro(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final euros = abs ~/ 100;
  final remainder = (abs % 100).toString().padLeft(2, '0');
  return '$sign$euros,$remainder €';
}
