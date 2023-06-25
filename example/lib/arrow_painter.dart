import 'package:flutter/material.dart';
import 'dart:math';


class DragArrowPainter extends StatefulWidget {
  @override
  _DragArrowPainterState createState() => _DragArrowPainterState();
}

class _DragArrowPainterState extends State<DragArrowPainter> {
  Offset startPoint = Offset.zero;
  Offset currentPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        setState(() {
          startPoint = details.localPosition;
          currentPoint = details.localPosition;
        });
      },
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          currentPoint = details.localPosition;
        });
      },
      child: CustomPaint(
        painter: ArrowPainter(startPoint, currentPoint),
        child: Container(),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;

  ArrowPainter(this.startPoint, this.endPoint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(endPoint.dx, endPoint.dy);

    final arrowSize = 15.0;
    final arrowAngle = pi / 4;
    final angleBetweenPoints = (atan2(
      startPoint.dy - endPoint.dy,
      startPoint.dx - endPoint.dx,
    ));

    final arrowPoint1 = Offset(
      endPoint.dx + arrowSize * cos(angleBetweenPoints - arrowAngle),
      endPoint.dy + arrowSize * sin(angleBetweenPoints - arrowAngle),
    );

    final arrowPoint2 = Offset(
      endPoint.dx + arrowSize * cos(angleBetweenPoints + arrowAngle),
      endPoint.dy + arrowSize * sin(angleBetweenPoints + arrowAngle),
    );

    path
      ..moveTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
