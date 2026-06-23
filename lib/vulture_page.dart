import 'package:flutter/material.dart';

/// Shared animation timing for the vulture screen widgets.
const Duration _kAnimationDuration = Duration(milliseconds: 800);

/// Palette used across the vulture screen.
const Color _kMutedGrey = Color(0xFF9A9A9A);
const Color _kCircleColor = Color.fromARGB(255, 174, 173, 173);

const TextStyle _kSectionTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
const TextStyle _kCampInfoStyle = TextStyle(color: _kMutedGrey, fontSize: 13);
const TextStyle _kDistanceStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);

/// Second page of the horizontal pager.
///
/// Reacts to a vertical drag by toggling a "details" layout: the hero image
/// scales/slides aside, the circle backdrop collapses, and a vertical timeline
/// replaces the collapsed progress dots.
class VulturePage extends StatefulWidget {
  /// Drives the circular backdrop scale (and is reused for fade transitions).
  final Animation<double> vultureCircleAnimation;

  /// Controller backing [vultureCircleAnimation]; owned by the parent.
  final AnimationController vultureCircleAnimationController;

  /// Drives the slide + fade of the supporting labels; owned by the parent.
  final AnimationController otherAnimationsController;

  const VulturePage({
    super.key,
    required this.vultureCircleAnimationController,
    required this.vultureCircleAnimation,
    required this.otherAnimationsController,
  });

  @override
  State<VulturePage> createState() => _VulturePageState();
}

class _VulturePageState extends State<VulturePage>
    with SingleTickerProviderStateMixin {
  /// Whether the expanded "details" layout is shown.
  bool _showDetails = false;

  late final AnimationController _verticalLineController;
  late final Animation<double> _verticalLineAnimation;

  /// Labels that slide in from the right edge.
  late final Animation<Offset> _slideInFromRight;

  /// Labels that slide in from the left edge.
  late final Animation<Offset> _slideInFromLeft;

  @override
  void initState() {
    super.initState();

    _verticalLineController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _verticalLineAnimation = CurvedAnimation(
      parent: _verticalLineController,
      curve: Curves.easeIn,
    );

    _slideInFromRight = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.otherAnimationsController,
        curve: Curves.easeOutQuad,
      ),
    );
    _slideInFromLeft = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.otherAnimationsController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _verticalLineController.dispose();
    super.dispose();
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    final deviceHeight = MediaQuery.of(context).size.height;
    // The gesture origin (not its direction) decides the target layout, matching
    // the original interaction: start the drag in the lower half to reveal the
    // details view, in the upper half to collapse it.
    _setDetailsVisible(details.globalPosition.dy > deviceHeight / 2);
  }

  void _setDetailsVisible(bool visible) {
    if (_showDetails != visible) {
      setState(() => _showDetails = visible);
    }

    if (visible) {
      if (widget.vultureCircleAnimation.isForwardOrCompleted) {
        widget.vultureCircleAnimationController.reverse();
      }
      if (!_verticalLineController.isForwardOrCompleted) {
        _verticalLineController.forward();
      }
    } else {
      if (!widget.vultureCircleAnimation.isForwardOrCompleted) {
        widget.vultureCircleAnimationController.forward();
      }
      if (_verticalLineController.isForwardOrCompleted) {
        _verticalLineController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceWidth = size.width;
    final deviceHeight = size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _handleVerticalDragStart,
      child: Stack(
        children: [
          _buildCircleBackdrop(deviceWidth, deviceHeight),
          _buildVultureImage(deviceWidth, deviceHeight),
          _buildTravelDetailsBar(deviceHeight),
          _buildStartCampInfo(),
          _buildVerticalTimeline(deviceHeight),
          _buildProgressDots(),
          _buildDistanceLabel(),
          _buildBaseCampInfo(deviceHeight),
        ],
      ),
    );
  }

  Widget _buildCircleBackdrop(double width, double height) {
    return Positioned(
      left: width * 0.25,
      top: height * 0.15,
      child: ScaleTransition(
        scale: widget.vultureCircleAnimation,
        child: Container(
          height: 220,
          width: 220,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kCircleColor,
          ),
        ),
      ),
    );
  }

  Widget _buildVultureImage(double width, double height) {
    return AnimatedPositioned(
      duration: _kAnimationDuration,
      top: height * 0.1,
      left: _showDetails ? -20 : 0,
      child: AnimatedScale(
        scale: _showDetails ? 0.9 : 1.0,
        duration: _kAnimationDuration,
        child: Image.asset(
          'assets/images/vulture_.png',
          fit: BoxFit.contain,
          width: width * 0.8,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildTravelDetailsBar(double height) {
    return AnimatedPositioned(
      duration: _kAnimationDuration,
      curve: Curves.easeIn,
      bottom: _showDetails ? height * 0.7 : 100,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SlideTransition(
            position: _slideInFromRight,
            child: FadeTransition(
              opacity: widget.otherAnimationsController,
              child: const Text("Travel details", style: _kSectionTitleStyle),
            ),
          ),
          const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildStartCampInfo() {
    return Positioned(
      bottom: 30,
      left: 60,
      child: SlideTransition(
        position: _slideInFromLeft,
        child: FadeTransition(
          opacity: widget.otherAnimationsController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("Start camp", style: _kCampInfoStyle),
              SizedBox(height: 12),
              Text("02:40 pm", style: _kCampInfoStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalTimeline(double height) {
    return Positioned(
      top: height * 0.12,
      bottom: 65,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _verticalLineController,
        // Only mount the timeline once the line animation has started.
        builder: (context, child) => _verticalLineController.value != 0
            ? child!
            : const SizedBox.shrink(),
        child: AnimatedVerticalLine(animation: _verticalLineAnimation),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Positioned(
      bottom: 65,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _verticalLineController,
        // Collapsed dots show only while the timeline is fully retracted.
        builder: (context, child) => _verticalLineController.value == 0
            ? child!
            : const SizedBox.shrink(),
        child: TravelProgressDots(
          controller: widget.vultureCircleAnimationController,
        ),
      ),
    );
  }

  Widget _buildDistanceLabel() {
    return const Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Text("72 km", textAlign: TextAlign.center, style: _kDistanceStyle),
    );
  }

  Widget _buildBaseCampInfo(double height) {
    return AnimatedPositioned(
      duration: _kAnimationDuration,
      curve: Curves.easeIn,
      bottom: _showDetails ? height * 0.62 : 30,
      right: 50,
      child: SlideTransition(
        position: _slideInFromRight,
        child: FadeTransition(
          opacity: widget.otherAnimationsController,
          child: Column(
            children: const [
              Text("Base camp", textAlign: TextAlign.end, style: _kCampInfoStyle),
              SizedBox(height: 12),
              Text("07:30 am", textAlign: TextAlign.end, style: _kCampInfoStyle),
            ],
          ),
        ),
      ),
    );
  }
}

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
            _buildOutlinedDot(),
            const SizedBox(width: _gap),
            SizedBox(
              width: middleWidth,
              child: Opacity(
                opacity: _dotsOpacity.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
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

/// Vertical timeline whose line grows upward and reveals nodes as it passes
/// them, driven by [animation].
class AnimatedVerticalLine extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedVerticalLine({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        size: const Size(40, 400),
        painter: LinePainter(progress: animation.value),
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
  static const double _nodeRadius = 4;
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
