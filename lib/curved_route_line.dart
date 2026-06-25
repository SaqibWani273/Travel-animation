import 'package:flutter/material.dart';

// /// Palette for the trek route overlay.
const Color _kRouteColor = Colors.white;
const Color _kRingFill = Color(0x55000000);
const Color _kRouteShadow = Color(0x66000000);

const TextStyle _kRouteLabelStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.2,
);

// /// A stop along the route that carries a node + caption.
class _RouteNode {
  const _RouteNode({
    required this.point,
    required this.label,
    this.side = _LabelSide.right,
    this.filled = false,
    this.icon,
    this.straightReveal = 0.0,
  });

  /// Index into [_kRoutePoints] where this node sits.
  final int point;
  final String label;
  final _LabelSide side;

  /// Filled white dot (camps) vs. outlined ring (wildlife sightings).
  final bool filled;

  /// Optional glyph drawn above the node (e.g. the leopard icon).
  final IconData? icon;

  /// Progress (0..1) at which this node is revealed while the line is still a
  /// straight vertical timeline; matches the collapsed-timeline node heights.
  /// The reveal point slides toward the route's arc-length fraction as the line
  /// bends (see [_MorphingRoutePainter]).
  final double straightReveal;
}

enum _LabelSide { left, right }

// /// Route control points, ordered from the bottom (start) to the top (end).
// /// Traced from the reference image; intermediate points (no node) only shape
// /// the switchbacks and bulges of the trail.
const List<Offset> _kRoutePoints = [
  Offset(0.497, 0.999), // 0  Start camp
  Offset(0.445, 0.898),
  Offset(0.322, 0.852),
  Offset(0.356, 0.815),
  Offset(0.432, 0.784),
  Offset(0.522, 0.746),
  Offset(0.624, 0.708),
  Offset(0.735, 0.664), // 7  Vultures
  Offset(0.712, 0.572),
  Offset(0.766, 0.474),
  Offset(0.786, 0.376), // 10 Leopards
  Offset(0.802, 0.262),
  Offset(0.744, 0.150),
  Offset(0.684, 0.064), // 13 Base camp
];

const List<_RouteNode> _kRouteNodes = [
  _RouteNode(point: 0, label: 'Start camp', filled: true, straightReveal: 0.0),
  _RouteNode(point: 7, label: 'Vultures', straightReveal: 0.3),
  _RouteNode(
    point: 10,
    label: 'Leopards',
    side: _LabelSide.left,

    straightReveal: 0.6,
  ),
  _RouteNode(point: 13, label: 'Base camp', filled: true, straightReveal: 1.0),
];

// /// Straight-line counterparts to [_kRoutePoints]: a centred vertical column,
// /// ordered bottom → top with point indices lined up 1:1 with [_kRoutePoints] so
// /// each control point can be blended to its route position. The node indices
// /// (0, 7, 10, 13) are placed at the same heights the collapsed timeline used
// /// (fractions 0, 0.3, 0.6, 1 from the bottom) so the captions stay anchored
// /// while the line bends.
const List<Offset> _kStraightPoints = [
  Offset(0.5, 1.000), // 0  Start camp (bottom)
  Offset(0.5, 0.957),
  Offset(0.5, 0.914),
  Offset(0.5, 0.871),
  Offset(0.5, 0.829),
  Offset(0.5, 0.786),
  Offset(0.5, 0.743),
  Offset(0.5, 0.700), // 7  Vultures
  Offset(0.5, 0.600),
  Offset(0.5, 0.500),
  Offset(0.5, 0.400), // 10 Leopards
  Offset(0.5, 0.267),
  Offset(0.5, 0.133),
  Offset(0.5, 0.000), // 13 Base camp (top)
];

// /// Catmull-Rom spline through [points] emitted as cubic beziers so the line
// /// flows smoothly through every traced point.
Path _smoothPath(List<Offset> points) {
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (int i = 0; i < points.length - 1; i++) {
    final p0 = points[i == 0 ? 0 : i - 1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = points[i + 2 < points.length ? i + 2 : i + 1];

    final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
    final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}

// /// Returns the leading [fraction] (0..1) of [path] by arc length.
Path _trimPath(Path path, double fraction) {
  if (fraction >= 1.0) return path;
  final result = Path();
  double remaining =
      path.computeMetrics().fold(0.0, (sum, m) => sum + m.length) * fraction;
  for (final metric in path.computeMetrics()) {
    if (remaining <= 0) break;
    final double take = remaining.clamp(0.0, metric.length);
    result.addPath(metric.extractPath(0, take), Offset.zero);
    remaining -= take;
  }
  return result;
}

/// Rebuilds the morphing route as either animation ticks. [drawOn] grows the
/// line on from the bottom; [morph] bends the straight timeline into the route.
class AnimatedMorphingRouteLine extends StatelessWidget {
  const AnimatedMorphingRouteLine({
    super.key,
    required this.drawOn,
    required this.morph,
  });

  /// Draw-on progress for the line (0 collapsed → 1 fully drawn).
  final Animation<double> drawOn;

  /// Shape blend (0 straight vertical line → 1 curved route).
  final Animation<double> morph;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([drawOn, morph]),
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _MorphingRoutePainter(
          progress: drawOn.value,
          morph: morph.value,
        ),
      ),
    );
  }
}

