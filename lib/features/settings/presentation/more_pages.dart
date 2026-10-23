// lib/features/settings/presentation/more_pages.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/lotto/draw_validation.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/scientific_notice.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/settings/settings_repository.dart';
import '../../../core/updates/update_prompt.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../../virtual_wallet/domain/auto_study.dart';

class MoreHubPage extends StatelessWidget {
  const MoreHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Altro',
      child: ListView(
        children: [
          HubSection(
            title: 'Account e studio',
            children: [
              HubTile(
                icon: Icons.settings_outlined,
                title: 'Impostazioni',
                subtitle: 'Tema, sync, budget, aggiornamenti',
                onTap: () => context.push('/more/settings'),
              ),
              HubTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Portafoglio virtuale',
                subtitle: 'Saldo simulato e limiti',
                onTap: () => context.push('/more/wallet'),
              ),
              HubTile(
                icon: Icons.insights_outlined,
                title: 'Statistiche',
                subtitle: 'Frequenze, ritardi, heatmap',
                onTap: () => context.push('/more/statistics'),
              ),
            ],
          ),
          HubSection(
            title: 'Altri giochi',
            subtitle: 'Le schedine Lotto stanno nella scheda Schedine.',
            children: [
              HubTile(
                icon: Icons.stars_outlined,
                title: 'Studio SuperEnalotto',
                subtitle: 'Ritardi, suggerimenti e categorie',
                onTap: () => context.push('/more/se-studio'),
              ),
            ],
          ),
          HubSection(
            title: 'Documentazione',
            children: [
              HubTile(
                icon: Icons.menu_book_outlined,
                title: 'Wiki',
                subtitle: 'Visione, fonti, probabilità, build',
                onTap: () => context.push('/more/wiki'),
              ),
              HubTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Diagnostica fonti',
                subtitle: 'Archivio, buchi e stato sync',
                onTap: () => context.push('/more/diagnostics'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return PageScaffold(
      title: 'Impostazioni',
      child: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (value) => ListView(
          children: [
            const ListTile(title: Text('Tema')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Chiaro')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Scuro')),
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                ],
                selected: {value.themeMode},
                onSelectionChanged: (selection) {
                  ref.read(settingsControllerProvider.notifier).setThemeMode(selection.first);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(drawEveningTimeline),
            ),
            SwitchListTile(
              title: const Text('Aggiornamento serale automatico'),
              subtitle: const Text(
                'Scarica da sola lo ZIP ufficiale dalle 20:15 (riprova fino alle 23) e confronta le schedine. '
                'I risultati non sono subito dopo le 19:30: di solito verso le 20:30. Android può posticipare il task in risparmio energetico.',
              ),
              value: value.liveSyncEnabled,
              onChanged: (enabled) async {
                await ref.read(settingsControllerProvider.notifier).setLiveSync(enabled);
                if (enabled && value.notificationsEnabled) {
                  await NotificationService.instance.requestPermission();
                }
              },
            ),
            SwitchListTile(
              title: const Text('Notifiche estrazione'),
              subtitle: const Text(
                'Alle 19:00 avvisa che sta per estrarre; alle 20:15 che sta scaricando lo ZIP; '
                'poi quando la nuova estrazione è in archivio e quando le schedine sono confrontate. Nessun server.',
              ),
              value: value.notificationsEnabled,
              onChanged: (enabled) async {
                await ref.read(settingsControllerProvider.notifier).setNotifications(enabled);
                if (enabled) await NotificationService.instance.requestPermission();
              },
            ),
            SwitchListTile(
              title: const Text('Schedine automatiche di studio'),
              subtitle: Text(
                value.autoStudyEnabled
                    ? 'L\'app crea da sola una schedina (${value.autoStudyMethod.label}) sulla ruota ${value.selectedWheelCode} '
                        'per ogni concorso, la valuta con lo ZIP e ti notifica. Puoi spegnerla quando vuoi.'
                    : 'Se la attivi, l\'app prepara una giocata ipotetica per il prossimo concorso, '
                        'controlla eventuali vincite simulate e te lo comunica con popup e notifica.',
              ),
              value: value.autoStudyEnabled,
              onChanged: (enabled) async {
                await ref.read(settingsControllerProvider.notifier).setAutoStudy(enabled: enabled);
                if (enabled && value.notificationsEnabled) {
                  await NotificationService.instance.requestPermission();
                }
              },
            ),
            if (value.autoStudyEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Metodo automatico', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<AutoStudyMethod>(
                      segments: const [
                        ButtonSegment(value: AutoStudyMethod.zoppe, label: Text('Zoppe')),
                        ButtonSegment(value: AutoStudyMethod.delays, label: Text('Ritardi')),
                        ButtonSegment(value: AutoStudyMethod.frequent, label: Text('Frequenti')),
                      ],
                      selected: {value.autoStudyMethod},
                      onSelectionChanged: (selection) {
                        ref.read(settingsControllerProvider.notifier).setAutoStudy(
                              enabled: true,
                              method: selection.first,
                            );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa la ruota selezionata in Home (${value.selectedWheelCode}). Posta: 1 € sull\'ambo (o il costo unità in portafoglio).',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const Divider(),
            const _BudgetSection(),
            const Divider(),
            const _UpdateSection(),
            const Padding(padding: EdgeInsets.all(16), child: Text(scientificDisclaimer)),
          ],
        ),
      ),
    );
  }
}

/// Budget simulato: limiti, spento o infinito per le prove.
class _BudgetSection extends ConsumerStatefulWidget {
  const _BudgetSection();

  @override
  ConsumerState<_BudgetSection> createState() => _BudgetSectionState();
}

class _BudgetSectionState extends ConsumerState<_BudgetSection> {
  final _capital = TextEditingController();
  final _contest = TextEditingController();
  final _month = TextEditingController();
  var _ready = false;

  @override
  void dispose() {
    _capital.dispose();
    _contest.dispose();
    _month.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    if (settings == null) return const SizedBox.shrink();
    if (!_ready) {
      _capital.text = (settings.virtualCapitalCents / 100).toStringAsFixed(2);
      _contest.text = (settings.contestBudgetCents / 100).toStringAsFixed(2);
      _month.text = (settings.monthlyBudgetCents / 100).toStringAsFixed(2);
      _ready = true;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget simulato', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Serve solo allo studio. Se i limiti bloccano le prove, spegnili o mettili infiniti.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SegmentedButton<BudgetMode>(
            segments: const [
              ButtonSegment(value: BudgetMode.limits, label: Text('Limiti'), icon: Icon(Icons.rule)),
              ButtonSegment(value: BudgetMode.off, label: Text('Spento'), icon: Icon(Icons.block)),
              ButtonSegment(value: BudgetMode.unlimited, label: Text('Infinito'), icon: Icon(Icons.all_inclusive)),
            ],
            selected: {settings.budgetMode},
            onSelectionChanged: (selection) {
              ref.read(settingsControllerProvider.notifier).setBudgetMode(selection.first);
            },
          ),
          const SizedBox(height: 8),
          Text(settings.budgetMode.hint, style: Theme.of(context).textTheme.bodySmall),
          if (settings.budgetMode == BudgetMode.limits) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _capital,
              decoration: const InputDecoration(labelText: 'Capitale iniziale, euro'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _contest,
              decoration: const InputDecoration(labelText: 'Budget per concorso, euro'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _month,
              decoration: const InputDecoration(labelText: 'Budget mensile, euro'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () async {
                  double cents(String raw) {
                    final value = double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
                    return value * 100;
                  }

                  await ref.read(settingsControllerProvider.notifier).setBudgets(
                        virtualCapitalCents: cents(_capital.text).round(),
                        contestBudgetCents: cents(_contest.text).round(),
                        monthlyBudgetCents: cents(_month.text).round(),
                        unitCostCents: settings.unitCostCents,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limiti salvati.')));
                  }
                },
                child: const Text('Salva limiti'),
              ),
            ),
          ] else if (settings.budgetMode == BudgetMode.unlimited)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Capitale · concorso · mese: ∞ (nessun blocco in registrazione).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpdateSection extends ConsumerStatefulWidget {
  const _UpdateSection();

  @override
  ConsumerState<_UpdateSection> createState() => _UpdateSectionState();
}

class _UpdateSectionState extends ConsumerState<_UpdateSection> {
  final _url = TextEditingController();
  var _ready = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final stored = await ref.read(settingsRepositoryProvider).updateManifestUrl();
      if (!mounted) return;
      _url.text = stored.isEmpty ? SettingsRepository.defaultUpdateManifestUrl : stored;
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aggiornamento dell\'app', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Quando pubblichi una versione nuova, aggiorna il file update.json con un versionCode più alto e l\'indirizzo dell\'APK. '
            'I telefoni che hanno già l\'app chiedono se scaricarla. «Più tardi» lascia l\'app installata e non ripropone quella stessa versione.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _url,
            enabled: _ready,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Indirizzo del file di versione',
              hintText: SettingsRepository.defaultUpdateManifestUrl,
              helperText: 'Se lo lasci vuoto, l\'app usa già quello su GitHub.',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: !_ready
                    ? null
                    : () async {
                        await ref.read(settingsRepositoryProvider).setUpdateManifestUrl(_url.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indirizzo salvato.')));
                        }
                      },
                child: const Text('Salva indirizzo'),
              ),
              FilledButton(
                onPressed: !_ready
                    ? null
                    : () async {
                        await ref.read(settingsRepositoryProvider).setUpdateManifestUrl(_url.text);
                        if (context.mounted) await offerAppUpdate(context, ref, ignoreDismiss: true);
                      },
                child: const Text('Controlla ora'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiagnosticsPage extends ConsumerWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_diagnosticsProvider);
    return PageScaffold(
      title: 'Diagnostica fonti',
      child: AsyncBody(
        value: data,
        onRetry: () => ref.invalidate(_diagnosticsProvider),
        data: (value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Freschezza: ${freshnessLabel(value.summary.freshness)}'),
            Text('Cinque numeri mancanti in qualche riga: ${value.broken}'),
            if (value.summary.lastError != null) Text(value.summary.lastError!),
            const SizedBox(height: 12),
            for (final source in value.sources)
              Text('${source.name}\n${source.status} · ${source.archiveUrl ?? 'nessun URL'}\n${source.notes ?? ''}\n'),
            const Text('Buchi dopo la prima comparsa di ciascuna ruota'),
            if (value.gaps.isEmpty) const Text('Nessun buco rilevato, oppure archivio vuoto.'),
            for (final gap in value.gaps.take(12))
              Text('${gap.wheelCode}: ${gap.missingDates.length} date, prima ${formatItalianDate(gap.missingDates.first)}'),
            const SizedBox(height: 12),
            const Text('L\'archivio ufficiale non contiene il numero di concorso, quindi il controllo sui concorsi mancanti non si applica.'),
          ],
        ),
      ),
    );
  }
}

class _Diagnostics {
  const _Diagnostics({required this.summary, required this.sources, required this.gaps, required this.broken});

  final ArchiveSummary summary;
  final List<DataSourceRow> sources;
  final List<WheelDateGap> gaps;
  final int broken;
}

final _diagnosticsProvider = FutureProvider<_Diagnostics>((ref) async {
  final repository = ref.watch(drawRepositoryProvider);
  return _Diagnostics(
    summary: await repository.summary(),
    sources: await repository.sources(),
    gaps: await repository.wheelGaps(),
    broken: await repository.countStructuralIssues(),
  );
});

class WikiPage extends StatelessWidget {
  const WikiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Wiki',
      child: ListView(
        children: [
          for (final page in wikiPages)
            ListTile(title: Text(page.$2), subtitle: Text(page.$1), onTap: () => context.push('/more/wiki/${page.$1}')),
        ],
      ),
    );
  }
}

class WikiArticlePage extends StatelessWidget {
  const WikiArticlePage({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final known = wikiPages.any((page) => page.$1 == name);
    return PageScaffold(
      title: name,
      child: known
          ? FutureBuilder<String>(
              future: rootBundle.loadString('wiki/$name'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const Center(child: Text('Pagina non disponibile offline.'));
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [SelectableText(snapshot.data ?? '')],
                );
              },
            )
          : const Center(child: Text('Voce sconosciuta.')),
    );
  }
}

const wikiPages = <(String, String)>[
  ('00_INDEX.md', 'Indice'),
  ('01_VISION.md', 'Visione'),
  ('06_DATA_SOURCES.md', 'Fonti'),
  ('10_PROBABILITY_THEORY.md', 'Probabilità'),
  ('18_ANDROID_BUILD.md', 'Build Android'),
  ('23_CHANGELOG.md', 'Changelog'),
  ('27_KNOWN_LIMITATIONS.md', 'Limiti'),
  ('28_PRIZES_AND_ALERTS.md', 'Premi e avvisi'),
];
