import 'package:go_router/go_router.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/category_selection_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/study_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/taxi_dashboard_screen.dart';
import '../screens/taxi_karta_screen.dart';
import '../screens/taxi_lagstiftning_screen.dart';
import '../screens/taxi_sakerhet_screen.dart';
import '../data/taxi_sakerhet_questions.dart';
import '../data/taxi_sakerhet_practice_sets.dart';
import '../models/taxi_practice_question.dart';
import '../screens/taxi_interactive_question_screen.dart';
import '../screens/taxi_continue_practice_screen.dart';
import '../screens/taxi_sakerhet_continue_practice_screen.dart';
import '../screens/taxi_review_results_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    /// Start at onboarding so users see **Kom igång** → **Välj behörighet** (B vs Taxi).
    /// During dev you can temporarily set this to `/taxi-dashboard` to skip straight to taxi.
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/category-selection',
        builder: (context, state) => const CategorySelectionScreen(),
      ),
      // Körkort B routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/study',
        builder: (context, state) => const StudyScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      // Taxi License routes
      GoRoute(
        path: '/taxi-dashboard',
        builder: (context, state) => const TaxiDashboardScreen(),
      ),
      GoRoute(
        path: '/taxi-karta',
        builder: (context, state) => const TaxiKartaScreen(),
      ),
      GoRoute(
        path: '/taxi-lagstiftning',
        builder: (context, state) => const TaxiLagstiftningScreen(),
      ),
      GoRoute(
        path: '/taxi-sakerhet',
        builder: (context, state) => const TaxiSakerhetScreen(),
      ),
      GoRoute(
        path: '/taxi-question',
        builder: (context, state) {
          final module = state.uri.queryParameters['module'] ?? kTaxiModuleSakerhet;
          final set = int.tryParse(state.uri.queryParameters['set'] ?? '1') ?? 1;
          final q = int.tryParse(state.uri.queryParameters['q'] ?? '1') ?? 1;
          final practiceSetRaw = state.uri.queryParameters['practiceSet'];
          final practiceSet = practiceSetRaw != null ? int.tryParse(practiceSetRaw) : null;

          final TaxiPracticeQuestion question;
          final int? practiceSetArg;

          if (module == kTaxiModuleSakerhet &&
              practiceSet != null &&
              practiceSet >= 1 &&
              practiceSet <= kSakerhetPracticeSetCount) {
            practiceSetArg = practiceSet;
            question = lookupSakerhetPracticeQuestion(
                  practiceSet: practiceSet,
                  questionOneBased: q,
                ) ??
                taxiQuestionFallback;
          } else {
            practiceSetArg = null;
            question = lookupTaxiQuestion(module: module, set: set, questionOneBased: q) ??
                taxiQuestionFallback;
          }

          return TaxiInteractiveQuestionScreen(
            question: question,
            practiceSet: practiceSetArg,
          );
        },
      ),
      GoRoute(
        path: '/taxi-sakerhet-continue',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kSakerhetPracticeSetCount);
          return TaxiSakerhetContinuePracticeScreen(practiceSet: clamped);
        },
      ),
      GoRoute(
        path: '/taxi-continue-practice',
        builder: (context, state) => const TaxiContinuePracticeScreen(),
      ),
      GoRoute(
        path: '/taxi-sakerhet-review',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kSakerhetPracticeSetCount);
          return TaxiReviewResultsScreen(practiceSet: clamped);
        },
      ),
    ],
  );
}
