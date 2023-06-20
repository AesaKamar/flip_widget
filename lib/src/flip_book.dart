import 'package:flutter/widgets.dart';

class FlipBook extends StatefulWidget {
  final List<Widget> children;

  const FlipBook({Key? key, required this.children}) : super(key: key);

  @override
  FlipBookState createState() => FlipBookState();
}

class FlipBookState extends State<FlipBook> {
  int _currentIndex = 0;

  void _goToNextPage() {
    if (_currentIndex < widget.children.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 0) {
          _goToPreviousPage();
        } else if (details.velocity.pixelsPerSecond.dx < 0) {
          _goToNextPage();
        }
      },
      child: Stack(
        children: [
          if (_currentIndex > 0)
            Positioned.fill(
              child: widget.children[_currentIndex - 1],
            ),
          Positioned.fill(
            child: widget.children[_currentIndex],
          ),
          if (_currentIndex < widget.children.length - 1)
            Positioned.fill(
              child: widget.children[_currentIndex + 1],
            ),
        ],
      ),
    );
  }
}
