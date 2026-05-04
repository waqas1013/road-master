import 'package:go_router/go_router.dart';

/// Direction for `/taxi-question` page transition (next from right, previous from left).
///
/// Prefer [taxiQuestionUriWithTx] on navigation so direction survives `pushReplacement`;
/// [GoRouterState.extra] is used as a fallback when `tx` is absent.
enum TaxiQuestionTransition {
  forward,
  backward,
}

const _txParam = 'tx';
const _txNext = 'n';
const _txPrev = 'p';

/// Appends `tx=` so [taxiQuestionTransitionFromState] picks the correct slide.
String taxiQuestionUriWithTx(String baseUri, TaxiQuestionTransition transition) {
  final v = transition == TaxiQuestionTransition.backward ? _txPrev : _txNext;
  return baseUri.contains('?') ? '$baseUri&$_txParam=$v' : '$baseUri?$_txParam=$v';
}

TaxiQuestionTransition taxiQuestionTransitionFromState(GoRouterState state) {
  final tx = state.uri.queryParameters[_txParam];
  if (tx == _txPrev) return TaxiQuestionTransition.backward;
  if (tx == _txNext) return TaxiQuestionTransition.forward;
  if (state.extra is TaxiQuestionTransition) {
    return state.extra! as TaxiQuestionTransition;
  }
  return TaxiQuestionTransition.forward;
}
