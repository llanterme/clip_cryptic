// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoreEntryImpl _$$ScoreEntryImplFromJson(Map<String, dynamic> json) =>
    _$ScoreEntryImpl(
      score: (json['score'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$ScoreEntryImplToJson(_$ScoreEntryImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'streak': instance.streak,
      'date': instance.date.toIso8601String(),
    };
