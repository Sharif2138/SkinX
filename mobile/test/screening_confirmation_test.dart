import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/screening_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screening requires confirmation of a skin photo', (tester) async {
    final data = await rootBundle.load('assets/parity_tests/synthetic_source.png');
    final bytes = Uint8List.view(data.buffer);
    var confirmed = false;
    var screened = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (context, setState) => ScreeningScreen(
        photo: MemoryImage(bytes),
        photoConfirmed: confirmed,
        onPhotoConfirmedChanged: (value) => setState(() => confirmed = value),
        onScreenPhoto: confirmed ? () => screened = true : null,
      ),
    ))));
    expect(find.text('Confirm photo to screen'), findsOneWidget);
    expect(screened, false);
    await tester.scrollUntilVisible(find.byType(CheckboxListTile), 90);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('Screen photo'), findsOneWidget);
  });
}
