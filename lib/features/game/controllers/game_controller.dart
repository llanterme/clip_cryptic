import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clip_cryptic/features/game/models/game_round.dart';
import 'package:clip_cryptic/features/game/services/game_service.dart';

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
  List<GameRound> _rounds = [];
  int _currentRoundIndex = 0;
  bool _lastAnswerCorrect = false;
  int _currentScore = 0;
  int _currentStreak = 0;
  int _highestStreak = 0;
  String? _selectedAnswer;
  final _random = math.Random();

  @override
  GameStatus build() => GameStatus.initial;

  Future<void> startGame() async {
    state = GameStatus.loading;
    try {
      final gameService = ref.read(gameServiceProvider);
      // We're using the hardcoded user ID in the service now
      _rounds = await gameService.getUnseenRounds('');
      
      // Randomize the order of rounds
      _shuffleRounds();
      
      // Reset the game state
      _currentRoundIndex = 0;
      _currentScore = 0;
      _currentStreak = 0;
      _highestStreak = 0;
      _selectedAnswer = null;
      
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

  GameRound? getCurrentRound() {
    if (state != GameStatus.playing || _currentRoundIndex >= _rounds.length || _rounds.isEmpty) {
      return null;
    }
    return _rounds[_currentRoundIndex];
  }

  void submitAnswer(String answer) {
    final currentRound = getCurrentRound();
    if (currentRound == null) {
      developer.log('No current round available');
      return;
    }
    
    // Store the selected answer for UI highlighting
    _selectedAnswer = answer;
    
    // Debug the comparison
    developer.log('Current round index: $_currentRoundIndex');
    developer.log('User selected: "$answer"');
    developer.log('Correct answer: "${currentRound.correctAnswer}"');
    developer.log('Current round data: ${currentRound.toString()}');
    developer.log('Options available: ${currentRound.options.join(", ")}');
    
    // Check if the selected answer is actually in the options
    final isOptionValid = currentRound.options.contains(answer);
    developer.log('Is selected answer in options? $isOptionValid');
    
    // Normalize both strings to handle case sensitivity and whitespace issues
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedCorrectAnswer = currentRound.correctAnswer.trim().toLowerCase();
    
    developer.log('Normalized user answer: "$normalizedAnswer"');
    developer.log('Normalized correct answer: "$normalizedCorrectAnswer"');
    developer.log('Match? ${normalizedCorrectAnswer == normalizedAnswer}');
    
    // Check each option against the correct answer for debugging
    for (final option in currentRound.options) {
      final normalizedOption = option.trim().toLowerCase();
      developer.log('Option: "$option" normalized: "$normalizedOption" matches correct answer? ${normalizedOption == normalizedCorrectAnswer}');
    }
    
    // Direct string comparison with normalization
    if (normalizedCorrectAnswer == normalizedAnswer) {
      developer.log('CORRECT ANSWER!');
      _lastAnswerCorrect = true;
      
      // Update score and streak
      _currentScore += 10;
      _currentStreak++;
      if (_currentStreak > _highestStreak) {
        _highestStreak = _currentStreak;
      }
      
      // Add a short delay to show the correct answer highlight
      Future.delayed(const Duration(milliseconds: 800), () {
        // Move to next round
        _currentRoundIndex++;
        _selectedAnswer = null;
        
        // Check if this was the last round
        if (_currentRoundIndex >= _rounds.length) {
          developer.log('Game complete! No more rounds.');
          state = GameStatus.gameComplete;
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
      });
    } else {
      // Game over on wrong answer
      developer.log('WRONG ANSWER!');
      _lastAnswerCorrect = false;
      _currentStreak = 0;
      
      // Add a short delay to show the wrong answer highlight
      Future.delayed(const Duration(milliseconds: 800), () {
        state = GameStatus.gameOver;
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
    final currentRound = getCurrentRound();
    if (currentRound == null) return "";
    return currentRound.correctAnswer;
  }

  void resetGame() {
    _rounds = [];
    _currentRoundIndex = 0;
    _lastAnswerCorrect = false;
    _currentScore = 0;
    _currentStreak = 0;
    _highestStreak = 0;
    _selectedAnswer = null;
    state = GameStatus.initial;
    
    // Automatically start a new game after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      startGame();
    });
  }
  
  // Fisher-Yates shuffle algorithm to randomize rounds
  void _shuffleRounds() {
    developer.log('Shuffling ${_rounds.length} rounds');
    
    // Create a copy of the original list to log the order change
    final originalOrder = List<int>.from(_rounds.map((r) => r.gifId));
    
    for (int i = _rounds.length - 1; i > 0; i--) {
      // Generate a random index between 0 and i
      int j = _random.nextInt(i + 1);
      
      // Swap elements at i and j
      if (i != j) {
        GameRound temp = _rounds[i];
        _rounds[i] = _rounds[j];
        _rounds[j] = temp;
      }
    }
    
    // Log the new order for debugging
    final newOrder = List<int>.from(_rounds.map((r) => r.gifId));
    developer.log('Original order: $originalOrder');
    developer.log('New shuffled order: $newOrder');
  }
}
