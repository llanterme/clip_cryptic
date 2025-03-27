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

    // Force rebuild when game state changes
    final currentRound = controller.getCurrentRound();
    final currentRoundIndex = controller.getCurrentRoundNumber();
    final currentScore = controller.getCurrentScore();
    final currentStreak = controller.getCurrentStreak();
    final selectedAnswer = controller.getSelectedAnswer();

    developer.log(
        'Building PlayScreen with game status: $gameStatus, round index: ${currentRoundIndex - 1}, score: $currentScore, streak: $currentStreak');

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
            ] else if (gameStatus == GameStatus.playing &&
                currentRound != null) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Score and progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Round progress
                          Text(
                            'Round ${controller.getCurrentRoundNumber()} of ${controller.getTotalRounds()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Score display
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Score: $currentScore',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Streak indicator
                    if (currentStreak > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Streak: $currentStreak',
                              style: TextStyle(
                                color: Colors.orange,
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
                          // Add key with currentRoundIndex to force refresh
                          child: _buildGifImage(
                              currentRound.gifUrl, currentRoundIndex),
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
                          return _buildAnswerButton(
                            option,
                            controller,
                            currentRoundIndex,
                            selectedAnswer,
                            currentRound.correctAnswer,
                          );
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

  Widget _buildGifImage(String url, int roundIndex) {
    developer.log('Loading GIF from URL: $url for round: $roundIndex');

    return Image.network(
      url,
      fit: BoxFit.cover,
      // Add roundIndex to the key to force refresh when round changes
      key: ValueKey('gif_$roundIndex'),
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

  Widget _buildAnswerButton(
    String option,
    GameController controller,
    int roundIndex,
    String? selectedAnswer,
    String correctAnswer,
  ) {
    // Determine button color based on selection and correctness
    Color buttonColor = AppTheme.primaryColor.withOpacity(0.8);
    Color textColor = Colors.white;

    if (selectedAnswer != null) {
      if (option == correctAnswer) {
        // Correct answer
        buttonColor = Colors.green;
        textColor = Colors.white;
      } else if (option == selectedAnswer) {
        // Selected wrong answer
        buttonColor = Colors.red;
        textColor = Colors.white;
      } else {
        // Other options - fade them out
        buttonColor = AppTheme.primaryColor.withOpacity(0.4);
        textColor = Colors.white.withOpacity(0.7);
      }
    }

    return ElevatedButton(
      // Add roundIndex to the key to force refresh when round changes
      key: ValueKey('button_${option}_$roundIndex'),
      onPressed: selectedAnswer == null
          ? () {
              developer
                  .log('User selected option: $option for round: $roundIndex');
              controller.submitAnswer(option);
            }
          : null, // Disable buttons after selection
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: buttonColor,
        disabledBackgroundColor: buttonColor, // Keep the color when disabled
      ),
      child: Text(
        option,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
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

  Widget _buildGameCompleteView(
      BuildContext context, GameController controller) {
    final score = controller.getCurrentScore();
    final highestStreak = controller.getHighestStreak();

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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Final Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Highest Streak: $highestStreak',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
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
    final score = controller.getCurrentScore();
    final highestStreak = controller.getHighestStreak();
    final correctAnswer = controller.getCorrectAnswer();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated container with sad face
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.sentiment_very_dissatisfied,
            size: 80,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        // Game over text with animated effect
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.red.shade300, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Game Over!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'The correct answer was:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        // Highlight the correct answer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Text(
            correctAnswer,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 24),
        // Score display with improved design
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.6),
                Colors.blue.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Final Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Highest Streak: $highestStreak',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Play Again button with improved design
        ElevatedButton(
          onPressed: controller.resetGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.replay, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Play Again',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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
