import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/account_screen.dart';
import 'package:skinx/privacy_consent_screen.dart';
import 'package:skinx/widgets/skinx_account_type_selector.dart';

void main() {
  testWidgets('Privacy information opens as a full screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyConsentScreen()));
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Privacy & consent'), findsOneWidget);
    expect(find.text('Your information matters'), findsOneWidget);
    expect(find.text('What SkinX does'), findsOneWidget);
  });

  testWidgets('The profile card shows name and account type', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AccountScreen(
      name: 'Example Tester',
      initialRole: SkinXAccountType.communityHealthWorker,
      accountActionAvailable: false,
    ))));
    expect(find.text('Example Tester'), findsWidgets);
    expect(find.text('Community health worker'), findsWidgets);
    expect(find.textContaining('Capstone'), findsNothing);
  });
}
