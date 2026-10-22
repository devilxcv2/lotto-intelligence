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
import '../../../core/settings/settings_controller.dart';
import '../../../core/settings/settings_repository.dart';
import '../../../core/updates/update_prompt.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';

class MoreHubPage extends StatelessWidget {
  const MoreHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Altro',
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Portafoglio virtuale'),
            subtitle: const Text('Saldo simulato, vincite nette, limiti di spesa'),
            onTap: () => context.push('/more/wallet'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Schedine ipotetiche'),
            subtitle: const Text('Giocate di studio del Lotto, confrontate con le ruote'),
            onTap: () => context.push('/more/tickets'),
          ),
          ListTile(
            leading: const Icon(Icons.stars_outlined),
            title: const Text('Studio SuperEnalotto'),
            subtitle: const Text('Ritardi, ultime combinazioni, suggerimenti e schedine'),
            onTap: () => context.push('/more/se-studio'),
          ),
          ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('Wiki'), onTap: () => context.push('/more/wiki')),
          ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Impostazioni'), onTap: () => context.push('/more/settings')),
          ListTile(leading: const Icon(Icons.health_and_safety_outlined), title: const Text('Diagnostica fonti'), onTap: () => context.push('/more/diagnostics')),
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
            SwitchListTile(
              title: const Text('Aggiornamento serale automatico'),
              subtitle: const Text(
                'Nei giorni di estrazione, dalle 20:15, scarica l\'archivio anche ad app chiusa e confronta le schedine ipotetiche. '
                'Riprova ogni 20 minuti fino alle 23 se l\'esito non è ancora pubblicato. Android può posticiparlo in risparmio energetico.',
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
              title: const Text('Notifica a nuova estrazione'),
              subtitle: const Text('Avviso locale, senza server, quando una nuova estrazione entra in archivio: tocca per vedere gli esiti delle schedine.'),
              value: value.notificationsEnabled,
              onChanged: !value.liveSyncEnabled
                  ? null
                  : (enabled) async {
                      await ref.read(settingsControllerProvider.notifier).setNotifications(enabled);
                      if (enabled) await NotificationService.instance.requestPermission();
                    },
            ),
            const _UpdateSection(),
            const Padding(padding: EdgeInsets.all(16), child: Text(scientificDisclaimer)),
          ],
        ),
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
  ('02_REQUIREMENTS.md', 'Requisiti'),
  ('03_ARCHITECTURE.md', 'Architettura'),
  ('04_TECH_STACK.md', 'Stack'),
  ('05_UI_UX_DESIGN.md', 'Interfaccia'),
  ('06_DATA_SOURCES.md', 'Fonti'),
  ('07_DATABASE_SCHEMA.md', 'Database'),
  ('08_DRAW_SYNC_ENGINE.md', 'Sincronizzazione'),
  ('09_STATISTICS_ENGINE.md', 'Statistiche'),
  ('10_PROBABILITY_THEORY.md', 'Probabilità'),
  ('11_SYSTEM_BUILDER.md', 'Sistemi'),
  ('12_AI_ARCHITECTURE.md', 'Architettura AI'),
  ('13_LOCAL_AI.md', 'AI locale'),
  ('14_REMOTE_AI.md', 'AI remota'),
  ('15_BACKTESTING.md', 'Backtesting'),
  ('16_MONTE_CARLO.md', 'Monte Carlo'),
  ('17_STRATEGY_EVALUATION.md', 'Valutazione'),
  ('18_ANDROID_BUILD.md', 'Build Android'),
  ('19_TESTING.md', 'Test'),
  ('20_SECURITY.md', 'Sicurezza'),
  ('21_TROUBLESHOOTING.md', 'Problemi'),
  ('22_ROADMAP.md', 'Roadmap'),
  ('23_CHANGELOG.md', 'Changelog'),
  ('24_DEVELOPMENT_GUIDE.md', 'Sviluppo'),
  ('25_AGENT_GUIDE.md', 'Guida agenti'),
  ('26_API_REFERENCE.md', 'Riferimento'),
  ('27_KNOWN_LIMITATIONS.md', 'Limiti'),
  ('28_PRIZES_AND_ALERTS.md', 'Premi e avvisi'),
];
