import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clip_cryptic/features/game/models/game_round.dart';
import 'package:clip_cryptic/features/game/services/game_service.dart';
import 'package:clip_cryptic/features/user/repositories/user_repository.dart';
import 'package:clip_cryptic/features/scores/providers/scores_repository_provider.dart';

part 'game_controller.g.dart';

enum GameStatus {
  initial,
  loading,
  playing,
  error,
  gameOver,
  gameComplete,
}

@riverpod
class GameController extends _$GameController {
  GameRound? _lastRound;
  List<GameRound> _rounds = [];
  int _currentRoundIndex = 0;
  bool _lastAnswerCorrect = false;
  int _currentScore = 0;
  int _currentStreak = 0;
  int _highestStreak = 0;
  String? _selectedAnswer;
  final _random = math.Random();

  // Hint system - changed to be per game instead of per round
  int _hintsRemainingForGame = 4; // Maximum 4 hints per game
  List<String> _eliminatedOptions = []; // Track which options have been eliminated by hints

  // Track seen GIFs to avoid repetition
  Set<int> _seenGifIds = {};

  // Track recently played GIFs to avoid showing the same ones in consecutive games
  // Map of GIF ID to count of recent appearances
  Map<int, int> _recentlyPlayedGifs = {};

  @override
  GameStatus build() => GameStatus.initial;

  /// Initializes the user and ensures it exists before starting the game
  /// Returns true if user initialization was successful
  Future<bool> _ensureUserExists() async {
    try {
      // Get current user from the AsyncValue provider
      final userProvider = ref.read(userRepositoryProvider);
      final user = userProvider.valueOrNull;

      if (user == null) {
        // We should NOT create a new user here - that's handled by the welcome screen
        // If we get here with no user, it's an error
        developer.log(
            'Error: No user found in repository. User should be created on welcome screen.');
        return false;
      } else {
        developer.log('Using existing user ID: ${user.id}');
        return true;
      }
    } catch (e) {
      developer.log('Error checking if user exists: $e');
      return false;
    }
  }

  Future<void> startGame() async {
    state = GameStatus.loading;
    try {
      // First ensure user exists
      final userInitialized = await _ensureUserExists();
      if (!userInitialized) {
        developer.log('Failed to initialize user');
        state = GameStatus.error;
        return;
      }

      final gameService = ref.read(gameServiceProvider);
      // Pass the ref to the service method
      _rounds = await gameService.getUnseenRounds(ref);

      // Randomize the order of rounds
      _shuffleRounds();

      // Reset the game state
      _currentRoundIndex = 0;
      _currentScore = 0;
      _currentStreak = 0;
      _highestStreak = 0;
      _selectedAnswer = null;
      _lastRound = null;
      _hintsRemainingForGame = 4; // Reset hints for new game
      _eliminatedOptions = []; // Clear eliminated options

      // Clean up old entries in _recentlyPlayedGifs to prevent the map from growing too large
      _cleanupRecentlyPlayedGifs();

      // We don't clear _seenGifIds here to maintain the list across games

      if (_rounds.isEmpty) {
        developer.log('No rounds available');
        state = GameStatus.gameComplete;
      } else {
        state = GameStatus.playing;

        // Debug the first round loaded
        final firstRound = _rounds[0];
        developer.log('First round loaded: gifId=${firstRound.gifId}');
        developer.log('Options: ${firstRound.options.join(", ")}');
        developer.log('Correct answer: "${firstRound.correctAnswer}"');
      }
    } catch (e) {
      developer.log('Error starting game: $e');
      state = GameStatus.error;
    }
  }

  // Enhanced Fisher-Yates shuffle algorithm with weighted randomization
  // This ensures better variety by deprioritizing recently seen GIFs
  void _shuffleRounds() {
    developer
        .log('Shuffling ${_rounds.length} rounds with enhanced randomization');

    // Create a copy of the original list to log the order change
    final originalOrder = List<int>.from(_rounds.map((r) => r.gifId));

    // First, assign weights to each round based on how recently they've been played
    final weights = <double>[];

    for (var round in _rounds) {
      // Default weight is 1.0 (normal priority)
      double weight = 1.0;

      // If this GIF has been played recently, reduce its weight
      if (_recentlyPlayedGifs.containsKey(round.gifId)) {
        final appearances = _recentlyPlayedGifs[round.gifId] ?? 0;
        // Exponentially decrease weight based on number of recent appearances
        weight = 1.0 / (appearances + 1);
      }

      weights.add(weight);
    }

    // Perform weighted shuffle
    for (int i = _rounds.length - 1; i > 0; i--) {
      // Use weighted random selection for better variety
      int j = _getWeightedRandomIndex(i + 1, weights.sublist(0, i + 1));

      // Swap elements at i and j
      if (i != j) {
        GameRound temp = _rounds[i];
        _rounds[i] = _rounds[j];
        _rounds[j] = temp;

        // Also swap their weights
        double tempWeight = weights[i];
        weights[i] = weights[j];
        weights[j] = tempWeight;
      }
    }

    // Log the new order for debugging
    final newOrder = List<int>.from(_rounds.map((r) => r.gifId));
    developer.log('Original order: $originalOrder');
    developer.log('New shuffled order: $newOrder');
  }

