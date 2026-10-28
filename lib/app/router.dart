// lib/app/router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_lab/presentation/ai_pages.dart';
import '../features/backtesting/presentation/backtest_pages.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/dashboard/presentation/startup_pages.dart';
import '../features/draws/presentation/draws_pages.dart';
import '../features/settings/presentation/more_pages.dart';
import '../features/settings/presentation/share_app_page.dart';
import '../features/superenalotto/presentation/se_bacheca_page.dart';
import '../features/superenalotto/presentation/se_hub_page.dart';
import '../features/superenalotto/presentation/se_studio_page.dart';
import '../features/superenalotto/presentation/se_tickets_page.dart';
import '../features/statistics/presentation/statistics_pages.dart';
import '../features/discovery/presentation/discovery_page.dart';
import '../features/systems/presentation/sisal_board_page.dart';
import '../features/systems/presentation/system_pages.dart';
import '../features/systems/presentation/zoppe_page.dart';
import '../features/virtual_wallet/presentation/budget_board_page.dart';
import '../features/virtual_wallet/presentation/wallet_pages.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      // Vecchi collegamenti → nuove schede.
      GoRoute(path: '/more/tickets', redirect: (context, state) => state.uri.toString().replaceFirst('/more/tickets', '/tickets')),
      GoRoute(path: '/statistics', redirect: (context, state) {
        final rest = state.uri.toString().substring('/statistics'.length);
        return '/more/statistics$rest';
      }),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/draws',
              builder: (context, state) => const DrawsPage(),
              routes: [
                GoRoute(path: 'archive', builder: (context, state) => const ArchivePage()),
                GoRoute(
                  path: 'day/:iso',
                  builder: (context, state) => DrawDayPage(isoDate: state.pathParameters['iso']!),
                ),
                GoRoute(
                  path: 'wheel/:code',
                  builder: (context, state) => WheelDetailPage(code: state.pathParameters['code']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const TicketsPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => NewTicketPage(
                    initialNumbers: [
                      for (final part in (state.uri.queryParameters['numbers'] ?? '').split(',')) ?int.tryParse(part.trim()),
                    ],
                    initialWheel: state.uri.queryParameters['wheel'],
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => TicketDetailPage(id: int.parse(state.pathParameters['id']!)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/budget', builder: (context, state) => const BudgetBoardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lab',
              builder: (context, state) => const LabHubPage(),
              routes: [
                GoRoute(path: 'systems', builder: (context, state) => const SystemBuilderPage()),
                GoRoute(
                  path: 'sisal',
                  builder: (context, state) => SisalBoardPage(
                    forSuperEnalotto: state.uri.queryParameters['game'] != 'lotto',
                  ),
                ),
                GoRoute(path: 'strategies', builder: (context, state) => const StrategiesPage()),
                GoRoute(path: 'ai', builder: (context, state) => const AiLabPage()),
                GoRoute(path: 'models', builder: (context, state) => const AiModelsPage()),
                GoRoute(path: 'backtest', builder: (context, state) => const BacktestPage()),
                GoRoute(path: 'discovery', builder: (context, state) => const DiscoveryPage()),
                GoRoute(
                  path: 'zoppe',
                  builder: (context, state) {
                    final raw = state.uri.queryParameters['mask'] ?? '';
                    final mask = <int>{
                      for (final part in raw.split(','))
                        ?int.tryParse(part),
                    }.where((number) => number >= 1 && number <= 90).toSet();
                    return ZoppePage(initialMask: mask);
                  },
                ),
                GoRoute(
                  path: 'reports',
                  builder: (context, state) => const ReportsPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => ReportDetailPage(id: int.parse(state.pathParameters['id']!)),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreHubPage(),
              routes: [
                GoRoute(path: 'wallet', builder: (context, state) => const WalletPage()),
                GoRoute(
                  path: 'se',
                  builder: (context, state) => const SeHubPage(),
                  routes: [
                    GoRoute(
                      path: 'studio',
                      builder: (context, state) => SeStudioPage(
                        initialNumbers: [
                          for (final part in (state.uri.queryParameters['numbers'] ?? '').split(',')) ?int.tryParse(part.trim()),
                        ],
                      ),
                    ),
                    GoRoute(path: 'tickets', builder: (context, state) => const SeTicketsPage()),
                    GoRoute(path: 'bacheca', builder: (context, state) => const SeBachecaPage()),
                  ],
                ),
                // Vecchio percorso → studio dentro l'area SuperEnalotto.
                GoRoute(
                  path: 'se-studio',
                  redirect: (context, state) {
                    final numbers = state.uri.queryParameters['numbers'];
                    if (numbers == null || numbers.isEmpty) return '/more/se/studio';
                    return '/more/se/studio?numbers=$numbers';
                  },
                ),
                GoRoute(
                  path: 'statistics',
                  builder: (context, state) => const StatisticsPage(),
                  routes: [
                    GoRoute(path: 'heatmap', builder: (context, state) => const HeatmapPage()),
                    GoRoute(path: 'advanced', builder: (context, state) => const AdvancedStatisticsPage()),
                    GoRoute(path: 'pairs', builder: (context, state) => const PairsPage()),
                  ],
                ),
                GoRoute(
                  path: 'wiki',
                  builder: (context, state) => const WikiPage(),
                  routes: [
                    GoRoute(
                      path: ':name',
                      builder: (context, state) => WikiArticlePage(name: state.pathParameters['name']!),
                    ),
                  ],
                ),
                GoRoute(path: 'settings', builder: (context, state) => const SettingsPage()),
                GoRoute(path: 'share', builder: (context, state) => const ShareAppPage()),
                GoRoute(path: 'info', builder: (context, state) => const InfoPage()),
                GoRoute(path: 'diagnostics', builder: (context, state) => const DiagnosticsPage()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
