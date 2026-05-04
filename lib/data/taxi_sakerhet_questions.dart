import '../models/taxi_practice_question.dart';

/// Questions per säkerhet practice set (matches UI copy on [TaxiSakerhetScreen]).
const int taxiSakerhetQuestionsPerSet = 75;

const String kTaxiModuleSakerhet = 'sakerhet';

/// Set 1 — säkerhet. Add further entries as you build the bank.
final List<TaxiPracticeQuestion> taxiSakerhetSet1 = [
  TaxiPracticeQuestion(
    id: 'sakerhet_s1_q1',
    moduleId: kTaxiModuleSakerhet,
    setNumber: 1,
    questionNumber: 1,
    totalInSet: taxiSakerhetQuestionsPerSet,
    categoryTag: 'Nödsituation',
    prompt:
        'Du kör taxi och bevittnar en lindrig trafikolycka på en svensk väg. Föraren i en annan bil har kolliderat; din bil är oskadd. Vad bör du göra först?',
    options: const [
      'Stanna på ett säkert sätt utan att utgöra fara.\n'
      'Sätt på varningsblinkers.\n'
      'Gör en snabb överblick av läget innan du agerar vidare.',
      'Kör vidare direkt så att du inte blockerar trafiken; olyckor är inte din uppgift att hantera.',
      'Stig ur och spring fram till de inblandade utan att först säkra platsen eller varna andra trafikanter.',
      'Ring 112 innan du gör något annat, även om du inte stannat eller bedömt läget.',
    ],
    correctOptionIndex: 0,
    explanationText:
        'Vid en olycka ska du först säkra platsen: stanna på ett betryggande sätt, varna andra med varningsblinkers och överblicka situationen innan du hjälper eller larmar. '
        'Att agera utan att först säkra området kan skapa mer risk för dig, passagerare och övrig trafik.',
    /// Exported from Stitch canvas (node taxi-olycka illustration):
    /// https://stitch.withgoogle.com/projects/12151423533525555918?node-id=6710e5a187464cfeb51dbcffd4e5c3d7
    imageAssetPath: 'assets/taxi/sakerhet_set1_q1.png',
    imageSemanticLabel:
        'Illustration: taxi med varningsblinkers på en svensk väg vid en lindrig olycka; föraren står på säkert avstånd och överväger läget; lugnt men akut instruktionsuttryck.',
    designIllustrationPrompt:
        'A professional and clear illustration of a car accident scene on a Swedish road. In the foreground, a taxi is parked safely with its hazard lights on. '
        'A person (the driver) is standing at a safe distance, looking over the scene. In the background, there\'s another car that has been in a minor collision. '
        'The scene should be calm but urgent, focusing on the steps of emergency response: overviewing the situation and warning others. '
        'Clean, modern, instructional style.',
  ),
];

/// Resolve a question for deep links / router.
TaxiPracticeQuestion? lookupSakerhetQuestion({required int set, required int questionOneBased}) {
  if (questionOneBased < 1) return null;
  if (set == 1) {
    // Only Q1 is implemented; extend list for more.
    if (questionOneBased == 1) return taxiSakerhetSet1.first;
  }
  return null;
}

TaxiPracticeQuestion? lookupTaxiQuestion({
  required String module,
  required int set,
  required int questionOneBased,
}) {
  if (module == kTaxiModuleSakerhet) {
    return lookupSakerhetQuestion(set: set, questionOneBased: questionOneBased);
  }
  return null;
}
