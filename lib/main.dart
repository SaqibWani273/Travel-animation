import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_design/leopard_page.dart';
import 'package:travel_app_design/travel_provider.dart';
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
      home: ChangeNotifierProvider(
        create: (_) => TravelProvider(),
        child: const AnimatedHorizontalPages(),
      ),
    );
  }
}

// Two horizontal hero pages (leopard → vulture). The swipe offset drives the
// reveal controllers below so the next page animates in mid-drag.
class AnimatedHorizontalPages extends StatefulWidget {
  const AnimatedHorizontalPages({super.key});

  @override
  State<AnimatedHorizontalPages> createState() =>
      _AnimatedHorizontalPagesState();
}

class _AnimatedHorizontalPagesState extends State<AnimatedHorizontalPages>
    with TickerProviderStateMixin {
  static const Duration _revealDuration = Duration(milliseconds: 800);

  late final PageController _pageController;

  late final AnimationController _vultureCircleController;
  late final AnimationController _otherAnimationsController;
  late final AnimationController _leopardBgSlideController;
  late final Animation<double> _vultureCircleAnimation;

  bool _circleRevealStarted = false; // one-shot guard per swipe-in
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _vultureCircleController = AnimationController(
      duration: _revealDuration,
      vsync: this,
    );
    _otherAnimationsController = AnimationController(
      duration: _revealDuration,
      vsync: this,
    );
    _leopardBgSlideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _vultureCircleAnimation = CurvedAnimation(
      parent: _vultureCircleController,
      curve: Curves.easeOut,
    );

    _pageController = PageController()..addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    final page = _pageController.page;
    if (page == null) return;

// To start animations in vultures page, we need to wait until the page is
// scrolled 70% into view.
    if (page >= 0.7 && !_circleRevealStarted) {
      _circleRevealStarted = true;
      _vultureCircleController.forward();
      _otherAnimationsController.forward();
    }

    if (page > 0.0 &&
        !_leopardBgSlideController.isAnimating &&
        !_leopardBgSlideController.isForwardOrCompleted) {
      _leopardBgSlideController.repeat(count: 1);
    }
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
    if (index == 0) {
      _circleRevealStarted = false;
      _vultureCircleController.reset();
      _otherAnimationsController.reset();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _vultureCircleController.dispose();
    _otherAnimationsController.dispose();
    _leopardBgSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262829),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(top: 20, left: 0, right: 0, child: TopWidget()),
          Positioned.fill(
            child: PageView(
              key: const PageStorageKey<String>('pageView'),
              padEnds: false,
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              children: [
                LeopardPage(controller: _leopardBgSlideController),
                VulturePage(
                  otherAnimationsController: _otherAnimationsController,
                  vultureCircleAnimationController: _vultureCircleController,
                  vultureCircleAnimation: _vultureCircleAnimation,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: BottomWidget(
              currentPage: _currentPage,
              otherAnimationsController: _otherAnimationsController,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomWidget extends StatelessWidget {
  const BottomWidget({
    super.key,
    required this.currentPage,
    required this.otherAnimationsController,
  });

  final int currentPage;
  final AnimationController otherAnimationsController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentPage == 0) const LeopardPageDescription(),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 60,
                child: currentPage == 1
                    ? FadeTransition(
                        opacity: otherAnimationsController,
                        child: GestureDetector(
                          onTap: () => context.read<TravelProvider>().toggleMap(),
                          child: const Text(
                            "ON MAP",
                            style: TextStyle(
                              color: Color.fromARGB(255, 67, 73, 166),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              const Spacer(),
              const Row(
                children: [
                  _PageDot(active: true),
                  SizedBox(width: 5),
                  _PageDot(active: false),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

class TopWidget extends StatelessWidget {
  const TopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 56),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
    );
  }
}
