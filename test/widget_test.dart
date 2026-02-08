import 'package:flutter_test/flutter_test.dart';
import 'package:game_wordcraft/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
