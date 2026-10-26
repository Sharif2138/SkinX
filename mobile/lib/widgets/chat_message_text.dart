import 'package:flutter/material.dart';

class ChatMessageText extends StatelessWidget {
  const ChatMessageText(this.message, {super.key});

  final String message;

  static const _ink = Color(0xFF193B38);

  @override
  Widget build(BuildContext context) {
    final lines = message.replaceAll('\r\n', '\n').trim().split('\n');
    final blocks = <Widget>[];

    for (final line in lines) {
      final value = line.trim();
      if (value.isEmpty || RegExp(r'^[-*_]{3,}$').hasMatch(value)) {
        if (blocks.isNotEmpty && value.isEmpty) {
          blocks.add(const SizedBox(height: 6));
        }
        continue;
      }

      final heading = RegExp(r'^#{1,6}\s+').hasMatch(value);
      final bullet = RegExp(r'^[-*]\s+').hasMatch(value);
      final number = RegExp(r'^\d+[.)]\s+').firstMatch(value);
      final body = value.replaceFirst(RegExp(r'^#{1,6}\s+'), '')
          .replaceFirst(RegExp(r'^[-*]\s+'), '')
          .replaceFirst(RegExp(r'^\d+[.)]\s+'), '');
      final paragraph = Text.rich(
        TextSpan(children: _inline(body), style: TextStyle(
          color: _ink, fontSize: 14, height: 1.55,
          fontWeight: heading ? FontWeight.w700 : FontWeight.w400,
        )),
      );

      if (bullet || number != null) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 22, child: Text(number?.group(0)?.trim() ?? '•',
              style: const TextStyle(fontSize: 14, color: _ink, height: 1.55))),
            Expanded(child: paragraph),
          ]),
        ));
      } else {
        blocks.add(Padding(
          padding: EdgeInsets.only(bottom: heading ? 5 : 3),
          child: paragraph,
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  List<InlineSpan> _inline(String input) {
    final spans = <InlineSpan>[];
    final token = RegExp(r'\*\*(.+?)\*\*|__(.+?)__|\*([^*]+)\*|`([^`]+)`');
    var offset = 0;
    for (final match in token.allMatches(input)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: input.substring(offset, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1) ?? match.group(2) ?? match.group(3) ?? match.group(4),
        style: TextStyle(
          fontWeight: match.group(4) == null ? FontWeight.w700 : FontWeight.w500,
        ),
      ));
      offset = match.end;
    }
    if (offset < input.length) spans.add(TextSpan(text: input.substring(offset)));
    return spans;
  }
}
