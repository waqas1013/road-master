import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_master/data/taxi_question_bank.dart';
import 'package:road_master/router/app_router.dart';
import 'package:road_master/services/sakerhet_practice_repository.dart';
import 'package:road_master/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await TaxiQuestionBank.instance.load();
    await SakerhetPracticeRepository.init();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kom igång'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Road Master - Swedish Theory Prep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
