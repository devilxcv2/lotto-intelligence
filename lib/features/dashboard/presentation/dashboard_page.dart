// lib/features/dashboard/presentation/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/freshness.dart';
import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../features/draws/data/archive_sync.dart';
import '../../../features/draws/data/draw_repository.dart';
import '../../../features/statistics/data/statistics_providers.dart';
import '../../../features/statistics/domain/statistics_engine.dart';
import '../../../features/superenalotto/presentation/se_chrome.dart';
import '../../../features/virtual_wallet/data/wallet_repository.dart';
import '../../../shared/widgets/common_widgets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(archiveSummaryProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    final sync = ref.watch(archiveSyncProvider);
    final wallet = ref.watch(walletSummaryProvider).value;
    final wheel = settings?.selectedWheelCode ?? 'BA';
    final ready = summary.maybeWhen(
      data: (data) => data.latestDate != null,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
              children: [
                _HomeHero(
                  settings: settings,
                  wallet: wallet,
                  sync: sync,
                  summary: summary.value,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    ready ? 'Scegli dove andare' : 'L\'archivio si aggiorna da solo. Poi si sbloccano i pannelli.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.15,
                    children: [
                      _ColorTile(
                        title: 'Ticket',
                        subtitle: ready ? 'Crea e storico' : 'Serve l\'archivio',
                        icon: Icons.confirmation_number_rounded,
                        colors: const [Color(0xFF1B4E8C), Color(0xFF2F6EAD)],
                        locked: !ready,
                        onTap: () => context.go('/tickets'),
                      ),
                      _ColorTile(
                        title: 'Soldi',
                        subtitle: wallet == null
                            ? 'Credito e budget'
                            : formatEuro(
                                (settings?.virtualCapitalCents ?? 0) +
                                    wallet.balanceCents +
                                    wallet.seBalanceCents -
                                    wallet.totalOpenStakeCents,
                              ),
                        icon: Icons.account_balance_wallet_rounded,
                        colors: const [Color(0xFFC8962E), Color(0xFFF0A01A)],
                        locked: false,
                        onTap: () => context.go('/budget'),
                      ),
                      _ColorTile(
                        title: 'Extra',
                        subtitle: ready
                            ? 'Estrazioni e ruote'
                            : 'Archivio in aggiornamento',
                        icon: Icons.bolt_rounded,
                        colors: const [Color(0xFFD47812), Color(0xFFE8A03A)],
                        locked: !ready,
                        onTap: () => context.go('/draws'),
                      ),
                      _ColorTile(
                        title: 'Lab',
                        subtitle: ready ? 'Sistemi e Zoppe' : 'Dopo l\'archivio',
                        icon: Icons.auto_awesome_rounded,
                        colors: const [Color(0xFF5B3A8C), Color(0xFF7A5AF0)],
                        locked: !ready,
                        onTap: () => context.go('/lab'),
                      ),
                      _ColorTile(
                        title: 'SuperEnalotto',
                        subtitle: ready ? 'Studio e catalogo' : 'Dopo l\'archivio',
                        icon: Icons.stars_rounded,
                        colors: const [SeColors.forestDeep, SeColors.mint],
                        locked: !ready,
                        onTap: () => context.push('/more/se'),
                      ),
                      _ColorTile(
                        title: 'Più',
                        subtitle: 'Impostazioni e info',
                        icon: Icons.grid_view_rounded,
                        colors: const [Color(0xFF334155), Color(0xFF64748B)],
                        locked: false,
                        onTap: () => context.go('/more'),
                      ),
                    ],
                  ),
                ),
                if (ready) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _LatestStrip(wheel: wheel),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Text(
                    'L\'archivio ufficiale si scarica in automatico. Per forzare o importare un file: Extra → icona aggiorna / Archivio.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.55),
                          height: 1.35,
                        ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/draws/archive'),
                    child: const Text('Apri gestione archivio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.settings,
    required this.wallet,
    required this.sync,
    required this.summary,
  });

  final AppSettings? settings;
  final WalletSummary? wallet;
  final ArchiveSyncState sync;
  final ArchiveSummary? summary;

  @override
  Widget build(BuildContext context) {
    final next = nextOpenDrawDate(DateTime.now());
    final freshness = summary?.freshness;
    final statusText = sync.running
        ? (sync.message ?? 'Aggiorno l\'archivio…')
        : switch (freshness) {
            SourceFreshness.updated => 'Archivio aggiornato',
            SourceFreshness.delayed => 'Cerco l\'estrazione più recente…',
            SourceFreshness.unavailable => 'Archivio non ancora pronto',
            SourceFreshness.unverified => 'Verifico l\'archivio…',
            null => sync.error != null ? 'Riprovo in automatico' : 'Preparazione archivio…',
          };
    final statusColor = sync.running
        ? AppColors.ballGold
        : switch (freshness) {
            SourceFreshness.updated => const Color(0xFF7DFFB3),
            SourceFreshness.delayed => AppColors.ballGold,
            _ => Colors.white70,
          };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF122B4A), Color(0xFF1B4E8C), Color(0xFF2F6EAD)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lotto Intelligence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prossimo concorso ${formatItalianDate(next)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.88)),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                if (sync.running)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ballGold),
                  )
                else
                  Icon(Icons.cloud_done_outlined, size: 18, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                if (summary?.latestDate != null)
                  Text(
                    formatItalianDate(summary!.latestDate!),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
              ],
            ),
          ),
          if (sync.running) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: sync.progress == 0 ? null : sync.progress,
                minHeight: 3,
                backgroundColor: Colors.white24,
                color: AppColors.ballGold,
              ),
            ),
          ],
          if (wallet case final w?) ...[
            const SizedBox(height: 12),
            Text(
              '${w.openCount + w.seOpenCount} schedine in attesa · saldo Lotto '
              '${w.balanceCents >= 0 ? '+' : ''}${formatEuro(w.balanceCents)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.locked,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: locked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Si sblocca quando l\'archivio è pronto (aggiornamento automatico).')),
                );
              }
            : onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: locked
                  ? [colors.first.withValues(alpha: 0.45), colors.last.withValues(alpha: 0.35)]
                  : colors,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white.withValues(alpha: locked ? 0.55 : 1), size: 26),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: locked ? 0.7 : 1),
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: locked ? 0.55 : 0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (locked)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.lock_outline, color: Colors.white70, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestStrip extends ConsumerWidget {
  const _LatestStrip({required this.wheel});

  final String wheel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draws = ref.watch(wheelDrawsProvider(wheel));
    return draws.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final latest = items.last;
        final stats = ref.watch(wheelStatisticsProvider((wheel: wheel, window: 30)));
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${wheelByCode(wheel)?.name ?? wheel} · ${formatItalianDate(latest.date)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/draws'),
                    child: const Text('Tutte'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NumberBalls(numbers: latest.numbers),
              const SizedBox(height: 8),
              switch (stats) {
                AsyncData(:final value?) => Text(
                    _topLine(value),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        );
      },
    );
  }

  String _topLine(WheelStatistics stats) {
    final delays = [...stats.numbers]..sort((a, b) => b.currentDelay.compareTo(a.currentDelay));
    return 'Ritardi più lunghi: ${delays.take(3).map((n) => '${n.number} (${n.currentDelay})').join(', ')}.';
  }
}
