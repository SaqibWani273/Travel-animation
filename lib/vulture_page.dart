import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_design/curved_route_line.dart';
import 'package:travel_app_design/travel_progress_dots.dart';
import 'package:travel_app_design/travel_provider.dart';

const Duration _kAnimationDuration = Duration(milliseconds: 800);
const Duration _kMorphDuration = Duration(milliseconds: 1100);

const Color _kMutedGrey = Color(0xFF9A9A9A);
const Color _kCircleColor = Color.fromARGB(255, 183, 183, 183);

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
const TextStyle _kAnimalLabelStyle = TextStyle(
  color: Colors.white,
  fontSize: 13,
);

// Lines a tag's connector dash up with its timeline node.
const double _kTagAnchorOffset = 40;
const double _kTagLineGap = 98;
const double _kTagSlideIn = 0.2;

class VulturePage extends StatefulWidget {
  final Animation<double> vultureCircleAnimation;
  final AnimationController vultureCircleAnimationController;
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
    with TickerProviderStateMixin {
  bool _showDetails = false;

  // Last seen map state, so the morph only fires on an actual toggle.
  bool _isOnMap = false;

  late final AnimationController _verticalLineController;
  late final AnimationController _revealController;
  late final AnimationController _morphController;

  late final Animation<double> _verticalLineAnimation;
  late final Animation<double> _morphAnimation;
  late final Animation<double> _mapFadeOut;
  late final Animation<Offset> _slideInFromRight;
  late final Animation<Offset> _slideInFromLeft;
  late final Animation<double> _leopardReveal;
  late final Animation<double> _vultureReveal;
  late final Animation<double> _overlayReveal;

  @override
  void initState() {
    super.initState();

    _verticalLineController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _revealController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _morphController = AnimationController(
      vsync: this,
      duration: _kMorphDuration,
    );
    _verticalLineAnimation = CurvedAnimation(
      parent: _verticalLineController,
      curve: Curves.easeIn,
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    );
    _mapFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(_morphAnimation);

    _overlayReveal = CurvedAnimation(
      parent: _verticalLineController,
      curve: Curves.easeIn,
    );
    _vultureReveal = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeIn,
    );
    _leopardReveal = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeIn,
    );

