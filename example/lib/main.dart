import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:multi_flip_widget/flip_widget.dart';
import 'package:multi_flip_widget/flip_book.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const double _MinNumber = 0.008;

double _clampMin(double v) {
  if (v < _MinNumber && v > -_MinNumber) {
    if (v >= 0) {
      v = _MinNumber;
    } else {
      v = -_MinNumber;
    }
  }
  return v;
}

class _MyAppState extends State with TickerProviderStateMixin {
  late AnimationController _flipPercentageAnimationController;
  late AnimationController _tiltAnimationController;

  final flipDuration = Duration(milliseconds: 1000);
  double totalDragDistance = 0.0;

  GlobalKey<FlipWidgetState> _flipKey = GlobalKey();

  Offset _oldPosition = Offset.zero;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _tiltAnimationController = AnimationController(
        vsync: this, duration: flipDuration, lowerBound: -125, upperBound: 125);

    _flipPercentageAnimationController = AnimationController(
      vsync: this,
      duration: flipDuration, // adjust the duration as needed
    )
      ..addListener(() {
        _flipKey.currentState?.flip(_flipPercentageAnimationController.value,
            _tiltAnimationController.value);
      })
      ..addListener(() {
        if(_flipKey.currentState?.isFlipping() == true) {
          if (
          // _flipPercentageAnimationController.status ==
          //     AnimationStatus.completed ||
              _flipPercentageAnimationController.status ==
                  AnimationStatus.dismissed) {
            _flipKey.currentState?.stopFlip();
          }
        }
      });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                child: Expanded(
                    child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: GestureDetector(
                    child: Stack(children: [
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      FlipWidget(
                        key: _flipKey,
                        textureSize: Size(constraints.maxWidth * 2,
                            constraints.maxHeight * 2),
                        child: Container(
                          color: Colors.blue,
                          child: Center(
                            child: SpinningSquare(),
                          ),
                        ),
                      ),
                    ]),
                    onHorizontalDragStart: (details) {
                      print("DragStart");
                      totalDragDistance = 0.0;
                      _oldPosition = details.globalPosition;
                      _flipKey.currentState?.startFlip();
                    },
                    onHorizontalDragUpdate: (details) {
                      Offset off = details.globalPosition - _oldPosition;

                      double direction = off.dx.sign;

                      double percentageChangedViaDrag =
                          -off.dx / MediaQuery.of(context).size.width * 1.4;

                      double clampedPercentageChangedViaDrag =
                          clampDouble(percentageChangedViaDrag, 0, 1);

                      late double percent;

                      // Right to left <-
                      percent = lerpDouble(
                              _flipPercentageAnimationController.value,
                              clampedPercentageChangedViaDrag,
                              0.1) ??
                          1.0;
                      // Left to right ->
                      // else {
                      //   percent = lerpDouble(
                      //           1 - clampedPercentageChangedViaDrag,
                      //           _flipPercentageAnimationController.value,
                      //           0.1) ??
                      //       0.0;
                      //   print(_flipPercentageAnimationController.value);
                      //   print(percent);
                      // }

                      double tilt = 1 / _clampMin((-off.dy + 20) / 100);

                      totalDragDistance += off.distance;

                      _tiltAnimationController.value = tilt;
                      _flipPercentageAnimationController.value = percent;
                    },
                    onHorizontalDragEnd: (details) {
                      if (totalDragDistance < 5.0) {
                        // Reset total drag distance
                        totalDragDistance = 0.0;
                        // Don't treat this as a drag end; return instead
                        return;
                      } else {
                        _animateToEndOrBeginning();
                      }
                      _animateTilt();
                    },
                    onHorizontalDragCancel: () {
                      print("DragCancel");
                      _animateToEndOrBeginning();
                    },
                  ),
                )),
                visible: _visible,
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _visible = !_visible;
                    });
                  },
                  child: Text("Toggle")),
            ],
          );
        }),
      ),
    );
  }

  void _animateTilt() {
    print(_tiltAnimationController.value);
    if (_tiltAnimationController.value > 0) {
      _tiltAnimationController.forward();
    } else {
      _tiltAnimationController.reverse();
    }
  }

  void _animateToEndOrBeginning() {
    if (_flipPercentageAnimationController.value > 0.5) {
      _flipPercentageAnimationController.forward();
    } else {
      _flipPercentageAnimationController.reverse();
    }
    // _flipKey.currentState?.stopFlip();
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
    _flipPercentageAnimationController.dispose();
  }
}

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
    )..repeat();
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
          angle: _controller.value * 2.0 * math.pi,
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
