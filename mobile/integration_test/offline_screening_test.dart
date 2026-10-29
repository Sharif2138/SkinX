import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skinx/models/screening_result.dart';
import 'package:skinx/services/skinx_model_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline model matches Colab synthetic golden output', (tester) async {
    final model = SkinXModelService();
    final input = (await rootBundle.load('assets/parity_tests/synthetic_source.png'))
        .buffer.asUint8List();
    final reference = jsonDecode(await rootBundle.loadString(
        'assets/parity_tests/expected_output.json')) as Map<String, dynamic>;
    try {
      final first = await model.screen(input);
      final second = await model.screen(input);
      expect(first.status, ScreeningResult.suspicious);
      expect(first.status, reference['expected_decision']);
      expect(first.targetProbability, isNotNull);
      expect((first.targetProbability! -
          (reference['expected_target_probability'] as num).toDouble()).abs(),
                    lessThan(0.03),
        reason:
            'Phone vs Colab score gap: float16 (~0.005) plus resize differences',
      );
      expect(second.targetProbability, closeTo(first.targetProbability!, 1e-6));
      expect((await model.screen(Uint8List(0))).status, ScreeningResult.cannotInfer);
    } finally {
      await model.close();
    }
  });
}
