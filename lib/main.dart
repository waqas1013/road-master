import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/taxi_question_bank.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/sakerhet_practice_repository.dart';
import 'services/lagar_practice_repository.dart';
import 'services/karta_practice_repository.dart';
import 'theme/app_theme.dart';

/// Production web: set `--dart-define=RECAPTCHA_SITE_KEY=<key>` from Firebase App Check (reCAPTCHA v3).
const _webRecaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    providerWeb: kIsWeb
        ? (kDebugMode
            ? WebDebugProvider()
            : (_webRecaptchaSiteKey.isEmpty
                ? WebDebugProvider()
                : ReCaptchaV3Provider(_webRecaptchaSiteKey)))
        : null,
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider(),
  );

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
