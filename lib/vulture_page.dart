import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

class VulturePage extends StatefulWidget {
  // final Animation<double> animation;
  final Animation<double> vultureCircleAnimation;
  final AnimationController vultureCircleAnimationController;
  final AnimationController otherAnimationsController;
  final ValueNotifier<bool> dragNotifier;
  const VulturePage({
    super.key,
    // required this.animation,
    required this.vultureCircleAnimationController,
    required this.vultureCircleAnimation,
    required this.otherAnimationsController,
    required this.dragNotifier,
  });

  @override
  State<VulturePage> createState() => _VulturePageState();
}

class _VulturePageState extends State<VulturePage>
    with TickerProviderStateMixin {
  bool showDetails = false;
  final _duration = const Duration(milliseconds: 800);

  late final AnimationController _scaleImageController;
  late final AnimationController _verticalLineAnimationController;
  late final Animation<Offset> slideTowardsLeftAnimation;
  late final Animation<Offset> slideTowardsRightAnimation;
  late final Animation<Offset> scaleImageAnimation;
  late final Animation<double> verticalLineAnimation;
  late final Animation<double> _leftAnimation;

  @override
  void initState() {
    _scaleImageController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _verticalLineAnimationController = AnimationController(
      duration: _duration, // Adjust duration for speed
      vsync: this,
    );
    slideTowardsLeftAnimation =
        Tween<Offset>(
          begin: const Offset(0.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: widget.otherAnimationsController,
            curve: Curves.easeOutQuad,
          ),
        );
    slideTowardsRightAnimation =
        Tween<Offset>(
          begin: const Offset(-0.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: widget.otherAnimationsController,
            curve: Curves.easeOutQuad,
          ),
        );
    verticalLineAnimation = CurvedAnimation(
      parent: _verticalLineAnimationController,
      curve: Curves.easeIn,
    );
    _leftAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _verticalLineAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // onVerticalDragUpdate: (details) {
      onVerticalDragStart: (details) {
        final dragPos = details.globalPosition.dy;
        if (dragPos > deviceHeight * 0.5) {
          // Dragging up
          if (!showDetails) {
            setState(() {
              showDetails = true;
            });
          }

          log('Dragging up -> $dragPos');
          if (widget.vultureCircleAnimation.isForwardOrCompleted) {
            widget.vultureCircleAnimationController.reverse();
          }
          if (!_verticalLineAnimationController.isForwardOrCompleted) {
            _verticalLineAnimationController.forward();
          }
        } else {
          if (showDetails) {
            setState(() {
              showDetails = false;
            });
          }
          log('Dragging down -> $dragPos');
          if (!widget.vultureCircleAnimation.isForwardOrCompleted) {
            widget.vultureCircleAnimationController.forward();
          }
          if (_verticalLineAnimationController.isForwardOrCompleted) {
            _verticalLineAnimationController.reverse();
          }
        }
      },
      child: Stack(
        // alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: deviceWidth * 0.25,
            top: deviceHeight * 0.15,
            child: ScaleTransition(
              scale: widget.vultureCircleAnimation,
              child: Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 174, 173, 173),
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: _duration,
            top: showDetails ? deviceHeight * 0.1 : deviceHeight * 0.1,

            left: showDetails ? -20 : 0,

            child: AnimatedScale(
              scale: showDetails ? 0.9 : 1.0,
              duration: _duration,
              child: Image(
                image: AssetImage('assets/images/vulture_.png'),
                fit: BoxFit.contain,

                width: deviceWidth * 0.8,
                // width: deviceWidth * 0.75,
                alignment: Alignment.center,
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: showDetails ? deviceHeight * 0.7 : 100,
            left: 20,
            right: 20,
            duration: _duration,
            curve: Curves.easeIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SlideTransition(
                  position: slideTowardsLeftAnimation,
                  child: FadeTransition(
                    opacity: widget.otherAnimationsController,
                    child: Text(
                      "Travel details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 60,

            child: SlideTransition(
              position: slideTowardsRightAnimation,
              child: FadeTransition(
                opacity: widget.otherAnimationsController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Start camp",
                      style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "02:40 pm",
                      style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // if (showDetails)
          Positioned(
            bottom: 65,
            left: 0,
            right: 0,
            top: deviceHeight * 0.12,
            child: AnimatedBuilder(
              animation: _verticalLineAnimationController,
              builder: (context, child) {
                if (_verticalLineAnimationController.value != 0) {
                  return child!;
                }
                return SizedBox.shrink();
              },
              child: AnimatedVerticalLine(
                // controller: _verticalLineAnimationController,
                animation: verticalLineAnimation,
              ),
            ),
          ),

          // if (!showDetails)
          Positioned(
            bottom: 65,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _verticalLineAnimationController,
              builder: (context, child) {
                if (_verticalLineAnimationController.value == 0) {
                  return child!;
                }
                return SizedBox.shrink();
              },
              child: TravelProgressDots(
                controller: widget.vultureCircleAnimationController,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Text(
              "72 km",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: showDetails ? deviceHeight * 0.62 : 30,

            right: 50,
            duration: _duration,
            curve: Curves.easeIn,
            child: SlideTransition(
              position: slideTowardsLeftAnimation,
              child: FadeTransition(
                opacity: widget.otherAnimationsController,
                child: Column(
                  children: [
                    Text(
                      "Base camp",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "07:30 am",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TravelProgressDots extends StatefulWidget {
  final AnimationController controller;
  const TravelProgressDots({super.key, required this.controller});

  @override
  State<TravelProgressDots> createState() => _TravelProgressDotsState();
}

class _TravelProgressDotsState extends State<TravelProgressDots> {
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _slideProgress;

  @override
  void initState() {
    super.initState();

    // Dots fade in during first 60% of animation
    _dotsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // White dot slides right across full animation
    _slideProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total width: 10 + 5 + (5+5) + (5+5) + 10 = ~45px collapsed, ~65px expanded
    const double dotSize = 5;
    const double bigDotSize = 10;
    const double gap = 5;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        // Width that the middle dots occupy (slides open)
        final double middleWidth = _slideProgress.value * ((dotSize + gap) * 2);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Outline circle (start)
            Container(
              width: bigDotSize,
              height: bigDotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9A9A9A), width: 1.5),
              ),
            ),
            SizedBox(width: gap),

            // Middle dots — expand in width + fade
            SizedBox(
              width: middleWidth,
              child: Opacity(
                opacity: _dotsOpacity.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    2,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: middleWidth / 4),
                      child: Container(
                        width: middleWidth / 4,
                        height: middleWidth / 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9A9A9A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filled white circle (end) — slides right as middle expands
            Container(
              width: bigDotSize,
              height: bigDotSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedVerticalLine extends StatefulWidget {
  // final AnimationController controller;
  final Animation<double> animation;
  const AnimatedVerticalLine({
    super.key,
    // required this.controller,
    required this.animation,
  });

  @override
  State<AnimatedVerticalLine> createState() => _AnimatedVerticalLineState();
}

class _AnimatedVerticalLineState extends State<AnimatedVerticalLine>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // _controller = widget.controller;

    _animation = widget.animation;
    //  CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeOutCubic,
    // );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedVerticalLine oldWidget) {
    _animation = widget.animation;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          // Define the size of the canvas area for the line
          size: const Size(40, 400),
          painter: LinePainter(progress: _animation.value),
        );
      },
    );
  }
}

class LinePainter extends CustomPainter {
  final double progress; // Ranges from 0.0 to 1.0

  LinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Define coordinates going from bottom to top
    final double startX = size.width / 2;
    final double startY = size.height; // Bottom of the canvas
    final double endY = 0; // Top of the canvas

    // Total distance to travel
    final double totalHeight = startY - endY;

    // Current tip of the line as it moves upwards
    final double currentY = startY - (totalHeight * progress);

    // Draw the main animating line
    canvas.drawLine(
      Offset(startX, startY),
      Offset(startX, currentY),
      linePaint,
    );

    // List of key node positions relative to progress (0.0 at bottom, 1.0 at top)
    // Adjust these percentages to match where you want your nodes to sit
    final List<double> nodeTargets = [0.0, 0.3, 0.6, 1.0];

    for (var target in nodeTargets) {
      // Only draw the node if the line animation has reached or passed it
      if (progress >= target) {
        double nodeY = startY - (totalHeight * target);

        // Custom styling for specific nodes to match your UI
        if (target == 0.0 || target == 1.0) {
          // Hollow circle or specific style for ends
          canvas.drawCircle(Offset(startX, nodeY), 4, dotPaint);
        } else {
          // Inner dot with an outer ring style
          canvas.drawCircle(Offset(startX, nodeY), 4, dotPaint);
          canvas.drawCircle(
            Offset(startX, nodeY),
            6,
            linePaint..strokeWidth = 1.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
