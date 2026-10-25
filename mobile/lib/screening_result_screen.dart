import 'package:flutter/material.dart';
import 'models/screening_result.dart';

class ScreeningResultScreen extends StatefulWidget {
  const ScreeningResultScreen({super.key, required this.result, required this.onSave});
  final ScreeningResult result;
  final Future<void> Function() onSave;

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen> {
  bool _saving = false;
  bool _saved = false;
  Future<void> _save() async {
    if (_saving || _saved) return;
    setState(() => _saving = true);
    try {
      await widget.onSave();
      if (mounted) setState(() => _saved = true);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save the result on this device.')));
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
      appBar: AppBar(title: const Text('Screening result'), backgroundColor: Colors.white,
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
                Text(status, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: ink)),
                const SizedBox(height: 16),
                Text(widget.result.message, style: const TextStyle(fontSize: 15, height: 1.6, color: ink)),
                const SizedBox(height: 22),
                const Text('SkinX is a research screening tool, not a diagnosis. Even a less suspicious result cannot rule out skin cancer.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF647D78))),
                const SizedBox(height: 30),
                if (status != ScreeningResult.cannotInfer) ...[
                  SizedBox(width: double.infinity, child: FilledButton(
                    onPressed: _saving || _saved ? null : _save,
                    style: FilledButton.styleFrom(backgroundColor: teal, minimumSize: const Size.fromHeight(48)),
                    child: Text(_saved ? 'Saved on this device' : _saving ? 'Saving...' : 'Save anonymous result locally'),
                  )),
                  const SizedBox(height: 8),
                  const Text('Optional: saves only the result and date. No photo or patient name is saved. Local records are not encrypted; avoid shared devices.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF647D78), height: 1.5)),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
