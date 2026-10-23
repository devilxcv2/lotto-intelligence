// lib/features/superenalotto/presentation/se_chrome.dart

import 'package:flutter/material.dart';

/// Colori dedicati al SuperEnalotto: verde scuro e oro, distinti dalla bacheca Lotto.
class SeColors {
  const SeColors._();

  static const forest = Color(0xFF0B5C3B);
  static const forestDeep = Color(0xFF063D28);
  static const mint = Color(0xFF1A8F5C);
  static const gold = Color(0xFFE8C547);
  static const cream = Color(0xFFF3FAF6);
  static const ink = Color(0xFF0E2418);
}

class SeHeroHeader extends StatelessWidget {
  const SeHeroHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SeColors.forestDeep, SeColors.forest, SeColors.mint],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: SeColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SeColors.gold.withValues(alpha: 0.55)),
            ),
            child: const Icon(Icons.stars_rounded, color: SeColors.gold, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'serif',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), height: 1.35),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class SeActionCard extends StatelessWidget {
  const SeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: SeColors.forest.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: SeColors.forest.withValues(alpha: 0.12),
                child: Icon(icon, color: SeColors.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: SeColors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: SeColors.ink.withValues(alpha: 0.65), height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: SeColors.forest.withValues(alpha: 0.55)),
            ],
          ),
        ),
      ),
    );
  }
}

class SeStatChip extends StatelessWidget {
  const SeStatChip({required this.label, required this.value, this.highlight = false, super.key});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: highlight ? SeColors.gold.withValues(alpha: 0.22) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight ? SeColors.gold : SeColors.forest.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: highlight ? SeColors.forestDeep : SeColors.forest)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: SeColors.ink.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }
}

class SeCategoryBadge extends StatelessWidget {
  const SeCategoryBadge({required this.label, required this.win, super.key});

  final String label;
  final bool win;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: win ? SeColors.gold : SeColors.forest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: win ? SeColors.forestDeep : SeColors.forest,
        ),
      ),
    );
  }
}
