// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiSuggestion {

 int get flightId; String get reason;
/// Create a copy of AiSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSuggestionCopyWith<AiSuggestion> get copyWith => _$AiSuggestionCopyWithImpl<AiSuggestion>(this as AiSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestion&&(identical(other.flightId, flightId) || other.flightId == flightId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,flightId,reason);

@override
String toString() {
  return 'AiSuggestion(flightId: $flightId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AiSuggestionCopyWith<$Res>  {
  factory $AiSuggestionCopyWith(AiSuggestion value, $Res Function(AiSuggestion) _then) = _$AiSuggestionCopyWithImpl;
@useResult
$Res call({
 int flightId, String reason
});




}
/// @nodoc
class _$AiSuggestionCopyWithImpl<$Res>
    implements $AiSuggestionCopyWith<$Res> {
  _$AiSuggestionCopyWithImpl(this._self, this._then);

  final AiSuggestion _self;
  final $Res Function(AiSuggestion) _then;

/// Create a copy of AiSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flightId = null,Object? reason = null,}) {
  return _then(_self.copyWith(
flightId: null == flightId ? _self.flightId : flightId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiSuggestion].
extension AiSuggestionPatterns on AiSuggestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiSuggestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _AiSuggestion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _AiSuggestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int flightId,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiSuggestion() when $default != null:
return $default(_that.flightId,_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int flightId,  String reason)  $default,) {final _that = this;
switch (_that) {
case _AiSuggestion():
return $default(_that.flightId,_that.reason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int flightId,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _AiSuggestion() when $default != null:
return $default(_that.flightId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _AiSuggestion implements AiSuggestion {
  const _AiSuggestion({required this.flightId, required this.reason});
  

@override final  int flightId;
@override final  String reason;

/// Create a copy of AiSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiSuggestionCopyWith<_AiSuggestion> get copyWith => __$AiSuggestionCopyWithImpl<_AiSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiSuggestion&&(identical(other.flightId, flightId) || other.flightId == flightId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,flightId,reason);

@override
String toString() {
  return 'AiSuggestion(flightId: $flightId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$AiSuggestionCopyWith<$Res> implements $AiSuggestionCopyWith<$Res> {
  factory _$AiSuggestionCopyWith(_AiSuggestion value, $Res Function(_AiSuggestion) _then) = __$AiSuggestionCopyWithImpl;
@override @useResult
$Res call({
 int flightId, String reason
});




}
/// @nodoc
class __$AiSuggestionCopyWithImpl<$Res>
    implements _$AiSuggestionCopyWith<$Res> {
  __$AiSuggestionCopyWithImpl(this._self, this._then);

  final _AiSuggestion _self;
  final $Res Function(_AiSuggestion) _then;

/// Create a copy of AiSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flightId = null,Object? reason = null,}) {
  return _then(_AiSuggestion(
flightId: null == flightId ? _self.flightId : flightId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
