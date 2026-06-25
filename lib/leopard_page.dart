import 'dart:math' as math;

import 'package:flutter/material.dart';

// First hero page. [controller] is owned by the parent pager and slides the
// background "72" in as the page scrolls into view.
class LeopardPage extends StatelessWidget {
  const LeopardPage({super.key, required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            top: size.height * 0.18,
            left: -(size.width * 0.25 + controller.value * 200),
            child: Transform.rotate(
              angle: math.pi / 2,
              alignment: Alignment.center,
              child: const Text(
                "72",
                style: TextStyle(
                  color: Color.fromARGB(255, 242, 238, 243),
                  fontSize: 400,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 20,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // ── Leopard image ────────────────────────────────────────────
          Positioned(
            left: 15,
            right: 0,
            top: size.height * 0.25,
            child: Image.asset(
              "assets/images/leopard_black_n_white-1.png",
              width: size.width * 0.8,
              height: size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class LeopardPageDescription extends StatelessWidget {
  const LeopardPageDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Travel description",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24),
          ],
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: Text(
            "The leopard is distinguished by its well-camouflaged fur, opportunistic hunting behaviour, broad diet, and strength.",
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}
