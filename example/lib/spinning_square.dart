
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';


class SpinningSquare extends StatefulWidget {
  @override
  _SpinningSquareState createState() => _SpinningSquareState();
}

class _SpinningSquareState extends State<SpinningSquare>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * pi,
          child: child,
        );
      },
      child: Container(
        width: 100.0,
        height: 100.0,
        color: Colors.green,
      ),
    );
  }
}
