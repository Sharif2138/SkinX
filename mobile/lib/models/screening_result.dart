class ScreeningResult {
  const ScreeningResult({required this.status, required this.message, this.targetProbability});

  final String status;
  final String message;
  final double? targetProbability;

  static const suspicious = 'Suspicious';
  static const lessSuspicious = 'Less suspicious';
  static const cannotInfer = 'Cannot infer';

  factory ScreeningResult.failed([String? detail]) => ScreeningResult(
    status: cannotInfer,
    message: detail ?? 'Could not screen this image. Please use a valid JPEG or PNG photo.',
  );
}
