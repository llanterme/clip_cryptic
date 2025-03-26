import 'package:flutter/material.dart';
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/features/welcome/widgets/floating_balloon.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated balloons background
          ...List.generate(
            10,
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.movie_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Welcome text
                Text(
                  'Clip Cryptic',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Can you guess the movie from just a GIF? Test your movie knowledge!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                const SizedBox(height: 48),

                // Start game button
                ElevatedButton.icon(
                  onPressed: () => context.go('/game'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Playing'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
