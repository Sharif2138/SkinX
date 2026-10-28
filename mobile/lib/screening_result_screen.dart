import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'widgets/skinx_feedback.dart';
import 'models/screening_result.dart';
import 'services/app_language.dart';

class ScreeningResultScreen extends StatefulWidget {
  const ScreeningResultScreen({
    super.key,
    required this.result,
    required this.onSave,
    this.communityHealthWorker = false,
    this.initialPatientName = '',
    this.originalImageBytes,
  });

  final ScreeningResult result;
  final Future<void> Function(String? patientName) onSave;
  final bool communityHealthWorker;
  final String initialPatientName;
  final Uint8List? originalImageBytes;

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen> {
  bool _saving = false;
  bool _saved = false;
  bool _showHeatmap = true;
  late final TextEditingController _name = TextEditingController(text: widget.initialPatientName);
  bool _permissionConfirmed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _saved) return;
    final patientName = _name.text.trim();
    if (widget.communityHealthWorker && patientName.isEmpty) {
      SkinXNotice.show(
        context,
        'Enter the patient name to save this screening.',
        error: true,
      );
      return;
    }
    if (widget.communityHealthWorker && !_permissionConfirmed) {
      SkinXNotice.show(
        context,
        'Confirm permission to save the patient record.',
        error: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(widget.communityHealthWorker ? patientName : null);
      if (mounted) {
        setState(() => _saved = true);
        SkinXNotice.show(context, 'Result saved');
      }
    } catch (_) {
      if (mounted)
        SkinXNotice.show(
          context,
          'Could not save the result on this device.',
          error: true,
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final status = result.status;
    final suspicious = status == ScreeningResult.suspicious;
    final cannotInfer = status == ScreeningResult.cannotInfer;
    final borderline = result.cannotInferReason == ScreeningResult.borderlinePredictionReason;
    final heatmap = result.explanationImageBytes;
    final heatmapAvailable = !cannotInfer && heatmap != null;
    final score = result.targetProbability;
    final threshold = result.decisionThreshold;
    const ink = Color(0xFF193B38);
    const teal = Color(0xFF14665E);
    final statusColor = suspicious
        ? const Color(0xFFB45309)
        : cannotInfer ? const Color(0xFF667085) : teal;
    final statusIcon = suspicious
        ? Icons.warning_amber_rounded
        : cannotInfer ? Icons.help_outline_rounded : Icons.info_outline_rounded;
    final displayedPhoto = heatmapAvailable && _showHeatmap
        ? heatmap
        : widget.originalImageBytes;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const SkinXText('Screening result'),
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      border: Border.all(color: statusColor.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkinXText(status, style: TextStyle(
                                fontSize: 23, height: 1.2, fontWeight: FontWeight.w700, color: statusColor,
                              )),
                              const SizedBox(height: 8),
                              SkinXText(result.message, style: const TextStyle(
                                fontSize: 14, height: 1.55, color: ink,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.originalImageBytes != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE0E9E6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: SkinXText('Photo reviewed', style: TextStyle(
                                color: ink, fontWeight: FontWeight.w700, fontSize: 16,
                              ))),
                              if (heatmapAvailable)
                                TextButton.icon(
                                  onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
                                  icon: Icon(_showHeatmap ? Icons.visibility_outlined : Icons.local_fire_department_outlined, size: 18),
                                  label: SkinXText(_showHeatmap ? 'Show original photo' : 'Show heatmap'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxHeight: 320),
                              color: const Color(0xFFF0F4F2),
                              child: Image.memory(
                                displayedPhoto!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: SkinXText('The photo preview could not be displayed.'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (heatmapAvailable && _showHeatmap)
                            const SkinXText(
                              'Highlighted areas influenced the model\'s output. They are not confirmed cancerous tissue.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF647D78)),
                            )
                          else if (!heatmapAvailable && !cannotInfer)
                            const SkinXText(
                              'Heatmap is not available in this build. The photo was processed on this device.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF647D78)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (score != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE0E9E6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: SkinXText('Model score', style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: ink,
                              ))),
                              SkinXText('${(score * 100).toStringAsFixed(1)}%', style: const TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w700, color: teal,
                              )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: score.clamp(0.0, 1.0).toDouble(),
                              minHeight: 9,
                              backgroundColor: const Color(0xFFE8EFEC),
                              color: statusColor,
                            ),
                          ),
                          if (threshold != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Expanded(child: SkinXText('Decision threshold', style: TextStyle(
                                  color: Color(0xFF647D78), fontSize: 13,
                                ))),
                                SkinXText('${(threshold * 100).toStringAsFixed(1)}%', style: const TextStyle(
                                  color: ink, fontSize: 13, fontWeight: FontWeight.w600,
                                )),
                              ],
                            ),
                          ],
                          if (borderline && result.uncertaintyLowerBoundary != null &&
                              result.uncertaintyUpperBoundary != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Expanded(child: SkinXText('Borderline score range', style: TextStyle(
                                  color: Color(0xFF647D78), fontSize: 13,
                                ))),
                                SkinXText(
                                  '${(result.uncertaintyLowerBoundary! * 100).toStringAsFixed(1)}%–${(result.uncertaintyUpperBoundary! * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          const SkinXText(
                            'This score is the model output, not a calibrated probability of cancer.',
                            style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF647D78)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.health_and_safety_outlined, color: teal, size: 23),
                        SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkinXText('Screening is not a diagnosis', style: TextStyle(
                              fontWeight: FontWeight.w700, color: ink, fontSize: 14,
                            )),
                            SizedBox(height: 5),
                            SkinXText(
                              borderline
                                  ? 'A borderline model score does not mean the lesion is harmless. Seek clinical assessment for a growing, bleeding, painful, changing or non-healing area.'
                                  : 'A less suspicious result does not rule out skin cancer. Seek clinical assessment for a growing, bleeding, painful, changing or non-healing area.',
                              style: TextStyle(fontSize: 13, height: 1.5, color: ink),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (score != null) ...[
                    if (widget.communityHealthWorker) ...[
                      TextField(
                        controller: _name,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: AppLanguage.text('Patient name'),
                          helperText: AppLanguage.text('Required to save the screening'),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _permissionConfirmed,
                        onChanged: (value) => setState(() => _permissionConfirmed = value ?? false),
                        title: const SkinXText(
                          'I have permission to save this person’s name and screening result on this device and in my account when online.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving || _saved ? null : _save,
                        icon: Icon(_saved ? Icons.check_circle_outline : Icons.save_outlined),
                        style: FilledButton.styleFrom(
                          backgroundColor: teal,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        label: SkinXText(_saved ? 'Result saved' : _saving ? 'Saving...' : 'Save result'),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SkinXText(
                      widget.communityHealthWorker
                          ? 'The patient name, result and date are saved. Signed-in records sync to the account when online. Photos are never uploaded.'
                          : 'Only the result and date are saved, never the photo or a patient name. Signed-in records sync when online; guest records stay on this device.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF647D78), height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