  // Get a random index with weighting applied
  int _getWeightedRandomIndex(int max, List<double> weights) {
    // Calculate total weight
    double totalWeight = 0;
    for (int i = 0; i < max; i++) {
      totalWeight += weights[i];
    }

    // Get a random value between 0 and totalWeight
    double randomValue = _random.nextDouble() * totalWeight;

    // Find the index corresponding to this random value
    double cumulativeWeight = 0;
    for (int i = 0; i < max; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return i;
      }
    }

    // Fallback to simple random if something goes wrong
    return _random.nextInt(max);
  }

  GameRound? getCurrentRound() {
    if (_rounds.isEmpty || _currentRoundIndex >= _rounds.length) {
      return null;
    }
    return _rounds[_currentRoundIndex];
  }

  void submitAnswer(String answer) {
    if (state != GameStatus.playing) return;

    final currentRound = getCurrentRound();
    if (currentRound == null) return;

    // Save the last round before potentially moving to the next one
    _lastRound = currentRound;

    // Add current GIF ID to seen list
    _seenGifIds.add(currentRound.gifId);

    // Update recently played GIFs counter
    _recentlyPlayedGifs.update(
      currentRound.gifId,
      (count) => count + 1,
      ifAbsent: () => 1,
    );

    // Set the selected answer
    _selectedAnswer = answer;

    // Normalize answers for comparison (trim whitespace, convert to lowercase)
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedCorrectAnswer =
        currentRound.correctAnswer.trim().toLowerCase();

    // Check if answer is correct
    if (normalizedCorrectAnswer == normalizedAnswer) {
      _lastAnswerCorrect = true;
      _currentScore += 10;
      _currentStreak++;

      // Update highest streak if current streak is higher
      if (_currentStreak > _highestStreak) {
        _highestStreak = _currentStreak;
      }

      developer.log(
          'Correct answer! Score: $_currentScore, Streak: $_currentStreak');

      // Short delay to show the correct answer before moving to next round
      Future.delayed(const Duration(milliseconds: 800), () {
        _moveToNextRound();
      });
    } else {
      // Wrong answer
      _lastAnswerCorrect = false;
      _currentStreak = 0;
      _hintsRemainingForGame = 4; // Reset hints for next round
      _eliminatedOptions = []; // Clear eliminated options

      developer.log('Wrong answer! Correct was: ${currentRound.correctAnswer}');

      // Short delay to show the wrong/correct answers before game over
      Future.delayed(const Duration(milliseconds: 800), () {
        state = GameStatus.gameOver;
        _saveHighScore();
      });
    }
  }

  void _moveToNextRound() {
    _currentRoundIndex++;
    _selectedAnswer = null;
    _eliminatedOptions = []; // Clear eliminated options for the new round
    // Don't reset hints - they're now per game

    // Check if this was the last round
    if (_currentRoundIndex >= _rounds.length) {
      developer.log('Game complete! No more rounds.');
      state = GameStatus.gameComplete;
      _saveHighScore();
    } else {
      // Force UI refresh by setting state to a temporary value and then back
      state = GameStatus.loading;

      // Use a short delay to ensure the UI updates
      Future.delayed(const Duration(milliseconds: 100), () {
        state = GameStatus.playing;

        // Debug the next round
        final nextRound = _rounds[_currentRoundIndex];
        developer.log('Next round: gifId=${nextRound.gifId}');
        developer.log('Options: ${nextRound.options.join(", ")}');
        developer.log('Correct answer: "${nextRound.correctAnswer}"');
      });
    }
  }

  bool wasLastAnswerCorrect() {
    return _lastAnswerCorrect;
  }

  int getTotalRounds() {
    return _rounds.length;
  }

  int getCurrentRoundNumber() {
    return _currentRoundIndex + 1;
  }

  int getCurrentScore() {
    return _currentScore;
  }

  int getCurrentStreak() {
    return _currentStreak;
  }

  int getHighestStreak() {
    return _highestStreak;
  }

  String? getSelectedAnswer() {
    return _selectedAnswer;
  }

  String getCorrectAnswer() {
    // If we have a saved last round, use that
    if (_lastRound != null) {
      return _lastRound!.correctAnswer;
    }

    // Otherwise try to get from current round
    final currentRound = getCurrentRound();
    if (currentRound == null) return "";
    return currentRound.correctAnswer;
  }

  // Get the list of seen GIF IDs
  List<int> getSeenGifIds() {
    return _seenGifIds.toList();
  }

  /// Save the current score and streak as a high score
  Future<void> _saveHighScore() async {
    if (_currentScore > 0) {
      try {
        developer.log(
            'Saving score: $_currentScore, highest streak: $_highestStreak');
        await ref
            .read(highScoresProvider.notifier)
            .addScore(_currentScore, _highestStreak);
      } catch (e) {
        developer.log('Error saving score: $e');
      }
    }
  }

  // Mark all seen GIFs on the server and reset the game
  Future<void> resetGame() async {
    // If we have seen GIFs, mark them on the server
    if (_seenGifIds.isNotEmpty) {
      developer.log('Marking ${_seenGifIds.length} GIFs as seen: $_seenGifIds');

      try {
        final gameService = ref.read(gameServiceProvider);
        final success =
            await gameService.markGifsAsSeen(_seenGifIds.toList(), ref);

        if (success) {
          developer.log('Successfully marked GIFs as seen on the server');
        } else {
          developer.log('Failed to mark GIFs as seen on the server');
        }
      } catch (e) {
        developer.log('Error marking GIFs as seen: $e');
      }
    }

    // Score saving has been moved to when the game ends (GameOver or GameComplete states)

    // Reset game state
    _rounds = [];
    _currentRoundIndex = 0;
    _lastAnswerCorrect = false;
    _currentScore = 0;
    _currentStreak = 0;
    _highestStreak = 0;
    _selectedAnswer = null;
    _lastRound = null;
    state = GameStatus.initial;

    // Do not clear _seenGifIds since we want to maintain the history across games

    // Clean up old entries in _recentlyPlayedGifs to prevent the map from growing too large
    _cleanupRecentlyPlayedGifs();

    // Automatically start a new game after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      startGame();
    });
  }

  /// Cleans up old entries in the _recentlyPlayedGifs map
  /// to prevent it from growing too large over time
  void _cleanupRecentlyPlayedGifs() {
    // If we have more than 100 entries, remove the oldest ones
    if (_recentlyPlayedGifs.length > 100) {
      // Sort by count (ascending) and take only the top 50
      final sortedEntries = _recentlyPlayedGifs.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      // Keep only the most frequently played 50 GIFs
      _recentlyPlayedGifs = Map.fromEntries(
        sortedEntries.skip(sortedEntries.length - 50),
      );
      
      developer.log('Cleaned up _recentlyPlayedGifs, now has ${_recentlyPlayedGifs.length} entries');
    }
  }

  // Hint system methods
  
  /// Returns the number of hints remaining for the game
  int getHintsRemaining() {
    return _hintsRemainingForGame;
  }
  
  /// Returns the list of options that have been eliminated by hints
  List<String> getEliminatedOptions() {
    return _eliminatedOptions;
  }
  
  /// Uses a hint to eliminate two incorrect options
  /// Returns true if hint was successfully used, false if no hints remaining
  bool useHint() {
    developer.log('useHint called. Hints remaining: $_hintsRemainingForGame, Game status: $state, Selected answer: $_selectedAnswer');
    
    if (_hintsRemainingForGame <= 0 || state != GameStatus.playing || _selectedAnswer != null) {
      developer.log('Cannot use hint: hints remaining: $_hintsRemainingForGame, game status: $state, selected answer: $_selectedAnswer');
      return false;
    }
    
    final currentRound = getCurrentRound();
    if (currentRound == null) {
      developer.log('Cannot use hint: current round is null');
      return false;
    }
    
    // Get all incorrect options that haven't been eliminated yet
    final incorrectOptions = currentRound.options
        .where((option) => 
            option != currentRound.correctAnswer && 
            !_eliminatedOptions.contains(option))
        .toList();
    
    developer.log('Incorrect options available for elimination: ${incorrectOptions.length}');
    
    // If there are fewer than 2 incorrect options available, use what we have
    final optionsToEliminate = math.min(2, incorrectOptions.length);
    
    if (optionsToEliminate == 0) {
      developer.log('No options to eliminate');
      return false; // No options to eliminate
    }
    
    // Shuffle incorrect options to randomize which ones get eliminated
    incorrectOptions.shuffle(_random);
    
    // Add the options to eliminate to our tracking list
    for (int i = 0; i < optionsToEliminate; i++) {
      _eliminatedOptions.add(incorrectOptions[i]);
      developer.log('Eliminated option: ${incorrectOptions[i]}');
    }
    
    // Decrement available hints
    _hintsRemainingForGame--;
    
    developer.log('Hint used successfully. Hints remaining: $_hintsRemainingForGame, Eliminated options: $_eliminatedOptions');
    
    // Force a rebuild by setting state to itself with a new instance
    // This is necessary to trigger UI updates for the eliminated options
    final currentStatus = state;
    state = GameStatus.loading; // Temporarily change state to force rebuild
    Future.microtask(() {
      state = currentStatus; // Restore original state
    });
    
    return true;
  }

  /// Skips the current GIF and moves to the next round
  /// Used when a GIF fails to load
  void skipToNextGif() {
    developer.log('Skipping GIF due to loading failure');
    
    // Mark the current GIF as seen even though it failed to load
    final currentRound = getCurrentRound();
    if (currentRound != null) {
      _seenGifIds.add(currentRound.gifId);
      
      // Update recently played GIFs counter
      _recentlyPlayedGifs.update(
        currentRound.gifId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    
    // Move to the next round without changing score or streak
    _moveToNextRound();
  }
}
