import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:multi_flip_widget/flip_widget.dart';
import 'local_math.dart';
import 'spinning_square.dart';

void main() {
  runApp(FlipBook());
}

class FlipBook extends StatefulWidget {
  @override
  _FlipBookState createState() => _FlipBookState();
}

class _FlipBookState extends State with TickerProviderStateMixin {
  late AnimationController _flipPercentageAnimationController;
  late AnimationController _tiltAnimationController;

  final flipDuration = Duration(milliseconds: 1000);
  double totalDragDistance = 0.0;

  GlobalKey<FlipWidgetState> _flipKey = GlobalKey();

  Offset _dragStartPosition = Offset.zero;
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
        if (_flipKey.currentState?.isFlipping() == true) {
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
                      _dragStartPosition = details.globalPosition;
                      _flipKey.currentState?.startFlip();
                    },
                    onHorizontalDragUpdate: (details) {
                      Offset off = details.globalPosition - _dragStartPosition;

                      double percentageChangedViaDrag =
                          -off.dx / MediaQuery.of(context).size.width * 1.4;

                      double clampedPercentageChangedViaDrag =
                          mapNumber(percentageChangedViaDrag, -1, 1, 0, 1);

                      late double percent = lerpDouble(
                              _flipPercentageAnimationController.value,
                              clampedPercentageChangedViaDrag,
                              0.1) ??
                          1.0;

                      double tilt = 1 / clampMin((-off.dy + 20) / 100);

                      totalDragDistance += off.distance;

                      _tiltAnimationController.value = tilt;
                      _flipPercentageAnimationController.value = percent;
                    },
                    onHorizontalDragEnd: (details) {
                      print("DragEnd");

                      _animateToEndOrBeginning();
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