/// Paints the route at any blend between a straight vertical line ([morph] = 0)
/// and the full winding trek route ([morph] = 1), grown on from the bottom by
/// [progress]. Driving [morph] 0→1 makes the straight timeline appear to bend
/// into the route; the node captions and leopard glyph fade in as it curves.
class _MorphingRoutePainter extends CustomPainter {
  const _MorphingRoutePainter({required this.progress, required this.morph});

  /// Draw-on growth from the bottom, 0.0 → 1.0.
  final double progress;

  /// Shape blend: 0.0 straight vertical line, 1.0 curved route.
  final double morph;

  static const double _dotRadius = 4.5;
  static const double _ringRadius = 5.5;
  static const double _labelGap = 16;
  static const double _iconSize = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final double m = morph.clamp(0.0, 1.0);

    // Blend each control point from its straight position to its route
    // position, then project the normalized point into pixels.
    final points = <Offset>[];
    for (int i = 0; i < _kRoutePoints.length; i++) {
      final n = Offset.lerp(_kStraightPoints[i], _kRoutePoints[i], m)!;
      points.add(Offset(n.dx * size.width, n.dy * size.height));
    }

    final shadowPaint = Paint()
      ..color = _kRouteShadow
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final linePaint = Paint()
      ..color = _kRouteColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fullPath = _smoothPath(points);
    final shownPath = _trimPath(fullPath, progress.clamp(0.0, 1.0));
    canvas.drawPath(shownPath, shadowPaint); // soft halo for legibility
    canvas.drawPath(shownPath, linePaint);

    for (final node in _kRouteNodes) {
      // The reveal point slides from its straight fraction to the route's
      // arc-length fraction as the line curves.
      final double curveFraction = node.point / (_kRoutePoints.length - 1);
      final double revealFraction =
          node.straightReveal + (curveFraction - node.straightReveal) * m;
      if (progress < revealFraction) continue;
      // The dot/ring shows on the straight timeline too; the caption only
      // fades in as the line bends into the route.
      _paintNode(canvas, points[node.point], node, m);
    }
  }

  /// [labelOpacity] fades the caption + glyph in as the line curves; the node
  /// dot/ring stays opaque since it exists in both the straight and curved
  /// states.
  void _paintNode(
    Canvas canvas,
    Offset p,
    _RouteNode node,
    double labelOpacity,
  ) {
    final dotPaint = Paint()
      ..color = _kRouteColor
      ..style = PaintingStyle.fill;

    if (node.icon != null && labelOpacity > 0) {
      _paintIcon(canvas, node.icon!, p, labelOpacity);
    }

    if (node.filled) {
      // Camp: small dark halo + filled white dot.
      canvas.drawCircle(p, _dotRadius + 1.5, Paint()..color = _kRingFill);
      canvas.drawCircle(p, _dotRadius, dotPaint);
    } else {
      // Sighting: outlined ring with a darkened centre.
      canvas.drawCircle(p, _ringRadius, Paint()..color = _kRingFill);
      canvas.drawCircle(
        p,
        _ringRadius,
        Paint()
          ..color = _kRouteColor
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(p, 1.6, dotPaint);
    }

    if (labelOpacity > 0) {
      _paintLabel(canvas, node, p, labelOpacity);
    }
  }

  void _paintLabel(Canvas canvas, _RouteNode node, Offset p, double opacity) {
    final tp = TextPainter(
      text: TextSpan(
        text: node.label,
        style: _kRouteLabelStyle.copyWith(
          color: _kRouteColor.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double dy = p.dy - tp.height / 2;
    final double dx = node.side == _LabelSide.right
        ? p.dx + _labelGap
        : p.dx - _labelGap - tp.width;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _paintIcon(Canvas canvas, IconData icon, Offset p, double opacity) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: _iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: _kRouteColor.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(p.dx - tp.width - 6, p.dy - tp.height - 8));
  }

  @override
  bool shouldRepaint(covariant _MorphingRoutePainter old) =>
      old.progress != progress || old.morph != morph;
}
