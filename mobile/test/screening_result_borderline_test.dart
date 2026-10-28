import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/models/screening_result.dart';
import 'package:skinx/screening_result_screen.dart';

void main() {
  testWidgets('borderline results show the score range and can be saved', (tester) async {
    var saved = false;
    const threshold = 0.374953031539917;
    const margin = 0.05;

    await tester.pumpWidget(MaterialApp(
      home: ScreeningResultScreen(
        result: ScreeningResult.borderline(
          targetProbability: 0.376,
          decisionThreshold: threshold,
          uncertaintyLowerBoundary: threshold - margin,
          uncertaintyUpperBoundary: threshold + margin,
        ),
        onSave: (_) async {
          saved = true;
        },
      ),
    ));

    expect(find.text('Cannot infer'), findsOneWidget);
    expect(find.text('37.6%'), findsOneWidget);
    expect(find.text('32.5%–42.5%'), findsOneWidget);
    expect(find.textContaining('This does not mean the lesion is harmless'), findsOneWidget);

    final saveButton = find.text('Save result');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(saved, isTrue);
  });
}
