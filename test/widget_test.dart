import 'package:flutter_test/flutter_test.dart';
import 'package:road_master/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoadMasterApp());

    // Verify that onboarding screen is shown.
    expect(find.text('Din väg till körkortet börjar här'), findsOneWidget);
  });
}
