// lib/core/settings/app_settings.dart

import 'package:flutter/material.dart';

import '../../features/virtual_wallet/domain/auto_study.dart';
import '../lotto/prize_table.dart';

/// Come il portafoglio simulato tratta i tetti di spesa.
enum BudgetMode {
  /// Concorso, mese e capitale bloccano la registrazione.
  limits,

  /// Nessun controllo sul budget: utile se i limiti disturbano lo studio.
  off,

  /// Come [off], ma i campi restano visibili come «infinito» per le prove.
  unlimited,
}

extension BudgetModeLabel on BudgetMode {
  String get label => switch (this) {
        BudgetMode.limits => 'Limiti attivi',
        BudgetMode.off => 'Budget spento',
        BudgetMode.unlimited => 'Budget infinito',
      };

  String get hint => switch (this) {
        BudgetMode.limits => 'Concorso, mese e capitale bloccano le schedine oltre il tetto.',
        BudgetMode.off => 'Nessun blocco: puoi registrare senza guardare i tetti.',
        BudgetMode.unlimited => 'I tetti non bloccano nulla. Ideale per le prove.',
      };

  bool get enforcesLimits => this == BudgetMode.limits;
}

class AppSettings {
  const AppSettings({
    required this.onboardingCompleted,
    required this.themeMode,
    required this.selectedWheelCode,
    required this.liveSyncEnabled,
    required this.notificationsEnabled,
    required this.budgetMode,
    required this.autoStudyEnabled,
    required this.autoStudyMethod,
    required this.autoSeEnabled,
    required this.autoStakeEstrattoCents,
    required this.autoStakeAmboCents,
    required this.autoStakeTernoCents,
    required this.autoStakeQuaternaCents,
    required this.autoStakeCinquinaCents,
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

  /// Se i limiti simulati devono bloccare le schedine.
  final BudgetMode budgetMode;

  /// L'app crea da sola una schedina Lotto di studio per il prossimo concorso.
  final bool autoStudyEnabled;
  final AutoStudyMethod autoStudyMethod;

  /// Crea anche le tre strategie SuperEnalotto (Zoppe, ritardi, frequenti) per confrontare i trend.
  final bool autoSeEnabled;

  final int autoStakeEstrattoCents;
  final int autoStakeAmboCents;
  final int autoStakeTernoCents;
  final int autoStakeQuaternaCents;
  final int autoStakeCinquinaCents;

  final int virtualCapitalCents;
  final int contestBudgetCents;
  final int monthlyBudgetCents;
  final int unitCostCents;

  Map<LottoSorte, int> get autoStudyStakes => autoStudyStakesFrom(
        estrattoCents: autoStakeEstrattoCents,
        amboCents: autoStakeAmboCents,
        ternoCents: autoStakeTernoCents,
        quaternaCents: autoStakeQuaternaCents,
        cinquinaCents: autoStakeCinquinaCents,
      );

  int autoStakeFor(LottoSorte sorte) => switch (sorte) {
        LottoSorte.estratto => autoStakeEstrattoCents,
        LottoSorte.ambo => autoStakeAmboCents,
        LottoSorte.terno => autoStakeTernoCents,
        LottoSorte.quaterna => autoStakeQuaternaCents,
        LottoSorte.cinquina => autoStakeCinquinaCents,
      };

  static const initial = AppSettings(
    onboardingCompleted: false,
    themeMode: ThemeMode.light,
    selectedWheelCode: 'BA',
    liveSyncEnabled: true,
    notificationsEnabled: true,
    budgetMode: BudgetMode.limits,
    autoStudyEnabled: false,
    autoStudyMethod: AutoStudyMethod.zoppe,
    autoSeEnabled: false,
    autoStakeEstrattoCents: 0,
    autoStakeAmboCents: 100,
    autoStakeTernoCents: 100,
    autoStakeQuaternaCents: 0,
    autoStakeCinquinaCents: 0,
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
    BudgetMode? budgetMode,
    bool? autoStudyEnabled,
    AutoStudyMethod? autoStudyMethod,
    bool? autoSeEnabled,
    int? autoStakeEstrattoCents,
    int? autoStakeAmboCents,
    int? autoStakeTernoCents,
    int? autoStakeQuaternaCents,
    int? autoStakeCinquinaCents,
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
      budgetMode: budgetMode ?? this.budgetMode,
      autoStudyEnabled: autoStudyEnabled ?? this.autoStudyEnabled,
      autoStudyMethod: autoStudyMethod ?? this.autoStudyMethod,
      autoSeEnabled: autoSeEnabled ?? this.autoSeEnabled,
      autoStakeEstrattoCents: autoStakeEstrattoCents ?? this.autoStakeEstrattoCents,
      autoStakeAmboCents: autoStakeAmboCents ?? this.autoStakeAmboCents,
      autoStakeTernoCents: autoStakeTernoCents ?? this.autoStakeTernoCents,
      autoStakeQuaternaCents: autoStakeQuaternaCents ?? this.autoStakeQuaternaCents,
      autoStakeCinquinaCents: autoStakeCinquinaCents ?? this.autoStakeCinquinaCents,
      virtualCapitalCents: virtualCapitalCents ?? this.virtualCapitalCents,
      contestBudgetCents: contestBudgetCents ?? this.contestBudgetCents,
      monthlyBudgetCents: monthlyBudgetCents ?? this.monthlyBudgetCents,
      unitCostCents: unitCostCents ?? this.unitCostCents,
    );
  }

  AppSettings withAutoStake(LottoSorte sorte, int cents) {
    return switch (sorte) {
      LottoSorte.estratto => copyWith(autoStakeEstrattoCents: cents),
      LottoSorte.ambo => copyWith(autoStakeAmboCents: cents),
      LottoSorte.terno => copyWith(autoStakeTernoCents: cents),
      LottoSorte.quaterna => copyWith(autoStakeQuaternaCents: cents),
      LottoSorte.cinquina => copyWith(autoStakeCinquinaCents: cents),
    };
  }

  AppSettings withSuggestedAutoStakes() {
    return copyWith(
      autoStakeEstrattoCents: suggestedAutoStakes[LottoSorte.estratto]!,
      autoStakeAmboCents: suggestedAutoStakes[LottoSorte.ambo]!,
      autoStakeTernoCents: suggestedAutoStakes[LottoSorte.terno]!,
      autoStakeQuaternaCents: suggestedAutoStakes[LottoSorte.quaterna]!,
      autoStakeCinquinaCents: suggestedAutoStakes[LottoSorte.cinquina]!,
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
