import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/taxi_question_bank.dart';
import 'router/app_router.dart';
import 'services/sakerhet_practice_repository.dart';
import 'services/lagar_practice_repository.dart';
import 'services/karta_practice_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaxiQuestionBank.instance.load();
  await SakerhetPracticeRepository.init();
  await LagarPracticeRepository.init();
  await KartaPracticeRepository.init();
  runApp(
    const ProviderScope(
      child: RoadMasterApp(),
    ),
  );
}

class RoadMasterApp extends StatelessWidget {
  const RoadMasterApp({super.key});

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
