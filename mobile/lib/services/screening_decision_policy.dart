enum ScreeningDecision {
  suspicious,
  lessSuspicious,
  cannotInfer,
}

class ScreeningDecisionPolicy {
  const ScreeningDecisionPolicy._();

  static ScreeningDecision classify({
    required double targetProbability,
    required double threshold,
    required double uncertaintyMargin,
    required bool uncertaintyAbstentionEnabled,
  }) {
    if (!targetProbability.isFinite || targetProbability < 0 || targetProbability > 1) {
      throw ArgumentError.value(targetProbability, 'targetProbability', 'Must be finite and between 0 and 1.');
    }
    if (!threshold.isFinite || threshold <= 0 || threshold >= 1) {
      throw ArgumentError.value(threshold, 'threshold', 'Must be finite and strictly between 0 and 1.');
    }
    if (!uncertaintyMargin.isFinite || uncertaintyMargin < 0) {
      throw ArgumentError.value(uncertaintyMargin, 'uncertaintyMargin', 'Must be finite and non-negative.');
    }
    if (uncertaintyAbstentionEnabled) {
      if (uncertaintyMargin <= 0 || uncertaintyMargin >= threshold || uncertaintyMargin >= 1 - threshold) {
        throw ArgumentError.value(uncertaintyMargin, 'uncertaintyMargin', 'Must fit on both sides of the decision threshold.');
      }
      if ((targetProbability - threshold).abs() <= uncertaintyMargin) {
        return ScreeningDecision.cannotInfer;
      }
    }
    return targetProbability >= threshold
        ? ScreeningDecision.suspicious
        : ScreeningDecision.lessSuspicious;
  }
}
