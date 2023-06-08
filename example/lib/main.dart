import 'package:flutter/material.dart';

import 'package:multi_flip_widget/multi_flip_widget.dart';
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

  final flipDuration = Duration(milliseconds: 500);


  GlobalKey<MultiFlipWidgetState> _flipKey = GlobalKey();

  Offset _oldPosition = Offset.zero;
  bool _visible = true;


  @override
  void initState() {
    super.initState();

    _tiltAnimationController =
        AnimationController(vsync: this,
            duration: flipDuration,
            lowerBound: -125,
            upperBound: 125);

    _flipPercentageAnimationController = AnimationController(
      vsync: this,
      duration: flipDuration, // adjust the duration as needed
    )
      ..addListener(() {
        _flipKey.currentState?.flip(
            _flipPercentageAnimationController.value, _tiltAnimationController.value);
      });

  }

  @override
  Widget build(BuildContext context) {
    Size size = Size(256, 256);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              child: Center(
                  child: Container(
                    width: size.width,
                    height: size.height,
                    child: GestureDetector(
                      child: Stack(children: [
                        SizedBox(
                          width: size.width,
                          height: size.height,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        MultiFlipWidget(
                          key: _flipKey,
                          textureSize: size * 2,
                          child: Container(
                            color: Colors.blue,
                            child: Center(
                              child: Text("hello"),
                            ),
                          ),
                        ),
                      ]),
                      onHorizontalDragStart: (details) {
                        print("DragStart");
                        _oldPosition = details.globalPosition;
                        _flipKey.currentState?.startFlip();
                      },
                      onHorizontalDragUpdate: (details) {
                        Offset off = details.globalPosition - _oldPosition;
                        double percent = math.max(0, -off.dx / size.width * 1.4);
                        double tilt = 1 / _clampMin((-off.dy + 20) / 100);

                        _tiltAnimationController.value = tilt;
                        _flipPercentageAnimationController.value = percent;
                      },
                      onHorizontalDragEnd: (details) {
                        print("DragEnd");
                        _animateToEndOrBeginning();
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
        ),
      ),
    );
  }

  void _animateToEndOrBeginning() {
    if (_flipPercentageAnimationController.value > 0.5) {
      _flipPercentageAnimationController.forward();
    } else {
      _flipPercentageAnimationController.reverse();
    }
    if(_tiltAnimationController.value > 0){
      _tiltAnimationController.forward();
    }else {
      _tiltAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
    _flipPercentageAnimationController.dispose();
  }
}
