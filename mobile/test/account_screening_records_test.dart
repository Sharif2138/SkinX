import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/models/screening_result.dart';
import 'package:skinx/screening_result_screen.dart';

void main() {
  const result = ScreeningResult(
    status: ScreeningResult.suspicious,
    message: 'Clinical assessment is recommended.',
    targetProbability: 0.42,
    decisionThreshold: 0.374953,
  );

  testWidgets('Individual screening results do not request a patient name', (tester) async {
    String? savedName;
    await tester.pumpWidget(MaterialApp(
      home: ScreeningResultScreen(
        result: result,
        onSave: (name) async { savedName = name; },
      ),
    ));

    expect(find.text('Patient name'), findsNothing);
    await tester.ensureVisible(find.text('Save result'));
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, isNull);
  });

  testWidgets('Community health worker records require a name and permission', (tester) async {
    String? savedName;
    await tester.pumpWidget(MaterialApp(
      home: ScreeningResultScreen(
        result: result,
        communityHealthWorker: true,
        onSave: (name) async { savedName = name; },
      ),
    ));

    await tester.ensureVisible(find.text('Save result'));
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, isNull);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Patient A');
    await tester.ensureVisible(find.text('Save result'));
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, isNull);

    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.ensureVisible(find.text('Save result'));
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, 'Patient A');
  });

  testWidgets('Screening result shows the model score and locked threshold', (tester) async {
    const scoredResult = ScreeningResult(
      status: ScreeningResult.suspicious,
      message: 'Clinical assessment is recommended.',
      targetProbability: 0.42,
      decisionThreshold: 0.374953,
    );
    await tester.pumpWidget(MaterialApp(
      home: ScreeningResultScreen(
        result: scoredResult,
        onSave: (_) async {},
      ),
    ));

    expect(find.text('Model score'), findsOneWidget);
    expect(find.text('42.0%'), findsOneWidget);
    expect(find.text('Decision threshold'), findsOneWidget);
    expect(find.text('37.5%'), findsOneWidget);
  });
}
