import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clip_cryptic/features/scores/models/score_entry.dart';

const _scoresKey = 'high_scores';
const _maxScores = 10;

/// Repository for managing high scores
class ScoresRepository {
  /// Loads the list of high scores from SharedPreferences
  Future<List<ScoreEntry>> getHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getStringList(_scoresKey);

      if (scoresJson == null || scoresJson.isEmpty) {
        return [];
      }

      return scoresJson
          .map((json) => ScoreEntry.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      developer.log('Error loading scores: $e');
      return [];
    }
  }

  /// Saves the list of high scores to SharedPreferences
  Future<void> _saveScores(List<ScoreEntry> scores) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson =
          scores.map((score) => jsonEncode(score.toJson())).toList();

      await prefs.setStringList(_scoresKey, scoresJson);
    } catch (e) {
      developer.log('Error saving scores: $e');
    }
  }

  /// Adds a new score to the high scores list
  /// If the list exceeds the maximum number of scores, the lowest scores are removed
  Future<void> addScore(int score, int streak) async {
    try {
      final currentScores = await getHighScores();
      final newEntry = ScoreEntry(
        score: score,
        streak: streak,
        date: DateTime.now(),
      );

      // Add new entry
      currentScores.add(newEntry);

      // Sort by score (descending)
      currentScores.sort((a, b) => b.score.compareTo(a.score));

      // Keep only top scores
      final topScores = currentScores.take(_maxScores).toList();

      // Save updated scores
      await _saveScores(topScores);
    } catch (e) {
      developer.log('Error adding score: $e');
    }
  }

  /// Clears all high scores
  Future<void> clearScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scoresKey);
    } catch (e) {
      developer.log('Error clearing scores: $e');
    }
  }
}
