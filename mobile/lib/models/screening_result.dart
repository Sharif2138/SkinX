import 'dart:typed_data';

class ScreeningResult {
  const ScreeningResult({
    required this.status,
    required this.message,
    this.targetProbability,
    this.decisionThreshold,
    this.uncertaintyLowerBoundary,
    this.uncertaintyUpperBoundary,
    this.cannotInferReason,
    this.explanationImageBytes,
  });

  final String status;
  final String message;
  final double? targetProbability;
  final double? decisionThreshold;
  final double? uncertaintyLowerBoundary;
  final double? uncertaintyUpperBoundary;
  final String? cannotInferReason;

  /// A locally generated image overlay. It is kept in memory only and is not saved to history.
  final Uint8List? explanationImageBytes;

  static const suspicious = 'Suspicious';
  static const lessSuspicious = 'Less suspicious';
  static const cannotInfer = 'Cannot infer';
  static const technicalFailureReason = 'TECHNICAL_FAILURE';
  static const borderlinePredictionReason = 'BORDERLINE_PREDICTION';

  factory ScreeningResult.failed([String? detail]) => ScreeningResult(
    status: cannotInfer,
    message: detail ?? 'Could not screen this image. Please use a valid JPEG or PNG photo.',
    cannotInferReason: technicalFailureReason,
  );

  factory ScreeningResult.borderline({
    required double targetProbability,
    required double decisionThreshold,
    required double uncertaintyLowerBoundary,
    required double uncertaintyUpperBoundary,
  }) => ScreeningResult(
    status: cannotInfer,
    message: 'The model score is close to its decision threshold, so SkinX cannot assign a screening category. This does not mean the lesion is harmless. Please seek assessment from a qualified healthcare professional, especially if the lesion is growing, bleeding, changing or not healing.',
    targetProbability: targetProbability,
    decisionThreshold: decisionThreshold,
    uncertaintyLowerBoundary: uncertaintyLowerBoundary,
    uncertaintyUpperBoundary: uncertaintyUpperBoundary,
    cannotInferReason: borderlinePredictionReason,
  );
}
