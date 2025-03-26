import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/features/welcome/widgets/floating_balloon.dart';
import 'package:clip_cryptic/features/user/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ref.watch(userRepositoryProvider).when(
                      data: (user) => ElevatedButton.icon(
                        onPressed: () async {
                          if (user == null) {
                            // Show loading indicator
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Setting up your game...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            
                            try {
                              await ref
                                  .read(userRepositoryProvider.notifier)
                                  .createAndSaveUser();
                              if (context.mounted) {
                                context.go('/game');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            context.go('/game');
                          }
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Playing'),
                      ),
                      error: (error, stack) => ElevatedButton.icon(
                        onPressed: () => ref.invalidate(userRepositoryProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      loading: () => const CircularProgressIndicator(),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
