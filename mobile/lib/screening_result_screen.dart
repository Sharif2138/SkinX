import 'services/app_language.dart';
import 'widgets/skinx_feedback.dart';
import 'package:flutter/material.dart';
import 'models/screening_result.dart';

class ScreeningResultScreen extends StatefulWidget {
  const ScreeningResultScreen({
    super.key,
    required this.result,
    required this.onSave,
    this.communityHealthWorker = false,
    this.initialPatientName = '',
  });
  final ScreeningResult result;
  final Future<void> Function(String? patientName) onSave;
  final bool communityHealthWorker;
  final String initialPatientName;

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen> {
  bool _saving = false;
  bool _saved = false;
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
      SkinXNotice.show(context, 'Enter the patient name to save this screening.', error: true);
      return;
    }
    if (widget.communityHealthWorker && !_permissionConfirmed) {
      SkinXNotice.show(context, 'Confirm permission to save the patient record.', error: true);
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
      if (mounted) SkinXNotice.show(context, 'Could not save the result on this device.', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.result.status;
    final suspicious = status == ScreeningResult.suspicious;
    const ink = Color(0xFF193B38);
    const teal = Color(0xFF14665E);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const SkinXText('Screening result'), backgroundColor: Colors.white,
        foregroundColor: ink),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(suspicious ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  color: suspicious ? const Color(0xFFB96720) : teal, size: 42),
                const SizedBox(height: 16),
                SkinXText(status, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: ink)),
                const SizedBox(height: 16),
                SkinXText(widget.result.message, style: const TextStyle(fontSize: 15, height: 1.6, color: ink)),
                const SizedBox(height: 22),
                const SkinXText('SkinX is a research screening tool, not a diagnosis. Even a less suspicious result cannot rule out skin cancer.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF647D78))),
                const SizedBox(height: 30),
                if (status != ScreeningResult.cannotInfer) ...[
                  if (widget.communityHealthWorker) ...[
                    TextField(
                      controller: _name,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: AppLanguage.text('Patient name'),
                        helperText: AppLanguage.text('Required to save the screening'),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _permissionConfirmed,
                      onChanged: (value) => setState(() => _permissionConfirmed = value ?? false),
                      title: const SkinXText('I have permission to save this person’s name and screening result on this device and in my account when online.',
                        style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(width: double.infinity, child: FilledButton(
                    onPressed: _saving || _saved ? null : _save,
                    style: FilledButton.styleFrom(backgroundColor: teal, minimumSize: const Size.fromHeight(48)),
                    child: SkinXText(_saved ? 'Result saved' : _saving ? 'Saving...' : 'Save result'),
                  )),
                  const SizedBox(height: 8),
                  SkinXText(
                    widget.communityHealthWorker
                        ? 'The patient name, result and date are saved. Signed-in records sync to the account when online. Photos are never uploaded.'
                        : 'Only the result and date are saved, never the photo or a patient name. Signed-in records sync when online; guest records stay on this device.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF647D78), height: 1.5),
                  ),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
