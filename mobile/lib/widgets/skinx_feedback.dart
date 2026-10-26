import 'package:flutter/material.dart';

import '../services/app_language.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);

class SkinXNotice {
  static void show(BuildContext context, String message, {
    bool error = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: error ? 5 : 4),
      backgroundColor: error ? const Color(0xFF693D32) : _ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Row(
        children: [
          Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: Colors.white, size: 21),
          const SizedBox(width: 12),
          Expanded(child: SkinXText(message, style: const TextStyle(
            color: Colors.white, fontSize: 13.5, height: 1.45))),
        ],
      ),
    ));
  }
}

class SkinXDialog extends StatelessWidget {
  const SkinXDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon = Icons.info_outline_rounded,
    this.danger = false,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _teal),
    ),
    child: AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
    contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
    actionsPadding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
    title: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFFEDE6) : const Color(0xFFE8F0E7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: danger ? const Color(0xFF9B4238) : _teal),
      ),
      const SizedBox(width: 12),
      Expanded(child: SkinXText(title, style: const TextStyle(
        fontSize: 18, color: _ink, fontWeight: FontWeight.w700))),
    ]),
    content: DefaultTextStyle.merge(
      style: const TextStyle(color: _ink, fontSize: 14, height: 1.5),
      child: content,
    ),
    actions: actions,
    ),
  );
}
