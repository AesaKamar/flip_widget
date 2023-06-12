import 'package:flutter/widgets.dart';
import 'package:multi_flip_widget/flip_widget.dart';

class FlipBook extends StatefulWidget {
  FlipBook({Key? key}) : super(key: key);

  @override
  _FlipBookState createState() => _FlipBookState();
}

class _FlipBookState extends State<FlipBook> {
  // Create keys for each flip widget
  List<GlobalKey<FlipWidgetState>> _flipKeys = List.generate(
    5, // 5 pages
    (index) => GlobalKey(),
  );

  // Current page index
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        double dx = details.delta.dx;
        if (dx < 0) {
          // Flip to the next page if there is one
          if (_currentPage < _flipKeys.length - 1) {
            // Calculate the flip progress
            double progress = dx / context.size!.width;

            // Ensure that progress stays between 0 and 1
            progress = progress.clamp(0.0, 1.0);

            // Start the flip if necessary
            _flipKeys[_currentPage].currentState?.startFlip();

            // Update the flip progress
            _flipKeys[_currentPage].currentState?.flip(progress, 1);
          }
        } else if (dx > 0) {
          // Flip back to the previous page if there is one
          if (_currentPage > 0) {
            double progress = dx / context.size!.width;

            // Ensure that progress stays between 0 and 1
            progress = progress.clamp(0.0, 1.0);

            // Start the flip if necessary
            _flipKeys[_currentPage - 1].currentState?.startFlip();

            // Update the flip progress
            _flipKeys[_currentPage - 1].currentState?.flip(1 - progress, 1);
          }
        }
      },
      onHorizontalDragEnd: (details) {
        // If the drag ends, decide whether to finish the flip based on the velocity
        if (details.velocity.pixelsPerSecond.dx < 0) {
          // If velocity is negative, flip to the next page
          if (_currentPage < _flipKeys.length - 1) {
            _flipKeys[_currentPage].currentState?.flip(1, 1);
            _currentPage++;
          }
        } else {
          // If velocity is positive, flip back to the previous page
          if (_currentPage > 0) {
            _flipKeys[_currentPage - 1].currentState?.flip(0, 1);
            _currentPage--;
          }
        }
      },
      child: Stack(
        children: List.generate(_flipKeys.length, (index) {
          return IgnorePointer(
            ignoring: index != _currentPage,
            child: FlipWidget(
              key: _flipKeys[index],
              child: Container(/* ... page content ... */),
            ),
          );
        }),
      ),
    );
  }
}
