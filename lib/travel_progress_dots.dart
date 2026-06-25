import 'package:flutter/material.dart';

const Color _kMutedGrey = Color(0xFF9A9A9A);

// Collapsed progress indicator: outlined start node, two middle dots that fade
// and widen, and a filled end node.
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
