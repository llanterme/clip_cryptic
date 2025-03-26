import 'dart:developer' as developer;
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

  @override
  GameStatus build() => GameStatus.initial;

  Future<void> startGame() async {
    state = GameStatus.loading;
    try {
      final gameService = ref.read(gameServiceProvider);
      // We're using the hardcoded user ID in the service now
      _rounds = await gameService.getUnseenRounds('');
      
      if (_rounds.isEmpty) {
        state = GameStatus.gameOver;
        return;
      }

      _currentRoundIndex = 0;
      _lastAnswerCorrect = false;
      state = GameStatus.playing;
      
      // Debug the first round
      final firstRound = _rounds.isNotEmpty ? _rounds[0] : null;
      if (firstRound != null) {
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
    if (state != GameStatus.playing || _currentRoundIndex >= _rounds.length) {
      return null;
    }
    return _rounds[_currentRoundIndex];
  }

  void submitAnswer(String answer) {
    final currentRound = getCurrentRound();
    if (currentRound == null) return;
    
    // Debug the comparison
    developer.log('User selected: "$answer"');
    developer.log('Correct answer: "${currentRound.correctAnswer}"');
    
    // Normalize both strings to handle case sensitivity and whitespace issues
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedCorrectAnswer = currentRound.correctAnswer.trim().toLowerCase();
    
    developer.log('Normalized user answer: "$normalizedAnswer"');
    developer.log('Normalized correct answer: "$normalizedCorrectAnswer"');
    developer.log('Match? ${normalizedCorrectAnswer == normalizedAnswer}');
    
    if (normalizedCorrectAnswer == normalizedAnswer) {
      _lastAnswerCorrect = true;
      // Move to next round
      _currentRoundIndex++;
      
      // Check if this was the last round
      if (_currentRoundIndex >= _rounds.length) {
        state = GameStatus.gameComplete;
      } else {
        // Trigger a UI refresh by updating the state
        state = GameStatus.playing;
        
        // Debug the next round
        final nextRound = _rounds[_currentRoundIndex];
        developer.log('Next round: gifId=${nextRound.gifId}');
        developer.log('Options: ${nextRound.options.join(", ")}');
        developer.log('Correct answer: "${nextRound.correctAnswer}"');
      }
    } else {
      // Game over on wrong answer
      _lastAnswerCorrect = false;
      state = GameStatus.gameOver;
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

  void resetGame() {
    _rounds = [];
    _currentRoundIndex = 0;
    _lastAnswerCorrect = false;
    state = GameStatus.initial;
    
    // Automatically start a new game after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      startGame();
    });
  }
}
