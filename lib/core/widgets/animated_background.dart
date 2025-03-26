import 'package:flutter/material.dart';
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/features/welcome/widgets/floating_balloon.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final int balloonCount;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.balloonCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated balloons background
        ...List.generate(
          balloonCount,
          (index) => FloatingBalloon(
            color: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
              AppTheme.accentColor,
            ][index % 3],
            size: (index % 3 + 1) * 30,
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}
