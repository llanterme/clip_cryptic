// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameRoundImpl _$$GameRoundImplFromJson(Map<String, dynamic> json) =>
    _$GameRoundImpl(
      gifId: (json['gifId'] as num).toInt(),
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      gifUrl: json['gif_url'] as String,
    );

Map<String, dynamic> _$$GameRoundImplToJson(_$GameRoundImpl instance) =>
    <String, dynamic>{
      'gifId': instance.gifId,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'gif_url': instance.gifUrl,
    };
