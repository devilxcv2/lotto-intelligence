// lib/features/dashboard/presentation/startup_pages.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/lotto_app.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/lotto/scientific_notice.dart';
import '../../../core/settings/settings_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  var _left = false;

  void _open(bool onboardingDone) {
    if (_left || !mounted) return;
    _left = true;
    final fromNotification = ref.read(launchRouteProvider);
    if (onboardingDone && fromNotification != null) {
      ref.read(launchRouteProvider.notifier).state = null;
      context.go(fromNotification);
      return;
    }
    context.go(onboardingDone ? '/dashboard' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    ref.listen(settingsControllerProvider, (_, next) {
      next.whenData((value) => _open(value.onboardingCompleted));
    });
    settings.whenData((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open(value.onboardingCompleted));
    });
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F0FA), Colors.white, Color(0xFFFFF6E8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Color(0x331B4E8C), blurRadius: 18, offset: Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.casino_outlined, size: 44, color: AppColors.ballText),
              ),
              const SizedBox(height: 20),
              Text(
                'Lotto Intelligence',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'serif',
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Archivio · studio · simulazioni',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.numberBlue),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardCard(
        title: 'Un laboratorio, non una ricevitoria',
        body: 'Qui si archiviano le estrazioni, si descrivono frequenze e ritardi e si costruiscono combinazioni di studio. L\'app non compra giocate e non gestisce denaro reale.',
      ),
      const _OnboardCard(title: 'Il caso resta caso', body: scientificDisclaimer),
      const _OnboardCard(
        title: 'Prima i dati, poi i conti',
        body: 'Le analisi usano l\'archivio locale. Senza rete restano disponibili quelle già scaricate. Un numero proposto è un\'ipotesi da confrontare con il passato, non una previsione.',
      ),
    ];
    final last = _index == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  children: pages,
                ),
              ),
              Row(
                children: [
                  Text('${_index + 1} / ${pages.length}'),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (!last) {
                        await _controller.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                        return;
                      }
                      await ref.read(settingsControllerProvider.notifier).completeOnboarding();
                      if (context.mounted) context.go('/dashboard');
                    },
                    child: Text(last ? 'Entra nel laboratorio' : 'Continua'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardCard extends StatelessWidget {
  const _OnboardCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
      ],
    );
  }
}
