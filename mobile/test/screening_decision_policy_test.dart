import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/services/screening_decision_policy.dart';

void main() {
  const threshold = 0.374953031539917;
  const margin = 0.05;

  ScreeningDecision classify(double score, {bool enabled = true}) =>
      ScreeningDecisionPolicy.classify(
        targetProbability: score,
        threshold: threshold,
        uncertaintyMargin: margin,
        uncertaintyAbstentionEnabled: enabled,
      );

  test('scores outside the uncertainty range keep the existing threshold direction', () {
    expect(classify(0.20), ScreeningDecision.lessSuspicious);
    expect(classify(threshold - margin - 0.000001), ScreeningDecision.lessSuspicious);
    expect(classify(threshold + margin + 0.000001), ScreeningDecision.suspicious);
  });

  test('scores on either boundary and around the threshold return Cannot infer', () {
    expect(classify(threshold - margin), ScreeningDecision.cannotInfer);
    expect(classify(threshold), ScreeningDecision.cannotInfer);
    expect(classify(threshold + margin), ScreeningDecision.cannotInfer);
  });

  test('disabling abstention preserves the original binary decision rule', () {
    expect(classify(threshold, enabled: false), ScreeningDecision.suspicious);
    expect(classify(threshold - 0.000001, enabled: false), ScreeningDecision.lessSuspicious);
  });

  test('invalid scores and invalid enabled margins are rejected', () {
    expect(
      () => ScreeningDecisionPolicy.classify(
        targetProbability: double.nan,
        threshold: threshold,
        uncertaintyMargin: margin,
        uncertaintyAbstentionEnabled: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => ScreeningDecisionPolicy.classify(
        targetProbability: 0.5,
        threshold: threshold,
        uncertaintyMargin: threshold,
        uncertaintyAbstentionEnabled: true,
      ),
      throwsArgumentError,
    );
  });
}
