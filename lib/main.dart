// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/lotto_app.dart';
import 'core/background/evening_sync.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.openDefault();
  await NotificationService.instance.initialize();
  await EveningSync.initialize();
  final launchRoute = await NotificationService.instance.launchRoute();
  runApp(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(database)],
    child: LottoApp(launchRoute: launchRoute),
  ));
}
