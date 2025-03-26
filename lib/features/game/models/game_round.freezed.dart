// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameRound _$GameRoundFromJson(Map<String, dynamic> json) {
  return _GameRound.fromJson(json);
}

/// @nodoc
mixin _$GameRound {
  int get gifId => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  @JsonKey(name: 'gif_url')
  String get gifUrl => throw _privateConstructorUsedError;

  /// Serializes this GameRound to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameRoundCopyWith<GameRound> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameRoundCopyWith<$Res> {
  factory $GameRoundCopyWith(GameRound value, $Res Function(GameRound) then) =
      _$GameRoundCopyWithImpl<$Res, GameRound>;
  @useResult
  $Res call(
      {int gifId,
      List<String> options,
      String correctAnswer,
      @JsonKey(name: 'gif_url') String gifUrl});
}

/// @nodoc
class _$GameRoundCopyWithImpl<$Res, $Val extends GameRound>
    implements $GameRoundCopyWith<$Res> {
  _$GameRoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gifId = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? gifUrl = null,
  }) {
    return _then(_value.copyWith(
      gifId: null == gifId
          ? _value.gifId
          : gifId // ignore: cast_nullable_to_non_nullable
              as int,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      gifUrl: null == gifUrl
          ? _value.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameRoundImplCopyWith<$Res>
    implements $GameRoundCopyWith<$Res> {
  factory _$$GameRoundImplCopyWith(
          _$GameRoundImpl value, $Res Function(_$GameRoundImpl) then) =
      __$$GameRoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int gifId,
      List<String> options,
      String correctAnswer,
      @JsonKey(name: 'gif_url') String gifUrl});
}

/// @nodoc
class __$$GameRoundImplCopyWithImpl<$Res>
    extends _$GameRoundCopyWithImpl<$Res, _$GameRoundImpl>
    implements _$$GameRoundImplCopyWith<$Res> {
  __$$GameRoundImplCopyWithImpl(
      _$GameRoundImpl _value, $Res Function(_$GameRoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gifId = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? gifUrl = null,
  }) {
    return _then(_$GameRoundImpl(
      gifId: null == gifId
          ? _value.gifId
          : gifId // ignore: cast_nullable_to_non_nullable
              as int,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      gifUrl: null == gifUrl
          ? _value.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameRoundImpl implements _GameRound {
  _$GameRoundImpl(
      {required this.gifId,
      required final List<String> options,
      required this.correctAnswer,
      @JsonKey(name: 'gif_url') required this.gifUrl})
      : _options = options;

  factory _$GameRoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameRoundImplFromJson(json);

  @override
  final int gifId;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String correctAnswer;
  @override
  @JsonKey(name: 'gif_url')
  final String gifUrl;

  @override
  String toString() {
    return 'GameRound(gifId: $gifId, options: $options, correctAnswer: $correctAnswer, gifUrl: $gifUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameRoundImpl &&
            (identical(other.gifId, gifId) || other.gifId == gifId) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gifId,
      const DeepCollectionEquality().hash(_options), correctAnswer, gifUrl);

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameRoundImplCopyWith<_$GameRoundImpl> get copyWith =>
      __$$GameRoundImplCopyWithImpl<_$GameRoundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameRoundImplToJson(
      this,
    );
  }
}

abstract class _GameRound implements GameRound {
  factory _GameRound(
          {required final int gifId,
          required final List<String> options,
          required final String correctAnswer,
          @JsonKey(name: 'gif_url') required final String gifUrl}) =
      _$GameRoundImpl;

  factory _GameRound.fromJson(Map<String, dynamic> json) =
      _$GameRoundImpl.fromJson;

  @override
  int get gifId;
  @override
  List<String> get options;
  @override
  String get correctAnswer;
  @override
  @JsonKey(name: 'gif_url')
  String get gifUrl;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameRoundImplCopyWith<_$GameRoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
