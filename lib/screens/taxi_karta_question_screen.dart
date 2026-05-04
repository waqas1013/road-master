import 'package:flutter/material.dart';
import '../data/taxi_karta_questions.dart';
import 'taxi_interactive_question_screen.dart';

class TaxiKartaQuestionScreen extends StatelessWidget {
  const TaxiKartaQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TaxiInteractiveQuestionScreen(
      question: taxiKartaPlaceholderQuestion,
    );
  }
}
