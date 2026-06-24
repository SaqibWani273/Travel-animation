import 'package:flutter/material.dart';
const Color _kMutedGrey = Color(0xFF9A9A9A);
/// Animated row of dots shown while the timeline is collapsed: an outlined
/// start node, two middle dots that fade and widen, and a filled end node.
class TravelProgressDots extends StatefulWidget {
  final AnimationController controller;

  const TravelProgressDots({super.key, required this.controller});

  @override
  State<TravelProgressDots> createState() => _TravelProgressDotsState();
}
class _TravelProgressDotsState extends State<TravelProgressDots> {
  static const double _dotSize = 5;
  static const double _bigDotSize = 10;
  static const double _gap = 5;

  late final Animation<double> _dotsOpacity;
  late final Animation<double> _slideProgress;

  @override
  void initState() {
    super.initState();

    // Dots fade in during the first 60% of the animation.
    _dotsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // The middle section widens (and the white dot slides right) across the
    // full animation.
    _slideProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final double middleWidth = _slideProgress.value * (_dotSize + _gap) * 2;
        final double middleDotSize = middleWidth / 4;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // width: middleWidth + _bigDotSize * 2 + _gap,
              width: middleWidth + _bigDotSize + _gap,
              child: Opacity(
                opacity: _dotsOpacity.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildOutlinedDot(),
                    const SizedBox(width: _gap),
                    ...List.generate(
                      2,
                      (_) => Padding(
                        padding: EdgeInsets.only(right: middleDotSize),
                        child: Container(
                          width: middleDotSize,
                          height: middleDotSize,
                          decoration: const BoxDecoration(
                            color: _kMutedGrey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    // _buildFilledDot(),
                  ],
                ),
              ),
            ),
            _buildFilledDot(),
          ],
        );
      },
    );
  }

  Widget _buildOutlinedDot() {
    return Container(
      width: _bigDotSize,
      height: _bigDotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kMutedGrey, width: 1.5),
      ),
    );
  }

  Widget _buildFilledDot() {
    return Container(
      width: _bigDotSize,
      height: _bigDotSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}



/// Paints a bottom-to-top growing line with progress nodes.
class LinePainter extends CustomPainter {
  /// Line growth progress, from 0.0 (collapsed) to 1.0 (fully drawn).
  final double progress;

  const LinePainter({required this.progress});

  /// Node positions along the line (0.0 at bottom, 1.0 at top).
  static const List<double> _nodeTargets = [0.0, 0.3, 0.6, 1.0];
  static const double _nodeRadius = 5;
  static const double _ringRadius = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double startY = size.height; // Bottom of the canvas.
    final double currentY = startY - (startY * progress);

    // Draw the line as it grows from the bottom toward the top.
    canvas.drawLine(
      Offset(centerX, startY),
      Offset(centerX, currentY),
      linePaint,
    );

    for (final target in _nodeTargets) {
      // Reveal a node only once the line has reached it.
      if (progress < target) continue;

      final double nodeY = startY - (startY * target);
      canvas.drawCircle(Offset(centerX, nodeY), _nodeRadius, dotPaint);

      final bool isEndpoint =
          target == _nodeTargets.first || target == _nodeTargets.last;
      if (!isEndpoint) {
        // Intermediate nodes get an outer ring.
        canvas.drawCircle(Offset(centerX, nodeY), _ringRadius, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