    _slideInFromRight =
        Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: widget.otherAnimationsController,
            curve: Curves.easeInQuad,
          ),
        );
    _slideInFromLeft =
        Tween<Offset>(begin: const Offset(-0.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: widget.otherAnimationsController,
            curve: Curves.easeInQuad,
          ),
        );

    // Reveal the tags once the line is half-drawn.
    _verticalLineController.addListener(() {
      if (_verticalLineController.value >= 0.5 &&
          _revealController.value == 0.0) {
        _revealController.forward();
      } else if (_verticalLineController.value <= 0.5 &&
          _revealController.value == 1.0) {
        _revealController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _verticalLineController.dispose();
    _revealController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _syncMapMorph(bool onMap) {
    if (onMap == _isOnMap) return;
    _isOnMap = onMap;
    if (onMap) {
      _morphController.forward();
    } else {
      _morphController.reverse();
    }
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    final deviceHeight = MediaQuery.of(context).size.height;
    // Origin half picks the target: lower = reveal details, upper = collapse.
    _setDetailsVisible(details.globalPosition.dy > deviceHeight / 2);
  }

  void _setDetailsVisible(bool visible) {
    if (visible) {
      // Collapse the circle first, then grow the timeline in behind it.
      if (widget.vultureCircleAnimation.isForwardOrCompleted) {
        widget.vultureCircleAnimationController.reverse().then((_) {
          _verticalLineController.forward();
          if (_showDetails != visible) {
            setState(() => _showDetails = visible);
          }
        });
      }
    } else {
      // Retract the timeline, then scale the circle back in.
      if (_showDetails != visible) {
        setState(() => _showDetails = visible);
      }

      if (_verticalLineController.isForwardOrCompleted) {
        _verticalLineController.reverse().then(
          (_) => widget.vultureCircleAnimationController.forward(),
        );
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
      child: Consumer<TravelProvider>(
        builder: (context, value, child) {
          _syncMapMorph(value.showMap);
          return Stack(
            children: [
              _buildCircleBackdrop(deviceWidth, deviceHeight),
              _buildVultureImage(deviceWidth, deviceHeight),
              _buildMapImage(value.showMap),
              _buildDarkOverlay(value.showMap),
              _buildTravelDetailsBar(deviceHeight),
              _buildStartCampInfo(deviceHeight),
              _buildVerticalTimeline(deviceHeight),
              _buildAnimalTags(deviceHeight),
              _buildProgressDots(deviceHeight),
              _buildDistanceLabel(deviceHeight),
              _buildBaseCampInfo(deviceHeight),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleBackdrop(double width, double height) {
    return Positioned(
      left: width * 0.25,
      top: height * 0.16,
      child: ScaleTransition(
        scale: widget.vultureCircleAnimation,
        child: Container(
          height: 240,
          width: 240,
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
      top: height * 0.15,
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

  Widget _buildMapImage(bool showMap) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: showMap ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1800),
        curve: Curves.easeInOut,
        child: Image.asset(fit: BoxFit.cover, 'assets/images/sanctuary.png'),
      ),
    );
  }

  Widget _buildDarkOverlay(bool onMap) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _verticalLineController,
          builder: (context, child) => _verticalLineController.value <= 0.3
              ? const SizedBox.shrink()
              : child!,
          child: FadeTransition(
            opacity: _overlayReveal,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: const Color.fromARGB(153, 57, 57, 57),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fades a label out (instead of unmounting) so it dissolves with the morph,
  // and stops it eating drag gestures once the map is up.
  Widget _fadeOutOnMap({required Widget child}) {
    return IgnorePointer(
      ignoring: _isOnMap,
      child: FadeTransition(opacity: _mapFadeOut, child: child),
    );
  }

  Widget _buildTravelDetailsBar(double height) {
    return AnimatedPositioned(
      duration: _kAnimationDuration,
      curve: Curves.easeIn,
      bottom: _showDetails ? height * 0.7 : height * 0.2,
      left: 20,
      right: 20,
      child: _fadeOutOnMap(
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
      ),
    );
  }

  Widget _buildStartCampInfo(double height) {
    return Positioned(
      bottom: height * 0.1,
      left: 60,
      child: _fadeOutOnMap(
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
      ),
    );
  }

  Widget _buildVerticalTimeline(double height) {
    return Positioned(
      top: height * 0.12,
      bottom: height * 0.14,
      left: 0,
      right: -15,
      child: AnimatedBuilder(
        animation: _verticalLineController,
        // Only mount once the line starts drawing.
        builder: (context, child) => _verticalLineController.value != 0
            ? child!
            : const SizedBox.shrink(),
        child: AnimatedMorphingRouteLine(
          drawOn: _verticalLineAnimation,
          morph: _morphAnimation,
        ),
      ),
    );
  }

  Widget _buildAnimalTags(double height) {
    return Positioned(
      top: height * 0.12,
      bottom: 65,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _verticalLineController,
        builder: (context, child) => _verticalLineController.value == 0.0
            ? const SizedBox.shrink()
            : child!,
        // Hand off to the route's painted captions as the line curves.
        child: FadeTransition(
          opacity: _mapFadeOut,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double centerX = constraints.maxWidth / 2;
              // Node Y measured from the bottom: y = height * (1 - fraction).
              final double leopardNodeY = constraints.maxHeight * (1 - 0.6);
              final double vultureNodeY = constraints.maxHeight * (1 - 0.3);

              return Stack(
                children: [
                  Positioned(
                    top: leopardNodeY - _kTagAnchorOffset,
                    right: centerX + _kTagLineGap,
                    child: _buildRevealable(
                      reveal: _leopardReveal,
                      leftSide: true,
                      child: _animalTag(
                        icon: Icons.pets,
                        label: "Leopards",
                        leftSide: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: vultureNodeY - _kTagAnchorOffset,
                    left: centerX + _kTagLineGap,
                    child: _buildRevealable(
                      reveal: _vultureReveal,
                      leftSide: false,
                      child: _animalTag(
                        icon: Icons.flutter_dash,
                        label: "Vultures",
                        leftSide: false,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Fades + slides [child] in from its nearer screen edge.
  Widget _buildRevealable({
    required Animation<double> reveal,
    required bool leftSide,
    required Widget child,
  }) {
    final slide = Tween<Offset>(
      begin: Offset(leftSide ? -_kTagSlideIn : _kTagSlideIn, 0),
      end: Offset.zero,
    ).animate(reveal);
    return FadeTransition(
      opacity: reveal,
      child: SlideTransition(position: slide, child: child),
    );
  }

  Widget _animalTag({
    required IconData icon,
    required String label,
    required bool leftSide,
  }) {
    final dash = Container(width: 18, height: 1.5, color: _kMutedGrey);
    final text = Text(label, style: _kAnimalLabelStyle);
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: leftSide
          ? [text, const SizedBox(width: 10), dash]
          : [dash, const SizedBox(width: 10), text],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: leftSide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        labelRow,
      ],
    );
  }

  Widget _buildProgressDots(double height) {
    return Positioned(
      bottom: height * 0.135,
      left: 0,
      right: 0,
      child: TravelProgressDots(
        controller: widget.vultureCircleAnimationController,
      ),
    );
  }

  Widget _buildDistanceLabel(double height) {
    return Positioned(
      bottom: height * 0.09,
      left: 0,
      right: 0,
      child: Text("72 km", textAlign: TextAlign.center, style: _kDistanceStyle),
    );
  }

  Widget _buildBaseCampInfo(double height) {
    return AnimatedPositioned(
      duration: _kAnimationDuration,
      curve: Curves.easeIn,
      bottom: _showDetails ? height * 0.62 : height * 0.1,
      right: 50,
      child: _fadeOutOnMap(
        child: SlideTransition(
          position: _slideInFromRight,
          child: FadeTransition(
            opacity: widget.otherAnimationsController,
            child: Column(
              children: const [
                Text(
                  "Base camp",
                  textAlign: TextAlign.end,
                  style: _kCampInfoStyle,
                ),
                SizedBox(height: 12),
                Text(
                  "07:30 am",
                  textAlign: TextAlign.end,
                  style: _kCampInfoStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
