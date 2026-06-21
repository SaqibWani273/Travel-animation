import 'dart:developer';

import 'package:flutter/material.dart';

class VulturePage extends StatelessWidget {
  final Animation<double> animation;
  const VulturePage({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Stack(
      // alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: deviceWidth * 0.25,
          top: deviceHeight * 0.15,
          child: ScaleTransition(
            scale: animation,
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
        Positioned(
          top: deviceHeight * 0.089,
          left: 0,
          // right: 0,
          child: Image(
            image: AssetImage('assets/images/vulture_.png'),
            fit: BoxFit.contain,

            width: deviceWidth * 0.8,
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }
}

class VulturePageDescription extends StatefulWidget {
  final Animation<Offset> slideTowardsLeftAnimation;
  final Animation<Offset> slideTowardsRightAnimation;
  const VulturePageDescription({
    super.key,
    required this.slideTowardsLeftAnimation,
    required this.slideTowardsRightAnimation,
  });

  @override
  State<VulturePageDescription> createState() => _VulturePageDescriptionState();
}

class _VulturePageDescriptionState extends State<VulturePageDescription>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 4.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlideTransition(
                position: widget.slideTowardsLeftAnimation,
                child: Text(
                  "Travel details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SlideTransition(
                  position: widget.slideTowardsRightAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Start camp",
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "02:40 pm",
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progress dots
                    TravelProgressDots(controller: _controller),

                    SizedBox(height: 16),
                    Text(
                      "72 km",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SlideTransition(
                  position: widget.slideTowardsLeftAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Base camp",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "07:30 am",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        log(" middleWidth: $middleWidth");
        return Row(
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
