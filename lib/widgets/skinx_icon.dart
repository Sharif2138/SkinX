import 'package:flutter/material.dart';

const _teal = Color(0xFF14665E);

enum SkinXIconType { globe, chevronDown, arrowUpRight, search, heart, chevronRight, play, book, history, scan, chat, account, calendar, folderLock }

class SkinXIcon extends StatelessWidget {
  const SkinXIcon(this.symbol, {required this.size, this.color = _teal});

  final SkinXIconType symbol;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SkinXIconPainter(symbol, color)),
    );
  }
}

class _SkinXIconPainter extends CustomPainter {
  const _SkinXIconPainter(this.symbol, this.color);

  final SkinXIconType symbol;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (symbol) {
      case SkinXIconType.globe:
        canvas.drawCircle(const Offset(12, 12), 8.5, p);
        canvas.drawOval(const Rect.fromLTRB(8, 3.5, 16, 20.5), p);
        canvas.drawLine(const Offset(3.5, 12), const Offset(20.5, 12), p);
        break;
      case SkinXIconType.chevronDown:
        canvas.drawPath(Path()..moveTo(6, 9)..lineTo(12, 15)..lineTo(18, 9), p);
        break;
      case SkinXIconType.arrowUpRight:
        canvas.drawPath(Path()..moveTo(6, 18)..lineTo(18, 6)..moveTo(7, 6)..lineTo(18, 6)..lineTo(18, 17), p);
        break;
      case SkinXIconType.search:
        canvas.drawCircle(const Offset(10.5, 10.5), 6.5, p);
        canvas.drawLine(const Offset(15.3, 15.3), const Offset(20.5, 20.5), p);
        break;
      case SkinXIconType.heart:
        canvas.drawPath(
          Path()..moveTo(12, 20)..lineTo(4.3, 12.4)..cubicTo(-1, 7.1, 6.1, 0.8, 12, 6.6)..cubicTo(17.9, 0.8, 25, 7.1, 19.7, 12.4)..close(),
          p,
        );
        canvas.drawPath(Path()..moveTo(4, 11)..lineTo(8, 11)..lineTo(10, 8)..lineTo(12.5, 14)..lineTo(14.5, 11)..lineTo(20, 11), p);
        break;
      case SkinXIconType.chevronRight:
        canvas.drawPath(Path()..moveTo(9, 6)..lineTo(15, 12)..lineTo(9, 18), p);
        break;
      case SkinXIconType.play:
        canvas.drawPath(Path()..moveTo(8, 5)..lineTo(19, 12)..lineTo(8, 19)..close(), p);
        break;
      case SkinXIconType.book:
        canvas.drawPath(
          Path()..moveTo(12, 5)..cubicTo(9, 3, 5, 3, 2.5, 4)..lineTo(2.5, 19)..cubicTo(6, 18, 9, 18.5, 12, 21)..cubicTo(15, 18.5, 18, 18, 21.5, 19)..lineTo(21.5, 4)..cubicTo(19, 3, 15, 3, 12, 5)..lineTo(12, 21),
          p,
        );
        break;
      case SkinXIconType.history:
        canvas.drawPath(Path()..moveTo(3, 3)..lineTo(3, 8)..lineTo(8, 8), p);
        canvas.drawArc(const Rect.fromLTRB(4, 4, 21, 21), -2.45, 5.55, false, p);
        canvas.drawPath(Path()..moveTo(12.5, 8)..lineTo(12.5, 12.5)..lineTo(16, 14.5), p);
        break;
      case SkinXIconType.scan:
        canvas.drawPath(
          Path()..moveTo(8, 3)..lineTo(5, 3)..quadraticBezierTo(3, 3, 3, 5)..lineTo(3, 8)
            ..moveTo(16, 3)..lineTo(19, 3)..quadraticBezierTo(21, 3, 21, 5)..lineTo(21, 8)
            ..moveTo(21, 16)..lineTo(21, 19)..quadraticBezierTo(21, 21, 19, 21)..lineTo(16, 21)
            ..moveTo(8, 21)..lineTo(5, 21)..quadraticBezierTo(3, 21, 3, 19)..lineTo(3, 16)
            ..moveTo(8, 10)..lineTo(16, 10)..moveTo(8, 14)..lineTo(16, 14),
          p,
        );
        break;
      case SkinXIconType.chat:
        canvas.drawPath(
          Path()..moveTo(6, 19)..cubicTo(4, 17.5, 2.5, 15, 2.5, 12)..cubicTo(2.5, 6.5, 6.5, 3, 12, 3)..cubicTo(17.5, 3, 21.5, 6.5, 21.5, 12)..cubicTo(21.5, 17.5, 17.5, 21, 12, 21)..lineTo(8.5, 20.4)..lineTo(4.5, 22)..close(),
          p,
        );
        break;
      case SkinXIconType.account:
        canvas.drawCircle(const Offset(12, 7), 3.8, p);
        canvas.drawPath(Path()..moveTo(4, 21)..cubicTo(4.7, 16, 7.5, 13, 12, 13)..cubicTo(16.5, 13, 19.3, 16, 20, 21), p);
        break;
      case SkinXIconType.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTRB(4, 5, 20, 21), const Radius.circular(2)),
          p,
        );
        canvas.drawLine(const Offset(8, 3), const Offset(8, 7), p);
        canvas.drawLine(const Offset(16, 3), const Offset(16, 7), p);
        canvas.drawLine(const Offset(4, 10), const Offset(20, 10), p);
        canvas.drawLine(const Offset(8, 14), const Offset(10, 14), p);
        canvas.drawLine(const Offset(14, 14), const Offset(16, 14), p);
        canvas.drawLine(const Offset(8, 17), const Offset(10, 17), p);
        break;
      case SkinXIconType.folderLock:
        canvas.drawPath(
          Path()
            ..moveTo(11, 20)
            ..lineTo(4, 20)
            ..quadraticBezierTo(2, 20, 2, 18)
            ..lineTo(2, 6)
            ..quadraticBezierTo(2, 4, 4, 4)
            ..lineTo(9, 4)
            ..lineTo(12, 7)
            ..lineTo(20, 7)
            ..quadraticBezierTo(22, 7, 22, 9)
            ..lineTo(22, 11),
          p,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTRB(14, 15, 22, 22), const Radius.circular(1.5)),
          p,
        );
        canvas.drawPath(
          Path()..moveTo(16, 15)..lineTo(16, 13)..cubicTo(16, 10, 20, 10, 20, 13)..lineTo(20, 15),
          p,
        );
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkinXIconPainter oldDelegate) {
    return oldDelegate.symbol != symbol || oldDelegate.color != color;
  }
}
