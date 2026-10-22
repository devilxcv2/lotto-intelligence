// lib/core/database/database_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('Il database va fornito all\'avvio dell\'applicazione.');
});
