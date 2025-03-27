import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_round.freezed.dart';
part 'game_round.g.dart';

@freezed
class GameRound with _$GameRound {
  factory GameRound({
    required int gifId,
    required List<String> options,
    required String correctAnswer,
    @JsonKey(name: 'gif_url') required String gifUrl,
  }) = _GameRound;

  factory GameRound.fromJson(Map<String, dynamic> json) => _$GameRoundFromJson(json);
}
