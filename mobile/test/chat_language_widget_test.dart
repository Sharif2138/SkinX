import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/services/app_language.dart';
import 'package:skinx/widgets/chat_message_text.dart';

void main() {
  testWidgets('Existing labels change as soon as the language changes', (tester) async {
    await AppLanguage.instance.setLanguage('en');
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SkinXText('Learn')),
    ));
    expect(find.text('Learn'), findsOneWidget);

    await AppLanguage.instance.setLanguage('rw');
    await tester.pump();
    expect(find.text('Iga'), findsOneWidget);

    await AppLanguage.instance.setLanguage('en');
    await tester.pump();
  });

  testWidgets('Chat replies render Markdown as formatted text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ChatMessageText(
        '**Important:** Check for changes.\n\n### What to do\n- Seek medical care.',
      )),
    ));

    expect(find.textContaining('Important:'), findsOneWidget);
    expect(find.textContaining('What to do'), findsOneWidget);
    expect(find.textContaining('Seek medical care.'), findsOneWidget);
    expect(find.textContaining('###'), findsNothing);
  });
}
