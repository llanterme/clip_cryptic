import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/core/widgets/animated_background.dart';
import 'package:clip_cryptic/features/game/controllers/game_controller.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStatus = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final currentRound = controller.getCurrentRound();

    return AnimatedBackground(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gameStatus == GameStatus.initial) ...[
              _buildStartButton(context, controller),
            ] else if (gameStatus == GameStatus.loading) ...[
              Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
            ] else if (gameStatus == GameStatus.playing && currentRound != null) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Round ${controller.getCurrentRoundNumber()} of ${controller.getTotalRounds()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // GIF Display
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildGifImage(currentRound.gifUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Answer Options
                    Expanded(
                      flex: 2,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: currentRound.options.map((option) {
                          return _buildAnswerButton(option, controller);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (gameStatus == GameStatus.gameComplete) ...[
              _buildGameCompleteView(context, controller),
            ] else if (gameStatus == GameStatus.gameOver) ...[
              _buildGameOverView(context, controller),
            ] else if (gameStatus == GameStatus.error) ...[
              _buildErrorView(context, controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGifImage(String url) {
    developer.log('Loading GIF from URL: $url');
    
    return Image.network(
      url,
      fit: BoxFit.cover,
      key: ValueKey(url), // Add a key to force refresh when URL changes
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        developer.log('Error loading GIF: $error');
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load GIF',
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'URL: $url',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerButton(String option, GameController controller) {
    return ElevatedButton(
      onPressed: () {
        developer.log('User selected option: $option');
        controller.submitAnswer(option);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
      ),
      child: Text(
        option,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, GameController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.secondaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            onPressed: controller.startGame,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Start New Game',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Test your movie knowledge!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildGameCompleteView(BuildContext context, GameController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.emoji_events,
          size: 80,
          color: Colors.amber,
        ),
        const SizedBox(height: 24),
        Text(
          'Congratulations!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'You completed all the rounds!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: controller.resetGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Play Again',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverView(BuildContext context, GameController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          controller.wasLastAnswerCorrect() ? Icons.check_circle : Icons.cancel,
          size: 80,
          color: controller.wasLastAnswerCorrect() ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 24),
        Text(
          controller.wasLastAnswerCorrect() ? 'Game Complete!' : 'Game Over!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.wasLastAnswerCorrect()
              ? 'You answered all questions correctly!'
              : 'Better luck next time!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: controller.resetGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Play Again',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, GameController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          'Oops! Something went wrong',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Failed to load game data',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: controller.startGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Try Again'),
        ),
      ],
    );
  }
}
