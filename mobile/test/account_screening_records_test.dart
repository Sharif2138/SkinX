import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/models/screening_result.dart';
import 'package:skinx/screening_result_screen.dart';

void main() {
  const result = ScreeningResult(
    status: ScreeningResult.suspicious,
    message: 'Clinical assessment is recommended.',
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

    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, isNull);

    await tester.enterText(find.byType(TextField), 'Patient A');
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, isNull);

    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Save result'));
    await tester.pump();
    expect(savedName, 'Patient A');
  });
}
