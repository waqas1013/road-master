import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
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
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../data/taxi_karta_practice_sets.dart';
import '../models/taxi_practice_question.dart';
import '../screens/taxi_interactive_question_screen.dart';
import '../screens/taxi_continue_practice_screen.dart';
import '../screens/taxi_sakerhet_continue_practice_screen.dart';
import '../screens/taxi_lagar_continue_practice_screen.dart';
import '../screens/taxi_karta_continue_practice_screen.dart';
import '../screens/taxi_review_results_screen.dart';
import '../screens/taxi_lagar_review_results_screen.dart';
import '../screens/taxi_karta_review_results_screen.dart';
import '../screens/taxi_mock_exams_screen.dart';

/// Routes that don't require authentication (browsing allowed).
const _publicPaths = {
  '/',
  '/login',
  '/register',
  '/forgot-password',
  '/category-selection',
  '/taxi-dashboard',
  '/taxi-sakerhet',
  '/taxi-lagstiftning',
  '/taxi-karta',
  '/dashboard',
};

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final path = state.uri.path;

      if (loggedIn && (path == '/login' || path == '/register')) {
        return '/category-selection';
      }

      if (!loggedIn && !_publicPaths.contains(path)) {
        return '/login';
      }

      return null;
    },
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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
          } else if (module == kTaxiModuleLagstiftning &&
              practiceSet != null &&
              practiceSet >= 1 &&
              practiceSet <= kLagstiftningPracticeSetCount) {
            practiceSetArg = practiceSet;
            question = lookupLagstiftningPracticeQuestion(
                  practiceSet: practiceSet,
                  questionOneBased: q,
                ) ??
                taxiQuestionFallback;
          } else if (module == kTaxiModuleKarta &&
              practiceSet != null &&
              practiceSet >= 1 &&
              practiceSet <= kKartaPracticeSetCount) {
            practiceSetArg = practiceSet;
            question = lookupKartaPracticeQuestion(
                  practiceSet: practiceSet,
                  questionOneBased: q,
                ) ??
                taxiQuestionFallback;
          } else {
            practiceSetArg = null;
            question = lookupTaxiQuestion(module: module, set: set, questionOneBased: q) ??
                taxiQuestionFallback;
          }

          final navIndex = module == kTaxiModuleLagstiftning ? 3
              : module == kTaxiModuleKarta ? 1
              : 2;

          return TaxiInteractiveQuestionScreen(
            question: question,
            practiceSet: practiceSetArg,
            bottomNavActiveIndex: navIndex,
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
      GoRoute(
        path: '/taxi-lagar-continue',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kLagstiftningPracticeSetCount);
          return TaxiLagarContinuePracticeScreen(practiceSet: clamped);
        },
      ),
      GoRoute(
        path: '/taxi-lagar-review',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kLagstiftningPracticeSetCount);
          return TaxiLagarReviewResultsScreen(practiceSet: clamped);
        },
      ),
      GoRoute(
        path: '/taxi-karta-continue',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kKartaPracticeSetCount);
          return TaxiKartaContinuePracticeScreen(practiceSet: clamped);
        },
      ),
      GoRoute(
        path: '/taxi-karta-review',
        builder: (context, state) {
          final ps = int.tryParse(state.uri.queryParameters['practiceSet'] ?? '1') ?? 1;
          final clamped = ps.clamp(1, kKartaPracticeSetCount);
          return TaxiKartaReviewResultsScreen(practiceSet: clamped);
        },
      ),
      GoRoute(
        path: '/taxi-mock-exams',
        builder: (context, state) => const TaxiMockExamsScreen(),
      ),
    ],
  );
}
