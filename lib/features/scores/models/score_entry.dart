import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_entry.freezed.dart';
part 'score_entry.g.dart';

@freezed
class ScoreEntry with _$ScoreEntry {
  const factory ScoreEntry({
    required int score,
    required int streak,
    required DateTime date,
  }) = _ScoreEntry;

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => _$ScoreEntryFromJson(json);
}
