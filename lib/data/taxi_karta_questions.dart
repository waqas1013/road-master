import '../models/taxi_practice_question.dart';

const String kTaxiModuleKarta = 'karta';

/// Placeholder karta question (used by [TaxiKartaQuestionScreen]) until karta sets are modelled.
final TaxiPracticeQuestion taxiKartaPlaceholderQuestion = TaxiPracticeQuestion(
  id: 'karta_stub_q12',
  moduleId: kTaxiModuleKarta,
  setNumber: 1,
  questionNumber: 12,
  totalInSet: 45,
  categoryTag: 'Karta',
  prompt: 'Vilken är den kortaste tillåtna vägen mellan punkt A och punkt B i denna trafiksituation?',
  options: const [
    'Rakt fram på Storgatan, sedan höger på Vasagatan.',
    'Vänster på Nygatan, sedan höger på Drottninggatan.',
    'Rakt fram, men du måste stanna för gående innan svängen.',
    'Det är förbjudet att svänga till punkt B från denna position.',
  ],
  correctOptionIndex: 0,
  explanationText:
      'Tillfällig förklaring: följ den rutt som följer lokala huvudleder och gällande väjningsplikt i situationen på kartan.',
  imageNetworkUrl:
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800',
);
