import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clip_cryptic/features/scores/models/score_entry.dart';
import 'package:clip_cryptic/features/scores/repositories/scores_repository.dart';

/// Provider for accessing the scores repository
final scoresRepositoryProvider = Provider<ScoresRepository>((ref) {
  return ScoresRepository();
});

/// Provider for the current list of high scores
/// This will be updated in real-time when scores change
final highScoresProvider = StateNotifierProvider<HighScoresNotifier, AsyncValue<List<ScoreEntry>>>((ref) {
  final repository = ref.watch(scoresRepositoryProvider);
  return HighScoresNotifier(repository);
});

/// Notifier that manages the high scores state
class HighScoresNotifier extends StateNotifier<AsyncValue<List<ScoreEntry>>> {
  final ScoresRepository _repository;
  
  HighScoresNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load scores on initialization
    loadScores();
  }
  
  /// Load scores from the repository
  Future<void> loadScores() async {
    state = const AsyncValue.loading();
    try {
      final scores = await _repository.getHighScores();
      state = AsyncValue.data(scores);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Add a new score and update the state
  Future<void> addScore(int score, int streak) async {
    await _repository.addScore(score, streak);
    await loadScores(); // Reload scores after adding
  }
  
  /// Clear all scores and update the state
  Future<void> clearScores() async {
    await _repository.clearScores();
    state = const AsyncValue.data([]);
  }
}
