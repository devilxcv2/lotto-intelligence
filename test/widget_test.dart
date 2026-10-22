// test/widget_test.dart

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/app/lotto_app.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/core/database/database_provider.dart';
import 'package:lotto_intelligence/core/settings/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding poi dashboard vuota', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const LottoApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('laboratorio'), findsWidgets);
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    expect(find.textContaining('aleatorio'), findsOneWidget);
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entra nel laboratorio'));
    await tester.pumpAndSettle();
    expect(find.text('Lotto Intelligence'), findsOneWidget);
    expect(find.text('Nessuna estrazione in archivio.'), findsOneWidget);

    final settings = await SettingsRepository(database).load();
    expect(settings.onboardingCompleted, isTrue);
  });
}
