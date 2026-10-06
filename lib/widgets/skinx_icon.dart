import 'package:flutter/material.dart';

const _teal = Color(0xFF14665E);

enum SkinXIconType { globe, chevronDown, arrowUpRight, search, heart, chevronRight, play, book, history, scan, chat, account, calendar, folderLock, camera, upload, info, checkCircle, image, expand, arrowUp, externalLink, eye, eyeOff, shieldCheck, signOut }

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
      case SkinXIconType.camera:
        canvas.drawPath(
          Path()
            ..moveTo(8, 5)
            ..lineTo(9.5, 3)
            ..lineTo(14.5, 3)
            ..lineTo(16, 5)
            ..lineTo(20, 5)
            ..quadraticBezierTo(22, 5, 22, 7)
            ..lineTo(22, 19)
            ..quadraticBezierTo(22, 21, 20, 21)
            ..lineTo(4, 21)
            ..quadraticBezierTo(2, 21, 2, 19)
            ..lineTo(2, 7)
            ..quadraticBezierTo(2, 5, 4, 5)
            ..close(),
          p,
        );
        canvas.drawCircle(const Offset(12, 13), 4, p);
        break;
      case SkinXIconType.upload:
        canvas.drawPath(
          Path()
            ..moveTo(12, 15)
            ..lineTo(12, 3)
            ..moveTo(7, 8)
            ..lineTo(12, 3)
            ..lineTo(17, 8)
            ..moveTo(4, 15)
            ..lineTo(4, 21)
            ..lineTo(20, 21)
            ..lineTo(20, 15),
          p,
        );
        break;
      case SkinXIconType.info:
        canvas.drawCircle(const Offset(12, 12), 9, p);
        canvas.drawCircle(const Offset(12, 7.5), 1, Paint()..color = color);
        canvas.drawLine(const Offset(12, 11), const Offset(12, 17), p);
        break;
      case SkinXIconType.checkCircle:
        canvas.drawCircle(const Offset(12, 12), 9, p);
        canvas.drawPath(Path()..moveTo(7.5, 12)..lineTo(10.5, 15)..lineTo(16.5, 9), p);
        break;
      case SkinXIconType.image:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTRB(3, 3, 21, 21), const Radius.circular(2)),
          p,
        );
        canvas.drawCircle(const Offset(8, 8), 1.5, p);
        canvas.drawPath(
          Path()..moveTo(4, 19)..lineTo(10, 13)..lineTo(13, 16)..lineTo(17, 11)..lineTo(21, 15),
          p,
        );
        break;
      case SkinXIconType.expand:
        canvas.drawPath(
          Path()
            ..moveTo(9, 3)..lineTo(3, 3)..lineTo(3, 9)
            ..moveTo(3, 3)..lineTo(9, 9)
            ..moveTo(15, 3)..lineTo(21, 3)..lineTo(21, 9)
            ..moveTo(21, 3)..lineTo(15, 9)
            ..moveTo(21, 15)..lineTo(21, 21)..lineTo(15, 21)
            ..moveTo(21, 21)..lineTo(15, 15)
            ..moveTo(9, 21)..lineTo(3, 21)..lineTo(3, 15)
            ..moveTo(3, 21)..lineTo(9, 15),
          p,
        );
        break;
      case SkinXIconType.arrowUp:
        canvas.drawPath(
          Path()..moveTo(12, 20)..lineTo(12, 4)..moveTo(5, 11)..lineTo(12, 4)..lineTo(19, 11),
          p,
        );
        break;
      case SkinXIconType.externalLink:
        canvas.drawPath(
          Path()
            ..moveTo(11, 5)
            ..lineTo(5, 5)
            ..quadraticBezierTo(3, 5, 3, 7)
            ..lineTo(3, 19)
            ..quadraticBezierTo(3, 21, 5, 21)
            ..lineTo(17, 21)
            ..quadraticBezierTo(19, 21, 19, 19)
            ..lineTo(19, 13)
            ..moveTo(13, 3)
            ..lineTo(21, 3)
            ..lineTo(21, 11)
            ..moveTo(21, 3)
            ..lineTo(10, 14),
          p,
        );
        break;
      case SkinXIconType.eye:
      case SkinXIconType.eyeOff:
        canvas.drawPath(
          Path()..moveTo(2.5, 12)..cubicTo(6.5, 3, 17.5, 3, 21.5, 12)..cubicTo(17.5, 21, 6.5, 21, 2.5, 12)..close(),
          p,
        );
        canvas.drawCircle(const Offset(12, 12), 3.2, p);
        if (symbol == SkinXIconType.eyeOff) {
          canvas.drawLine(const Offset(3, 3), const Offset(21, 21), p);
        }
        break;
      case SkinXIconType.shieldCheck:
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..lineTo(20, 6)
            ..lineTo(20, 12)
            ..cubicTo(19.5, 18, 15.5, 21, 12, 22)
            ..cubicTo(8.5, 21, 4.5, 18, 4, 12)
            ..lineTo(4, 6)
            ..close(),
          p,
        );
        canvas.drawPath(Path()..moveTo(8, 12)..lineTo(11, 15)..lineTo(16, 10), p);
        break;
      case SkinXIconType.signOut:
        canvas.drawPath(
          Path()
            ..moveTo(11, 3)
            ..lineTo(5, 3)
            ..quadraticBezierTo(3, 3, 3, 5)
            ..lineTo(3, 19)
            ..quadraticBezierTo(3, 21, 5, 21)
            ..lineTo(11, 21)
            ..moveTo(10, 12)
            ..lineTo(21, 12)
            ..moveTo(16, 7)
            ..lineTo(21, 12)
            ..lineTo(16, 17),
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
