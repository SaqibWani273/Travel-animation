import 'dart:developer';

import 'package:flutter/material.dart';

class LeopardPage extends StatefulWidget {
  final AnimationController controller;
  const LeopardPage({super.key, required this.controller});

  @override
  State<LeopardPage> createState() => _LeopardPageState();
}

class _LeopardPageState extends State<LeopardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = widget.controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            top: screenHeight * 0.12,
            left: -(screenWidth * 0.25 + (_controller.value * 200)),

            child: Transform.rotate(
              angle: 3.14 / 2,
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
            left: 0,
            right: 0,
            top: screenHeight * 0.2,
            child: Image.asset(
              width: screenWidth * 0.8,
              height: screenWidth * 0.7,
              "assets/images/leopard_black_n_white-1.png",
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
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
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

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: const Text(
            "The leopard is distinguished by its well-camouflaged fur, opportunistic hunting behaviour, broad diet, and strength.",
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
