// lib/shared/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../core/lotto/prize_table.dart';
import '../../core/lotto/scientific_notice.dart';
import '../../core/lotto/wheel_catalog.dart';
import '../../core/settings/settings_controller.dart';
import '../../features/statistics/domain/statistics_engine.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.banner.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.banner),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(scientificDisclaimer),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({required this.title, required this.child, this.trailing, super.key});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class NumberBalls extends StatelessWidget {
  const NumberBalls({required this.numbers, this.hits = const {}, this.gold = false, this.compact = false, super.key});

  final List<int> numbers;
  final Set<int> hits;

  /// Palline oro, come le estrazioni speciali. I [hits] restano blu.
  final bool gold;

  /// Palline più piccole per le tabelle a molte ruote.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 42.0;
    return Wrap(
      spacing: compact ? 4 : 8,
      runSpacing: compact ? 4 : 8,
      alignment: WrapAlignment.end,
      children: [
        for (final number in numbers)
          Semantics(
            label: 'Numero $number',
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hits.contains(number) || gold ? AppColors.ballGold : AppColors.ball,
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 12 : null,
                  color: hits.contains(number) || gold ? AppColors.navy : AppColors.ballText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Fascia arancione «Estrazione del …».
class ResultsBanner extends StatelessWidget {
  const ResultsBanner(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.banner,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

/// Tabella a righe alternate: nome ruota arancione, palline blu.
class DrawBoard extends StatelessWidget {
  const DrawBoard({required this.banner, required this.rows, this.footer, this.onWheelTap, super.key});

  final String banner;
  final List<({String wheel, List<int> numbers, String? code})> rows;
  final String? footer;
  final ValueChanged<String>? onWheelTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultsBanner(banner),
        for (var i = 0; i < rows.length; i++)
          Material(
            color: i.isOdd ? (dark ? const Color(0xFF1A283C) : AppColors.rowAlt) : Colors.transparent,
            child: InkWell(
              onTap: rows[i].code == null || onWheelTap == null ? null : () => onWheelTap!(rows[i].code!),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rows[i].wheel,
                            style: const TextStyle(color: AppColors.wheel, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          if (rows[i].code != null)
                            Text(rows[i].code!, style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: NumberBalls(numbers: rows[i].numbers, compact: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(footer!, style: TextStyle(color: muted, fontSize: 12)),
          ),
      ],
    );
  }
}

/// Tabella con intestazione arancione, come i «Top ritardatari».
class OrangeTable extends StatelessWidget {
  const OrangeTable({required this.headers, required this.rows, super.key});

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ColoredBox(
          color: AppColors.banner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final header in headers)
                  Expanded(
                    child: Text(header, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < rows.length; i++)
          ColoredBox(
            color: i.isOdd ? (dark ? const Color(0xFF1A283C) : AppColors.rowAlt) : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (var c = 0; c < rows[i].length; c++)
                    Expanded(
                      child: Text(
                        rows[i][c],
                        style: TextStyle(
                          color: c == 0 ? AppColors.wheel : AppColors.numberBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class WheelSelector extends ConsumerWidget {
  const WheelSelector({this.onChanged, this.includeAllWheels = false, this.selectedCode, super.key});

  /// Se valorizzato, non scrive nelle impostazioni globali: solo callback.
  final ValueChanged<String>? onChanged;

  /// Aggiunge la voce «Tutte (÷10)» per le schedine.
  final bool includeAllWheels;

  /// Codice selezionato quando si usa [onChanged] (locale). Altrimenti legge le impostazioni.
  final String? selectedCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).value;
    final selected = selectedCode ?? settings?.selectedWheelCode ?? 'BA';
    void pick(String code) {
      if (onChanged != null) {
        onChanged!(code);
      } else {
        ref.read(settingsControllerProvider.notifier).selectWheel(code);
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final wheel in officialWheels)
          FilterChip(
            avatar: CircleAvatar(
              backgroundColor: wheel.code == selected ? AppColors.banner : AppColors.navy.withValues(alpha: 0.12),
              child: Text(
                wheel.code,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: wheel.code == selected ? Colors.white : AppColors.navy,
                ),
              ),
            ),
            label: Text(wheel.name),
            selected: wheel.code == selected,
            onSelected: (_) => pick(wheel.code),
            showCheckmark: false,
          ),
        if (includeAllWheels)
          FilterChip(
            avatar: CircleAvatar(
              backgroundColor: selected == allWheelsCode ? AppColors.banner : AppColors.navy.withValues(alpha: 0.12),
              child: Icon(Icons.grid_view, size: 14, color: selected == allWheelsCode ? Colors.white : AppColors.navy),
            ),
            label: const Text('Tutte (÷10)'),
            selected: selected == allWheelsCode,
            onSelected: (_) => pick(allWheelsCode),
            showCheckmark: false,
          ),
      ],
    );
  }
}

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({required this.value, required this.onRetry, required this.data, super.key});

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Non riesco a leggere i dati locali.'),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Riprova')),
            ],
          ),
        ),
      ),
      data: data,
    );
  }
}

class EmptyArchive extends StatelessWidget {
  const EmptyArchive({required this.onSync, super.key});

  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('L\'archivio locale non contiene ancora estrazioni.'),
        const SizedBox(height: 8),
        const Text('Puoi scaricare il file ZIP collegato dalla pagina ufficiale del Lotto, oppure importare un CSV o JSON tuo.'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onSync, child: const Text('Scarica archivio')),
      ],
    );
  }
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({required this.title, required this.child, this.actions, super.key});

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: child,
          ),
        ),
      ),
    );
  }
}

class WindowPicker extends StatelessWidget {
  const WindowPicker({required this.value, required this.onChanged, super.key});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <int?>[10, 30, 50, 100, 500, 1000, null];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option == null ? 'Tutte' : '$option'),
            selected: value == option,
            onSelected: (_) => onChanged(option),
          ),
      ],
    );
  }
}

List<T> sliceWindow<T>(List<T> items, int? window) => lastWindow(items, window);
