// lib/features/statistics/data/statistics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../draws/data/draw_repository.dart';
import '../domain/statistics_engine.dart';

typedef StatisticsKey = ({String wheel, int? window});

/// Statistiche in cache per ruota e finestra, calcolate su un isolate.
/// `null` quando la ruota non ha estrazioni nella finestra.
final wheelStatisticsProvider = FutureProvider.family<WheelStatistics?, StatisticsKey>((ref, key) async {
  final draws = await ref.watch(wheelDrawsProvider(key.wheel).future);
  final sliced = lastWindow(draws, key.window);
  if (sliced.isEmpty) return null;
  return summarizeInBackground(sliced);
});
