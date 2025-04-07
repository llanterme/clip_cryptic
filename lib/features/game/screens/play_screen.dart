import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/core/widgets/animated_background.dart';
import 'package:clip_cryptic/features/game/controllers/game_controller.dart';
import 'package:clip_cryptic/core/services/ad_service.dart';

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
              _buildStartButton(context, controller, ref),
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
                    const SizedBox(height: 24),
                    // Answer Options Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade500.withOpacity(0.8),
                              Colors.blue.shade500.withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'What movie is this?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Answer Options
                    Expanded(
                      flex: 2,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        // Allow scrolling to see all options
                        physics: ClampingScrollPhysics(),
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
                    // Hint button
                    if (selectedAnswer == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Consumer(
                          builder: (context, ref, _) {
                            final controller =
                                ref.read(gameControllerProvider.notifier);
                            final hintsRemaining =
                                controller.getHintsRemaining();

                            return ElevatedButton.icon(
                              onPressed: hintsRemaining > 0
                                  ? () {
                                      developer.log('Hint button pressed');
                                      controller.useHint();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hintsRemaining > 0
                                    ? Colors.amber.shade600
                                    : Colors.grey.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: hintsRemaining > 0 ? 4 : 1,
                              ),
                              icon: Icon(Icons.lightbulb_outline),
                              label: Text(
                                hintsRemaining > 0
                                    ? "Use Hint (${hintsRemaining} left)"
                                    : "No Hints Left",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: hintsRemaining > 0
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Banner Ad below the Use Hint button
                      const SizedBox(height: 8),
                      const BannerAdWidget(),
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

        // Automatically skip to the next GIF after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          // Get the controller and skip to the next GIF
          final controller = ProviderScope.containerOf(context)
              .read(gameControllerProvider.notifier);
          controller.skipToNextGif();
        });

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
                  'Skipping to next...',
                  style: TextStyle(color: Colors.grey[700]),
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
    Color buttonColor = AppTheme.primaryColor.withOpacity(0.8);
    Color textColor = Colors.white;
    bool isSelected = option == selectedAnswer;
    bool isCorrect = option == correctAnswer;
    bool showResult = selectedAnswer != null;
    bool isEliminated = controller.getEliminatedOptions().contains(option);

    Widget? buttonIcon;

    if (showResult) {
      if (isCorrect) {
        buttonColor = Colors.green.shade500;
        textColor = Colors.white;
        buttonIcon = Icon(Icons.check_circle, color: Colors.white, size: 22);
      } else if (isSelected) {
        buttonColor = Colors.red.shade500;
        textColor = Colors.white;
        buttonIcon = Icon(Icons.cancel, color: Colors.white, size: 22);
      } else {
        buttonColor = Colors.indigo.withOpacity(0.5);
        textColor = Colors.white.withOpacity(0.9);
      }
    } else if (isEliminated) {
      buttonColor = Colors.grey.shade700.withOpacity(0.5);
      textColor = Colors.white.withOpacity(0.5);
      buttonIcon = Icon(Icons.not_interested,
          color: Colors.white.withOpacity(0.5), size: 22);
    } else {
      buttonColor = Colors.transparent;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: showResult
            ? (isCorrect || isSelected)
                ? null
                : LinearGradient(
                    colors: [
                      Colors.indigo.shade400.withOpacity(0.7),
                      Colors.purple.shade400.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
            : isEliminated
                ? LinearGradient(
                    colors: [
                      Colors.grey.shade700.withOpacity(0.5),
                      Colors.grey.shade800.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.purple.shade500.withOpacity(0.8),
                      Colors.blue.shade500.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: showResult && isCorrect
                ? Colors.green.withOpacity(0.6)
                : showResult && isSelected
                    ? Colors.red.withOpacity(0.6)
                    : isEliminated
                        ? Colors.black.withOpacity(0.2)
                        : Colors.purple.withOpacity(0.3),
            blurRadius: showResult ? 12 : 8,
            spreadRadius: showResult ? 2 : 1,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: showResult && (isCorrect || isSelected)
              ? (isCorrect ? Colors.green.shade300 : Colors.red.shade300)
              : isEliminated
                  ? Colors.grey.shade600.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
          width: showResult && (isCorrect || isSelected) ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: (showResult || isEliminated)
              ? null
              : () {
                  developer.log(
                      'User selected option: $option for round: $roundIndex');
                  controller.submitAnswer(option);
                },
          splashColor: AppTheme.primaryColor.withOpacity(0.3),
          highlightColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonIcon != null) ...[
                  buttonIcon,
                  SizedBox(height: 4),
                ],
                Flexible(
                  child: AutoSizeText(
                    option,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(
      BuildContext context, GameController controller, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie,
                    size: 40,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade500,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      'Movie GIF Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Can you guess the movie?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 64,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.startGame();
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Test Your Movie Knowledge',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Identify movies from animated GIFs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGameCompleteView(
      BuildContext context, GameController controller) {
    final score = controller.getCurrentScore();
    final highestStreak = controller.getHighestStreak();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade700.withOpacity(0.8),
                      Colors.indigo.shade700.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Congratulations!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'You completed all the rounds!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverView(BuildContext context, GameController controller) {
    final score = controller.getCurrentScore();
    final highestStreak = controller.getHighestStreak();
    final correctAnswer = controller.getCorrectAnswer();

    developer
        .log('Building Game Over screen with correct answer: "$correctAnswer"');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        const SizedBox(height: 24),
        if (correctAnswer.isNotEmpty) ...[
          Text(
            'The correct answer was:',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Text(
              correctAnswer,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
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
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 2.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
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
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.red.shade300, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Connection Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Unable to connect to the game server',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The server might be temporarily unavailable or your internet connection may be down.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Troubleshooting Tips:',
                  style: TextStyle(
                    color: Colors.blue.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildTroubleshootingItem(
                Icons.wifi_off,
                'Check your internet connection',
              ),
              const SizedBox(height: 4),
              _buildTroubleshootingItem(
                Icons.refresh,
                'Try again in a few moments',
              ),
              const SizedBox(height: 4),
              _buildTroubleshootingItem(
                Icons.settings,
                'Restart the app if the problem persists',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: controller.startGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                controller.resetGame();
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                side: BorderSide(color: Colors.white70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Go Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue.shade200,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
