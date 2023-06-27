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
  bool _globalVisible = true;

  int currentPageIndex = 0;

  List<Widget> pages = [
    Container(
      color: Colors.greenAccent,
      child: Center(
        child: SpinningSquare(),
      ),
    ),
    Container(
      color: Colors.yellow,
      child: Center(
        child: SpinningSquare(),
      ),
    ),
    Container(
      color: Colors.orange,
      child: Center(
        child: SpinningSquare(),
      ),
    ),
    Container(
      color: Colors.red,
    ),
    // Add more pages as needed...
  ];

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
          //TODO Figure out when to set state to stop the jank flashing back to previous page
          if (_flipPercentageAnimationController.status ==
              AnimationStatus.dismissed) {
            _flipKey.currentState?.stopFlip();
          }
          if (_flipPercentageAnimationController.status ==
              AnimationStatus.completed) {
            if (currentPageIndex < pages.length - 1) {
              setState(() {
                currentPageIndex++;
                _flipPercentageAnimationController.value = 0;
                _tiltAnimationController.value = 0;
                print("L86");
                print(currentPageIndex);
              });
            }
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
          title: const Text('FlipBook Test'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: Visibility(
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: GestureDetector(
                    child: Stack(
                      children: [
                        if (currentPageIndex < pages.length - 1) ...[
                          Container(
                            child: pages[currentPageIndex + 1],
                          ),
                        ],
                        Container(
                          child: FlipWidget(
                            key: _flipKey,
                            textureSize: Size(constraints.maxWidth * 2,
                                constraints.maxHeight * 2),
                            child: pages[currentPageIndex],
                          ),
                        ),
                        // This page is supposed to be flipped to the max
                        // if (currentPageIndex > 0) ...[
                        //   Container(
                        //     child: pages[currentPageIndex - 1],
                        //   ),
                        // ],
                      ],
                    ),
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
                ),
                visible: _globalVisible,
              )),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 50),
                  // set the max height as you need
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _globalVisible = !_globalVisible;
                      });
                    },
                    child: Text("Toggle"),
                  ),
                ),
              )
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
