// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'score_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoreEntry _$ScoreEntryFromJson(Map<String, dynamic> json) {
  return _ScoreEntry.fromJson(json);
}

/// @nodoc
mixin _$ScoreEntry {
  int get score => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this ScoreEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreEntryCopyWith<ScoreEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreEntryCopyWith<$Res> {
  factory $ScoreEntryCopyWith(
          ScoreEntry value, $Res Function(ScoreEntry) then) =
      _$ScoreEntryCopyWithImpl<$Res, ScoreEntry>;
  @useResult
  $Res call({int score, int streak, DateTime date});
}

/// @nodoc
class _$ScoreEntryCopyWithImpl<$Res, $Val extends ScoreEntry>
    implements $ScoreEntryCopyWith<$Res> {
  _$ScoreEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? streak = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoreEntryImplCopyWith<$Res>
    implements $ScoreEntryCopyWith<$Res> {
  factory _$$ScoreEntryImplCopyWith(
          _$ScoreEntryImpl value, $Res Function(_$ScoreEntryImpl) then) =
      __$$ScoreEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int score, int streak, DateTime date});
}

/// @nodoc
class __$$ScoreEntryImplCopyWithImpl<$Res>
    extends _$ScoreEntryCopyWithImpl<$Res, _$ScoreEntryImpl>
    implements _$$ScoreEntryImplCopyWith<$Res> {
  __$$ScoreEntryImplCopyWithImpl(
      _$ScoreEntryImpl _value, $Res Function(_$ScoreEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? streak = null,
    Object? date = null,
  }) {
    return _then(_$ScoreEntryImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreEntryImpl implements _ScoreEntry {
  const _$ScoreEntryImpl(
      {required this.score, required this.streak, required this.date});

  factory _$ScoreEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreEntryImplFromJson(json);

  @override
  final int score;
  @override
  final int streak;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'ScoreEntry(score: $score, streak: $streak, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreEntryImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, score, streak, date);

  /// Create a copy of ScoreEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreEntryImplCopyWith<_$ScoreEntryImpl> get copyWith =>
      __$$ScoreEntryImplCopyWithImpl<_$ScoreEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreEntryImplToJson(
      this,
    );
  }
}

abstract class _ScoreEntry implements ScoreEntry {
  const factory _ScoreEntry(
      {required final int score,
      required final int streak,
      required final DateTime date}) = _$ScoreEntryImpl;

  factory _ScoreEntry.fromJson(Map<String, dynamic> json) =
      _$ScoreEntryImpl.fromJson;

  @override
  int get score;
  @override
  int get streak;
  @override
  DateTime get date;

  /// Create a copy of ScoreEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreEntryImplCopyWith<_$ScoreEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
