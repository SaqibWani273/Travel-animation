import 'package:flutter/material.dart';

const Color _kRouteColor = Colors.white;
const Color _kRingFill = Color(0x55000000);
const Color _kRouteShadow = Color(0x66000000);

const TextStyle _kRouteLabelStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.2,
);

// A stop on the route: a node plus its caption.
class _RouteNode {
  const _RouteNode({
    required this.point,
    required this.label,
    this.side = _LabelSide.right,
    this.filled = false,
    this.straightReveal = 0.0,
  });

  final int point; // index into _kRoutePoints
  final String label;
  final _LabelSide side;
  final bool filled; // filled dot (camp) vs. outlined ring (sighting)

  // Progress at which the node reveals on the straight timeline; slides toward
  // the route's arc-length fraction as the line bends.
  final double straightReveal;
}

enum _LabelSide { left, right }

// Route control points, bottom (start) → top (end). Traced from the reference;
// the in-between points just shape the switchbacks.
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

// Straight-line counterparts to _kRoutePoints, lined up 1:1 so each point can
// be blended to its route position. Node heights match the collapsed timeline.
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

// Catmull-Rom spline through [points], emitted as cubic beziers.
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

// Leading [fraction] (0..1) of [path] by arc length.
Path _trimPath(Path path, double fraction) {
  if (fraction >= 1.0) return path;
  // computeMetrics() is pricey, so walk it once.
  final metrics = path.computeMetrics().toList();
  final double totalLength = metrics.fold(0.0, (sum, m) => sum + m.length);
  double remaining = totalLength * fraction;

  final result = Path();
  for (final metric in metrics) {
    if (remaining <= 0) break;
    final double take = remaining.clamp(0.0, metric.length);
    result.addPath(metric.extractPath(0, take), Offset.zero);
    remaining -= take;
  }
  return result;
}

class AnimatedMorphingRouteLine extends StatelessWidget {
  const AnimatedMorphingRouteLine({
    super.key,
    required this.drawOn,
    required this.morph,
  });

  final Animation<double> drawOn; // grows the line on from the bottom
  final Animation<double> morph; // 0 straight line → 1 curved route

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

// Paints the route at any blend between a straight line (morph 0) and the full
// trek route (morph 1), grown on from the bottom by [progress].
class _MorphingRoutePainter extends CustomPainter {
  const _MorphingRoutePainter({required this.progress, required this.morph});

  final double progress;
  final double morph;

  static const double _dotRadius = 4.5;
  static const double _ringRadius = 5.5;
  static const double _labelGap = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final double m = morph.clamp(0.0, 1.0);

    // Blend each control point straight → route, then project into pixels.
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
      // Reveal point slides from the straight fraction to the arc-length one.
      final double curveFraction = node.point / (_kRoutePoints.length - 1);
      final double revealFraction =
          node.straightReveal + (curveFraction - node.straightReveal) * m;
      if (progress < revealFraction) continue;
      _paintNode(canvas, points[node.point], node, m);
    }
  }

  // [labelOpacity] fades the caption in as the line curves; the dot/ring stays
  // opaque since it exists in both states.
  void _paintNode(
    Canvas canvas,
    Offset p,
    _RouteNode node,
    double labelOpacity,
  ) {
    final dotPaint = Paint()
      ..color = _kRouteColor
      ..style = PaintingStyle.fill;

    if (node.filled) {
      // Camp: dark halo + filled dot.
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

  @override
  bool shouldRepaint(covariant _MorphingRoutePainter old) =>
      old.progress != progress || old.morph != morph;
}
