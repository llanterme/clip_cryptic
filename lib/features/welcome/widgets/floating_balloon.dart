import 'dart:math';
import 'package:flutter/material.dart';

class FloatingBalloon extends StatefulWidget {
  final Color color;
  final double size;

  const FloatingBalloon({
    super.key,
    required this.color,
    this.size = 60,
  });

  @override
  State<FloatingBalloon> createState() => _FloatingBalloonState();
}

class _FloatingBalloonState extends State<FloatingBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double startX;
  late double startY;
  late double endX;
  late double endY;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    final random = Random();
    startX = random.nextDouble() * 400 - 200;
    startY = random.nextDouble() * 400 - 200;
    endX = random.nextDouble() * 400 - 200;
    endY = random.nextDouble() * 400 - 200;

    _controller = AnimationController(
      duration: Duration(seconds: random.nextInt(5) + 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final currentX = startX + (endX - startX) * progress;
        final currentY = startY + (endY - startY) * progress;

        return Transform.translate(
          offset: Offset(currentX, currentY),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size * 1.2,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
