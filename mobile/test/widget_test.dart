import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/main.dart';

void main() {
  testWidgets('SkinX splash displays brand', (tester) async {
    await tester.pumpWidget(const SkinX());
    expect(find.text('SkinX'), findsOneWidget);
    expect(find.textContaining('AI-assisted screening'), findsOneWidget);
  });
}
