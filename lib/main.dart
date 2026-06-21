import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:travel_app_design/leopard_page.dart';
import 'package:travel_app_design/vulture_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const LeopardPage(),
      home: const AnimatedHorizontalPages(),
    );
  }
}

class AnimatedHorizontalPages extends StatefulWidget {
  const AnimatedHorizontalPages({super.key});

  @override
  State<AnimatedHorizontalPages> createState() =>
      _AnimatedHorizontalPagesState();
}

class _AnimatedHorizontalPagesState extends State<AnimatedHorizontalPages>
    with TickerProviderStateMixin {
  late PageController _pageController;
  bool showOnMapOption = false;
  int _currentPage = 0;
  final _duration = const Duration(milliseconds: 800);
  final _curve = Curves.easeOut;
  late final AnimationController vultureCircleAnimationController;
  late final Animation<double> vultureCircleAnimation;
  late final Animation<Offset> slideTowardsLeftAnimation;
  late final Animation<Offset> slideTowardsRightAnimation;
  bool circleAnimationForwaded = false;

  @override
  void initState() {
    super.initState();
    vultureCircleAnimationController = AnimationController(
      duration: _duration,
      vsync: this,
    );
    vultureCircleAnimation = CurvedAnimation(
      parent: vultureCircleAnimationController,
      curve: _curve,
    );
    slideTowardsLeftAnimation =
        Tween<Offset>(
          begin: const Offset(0.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: vultureCircleAnimationController,
            curve: _curve,
          ),
        );
    slideTowardsRightAnimation =
        Tween<Offset>(
          begin: const Offset(-0.5, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: vultureCircleAnimationController,
            curve: _curve,
          ),
        );
    _pageController = PageController(viewportFraction: 0.9)
      ..addListener(() {
        // if (_pageController.page! >= 0.8 && !circleAnimationForwaded) {
        if (_pageController.page! >= 0.5 && !circleAnimationForwaded) {
          circleAnimationForwaded = true;
          vultureCircleAnimationController.forward();
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262829),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "SY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Icon(Icons.menu, color: Colors.white, size: 24),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                padEnds: _currentPage == 0 ? false : true,
                onPageChanged: (value) => setState(() {
                  _currentPage = value;
                  if (_currentPage == 0) {
                    circleAnimationForwaded = false;
                    vultureCircleAnimationController.reset();
                  }
                }),
                controller: _pageController,
                children: [
                  LeopardPage(),
                  VulturePage(animation: vultureCircleAnimation),
                ],
              ),
            ),

            Container(
              color: const Color(0xFF262829),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentPage == 0)
                    LeopardPageDescription()
                  else
                    VulturePageDescription(
                      slideTowardsLeftAnimation: slideTowardsLeftAnimation,
                      slideTowardsRightAnimation: slideTowardsRightAnimation,
                    ),

                  const SizedBox(height: 20),
                  // Dots + share row
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //onMap
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 60,
                          maxWidth: 60,
                        ),
                        child: _currentPage == 1
                            ? FadeTransition(
                                opacity: vultureCircleAnimation,
                                child: Text(
                                  "ON MAP",
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      67,
                                      73,
                                      166,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Spacer(),
                      // Page dots
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Share
                      const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
