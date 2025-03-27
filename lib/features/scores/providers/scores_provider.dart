import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clip_cryptic/features/scores/models/score_entry.dart';
import 'package:clip_cryptic/features/scores/repositories/scores_repository.dart';

/// Provider for accessing the scores repository
final scoresRepositoryProvider = Provider<ScoresRepository>((ref) {
  return ScoresRepository();
});

/// Provider for accessing the list of high scores
final highScoresProvider = FutureProvider<List<ScoreEntry>>((ref) async {
  final repository = ref.watch(scoresRepositoryProvider);
  return repository.getHighScores();
});
