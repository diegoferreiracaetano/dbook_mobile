// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_suggestion_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiSuggestionItemDto {

 int get flightId; String get reason;
/// Create a copy of AiSuggestionItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSuggestionItemDtoCopyWith<AiSuggestionItemDto> get copyWith => _$AiSuggestionItemDtoCopyWithImpl<AiSuggestionItemDto>(this as AiSuggestionItemDto, _$identity);

  /// Serializes this AiSuggestionItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AiSuggestionItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionItemDto&&(identical(other.flightId, _this.flightId) || other.flightId == _this.flightId)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AiSuggestionItemDto;
  return Object.hash(runtimeType,_this.flightId,_this.reason);
}

@override
String toString() {
  final _this = this as AiSuggestionItemDto;
  return 'AiSuggestionItemDto(flightId: ${_this.flightId}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $AiSuggestionItemDtoCopyWith<$Res>  {
  factory $AiSuggestionItemDtoCopyWith(AiSuggestionItemDto value, $Res Function(AiSuggestionItemDto) _then) = _$AiSuggestionItemDtoCopyWithImpl;
@useResult
$Res call({
 int flightId, String reason
});




}
/// @nodoc
class _$AiSuggestionItemDtoCopyWithImpl<$Res>
    implements $AiSuggestionItemDtoCopyWith<$Res> {
  _$AiSuggestionItemDtoCopyWithImpl(this._self, this._then);

  final AiSuggestionItemDto _self;
  final $Res Function(AiSuggestionItemDto) _then;

/// Create a copy of AiSuggestionItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flightId = null,Object? reason = null,}) {
  return _then(AiSuggestionItemDto(
flightId: null == flightId ? _self.flightId : flightId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiSuggestionItemDto].
extension AiSuggestionItemDtoPatterns on AiSuggestionItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiSuggestionItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiSuggestionItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiSuggestionItemDto value)  $default,){
final _that = this;
switch (_that) {
case _AiSuggestionItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiSuggestionItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _AiSuggestionItemDto() when $default != null:
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
case _AiSuggestionItemDto() when $default != null:
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
case _AiSuggestionItemDto():
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
case _AiSuggestionItemDto() when $default != null:
return $default(_that.flightId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiSuggestionItemDto extends AiSuggestionItemDto {
  const _AiSuggestionItemDto({required this.flightId, required this.reason}): super._();
  factory _AiSuggestionItemDto.fromJson(Map<String, dynamic> json) => _$AiSuggestionItemDtoFromJson(json);

@override final  int flightId;
@override final  String reason;

/// Create a copy of AiSuggestionItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiSuggestionItemDtoCopyWith<_AiSuggestionItemDto> get copyWith => __$AiSuggestionItemDtoCopyWithImpl<_AiSuggestionItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiSuggestionItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiSuggestionItemDto&&(identical(other.flightId, flightId) || other.flightId == flightId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,flightId,reason);
}

@override
String toString() {
    return 'AiSuggestionItemDto(flightId: $flightId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$AiSuggestionItemDtoCopyWith<$Res> implements $AiSuggestionItemDtoCopyWith<$Res> {
  factory _$AiSuggestionItemDtoCopyWith(_AiSuggestionItemDto value, $Res Function(_AiSuggestionItemDto) _then) = __$AiSuggestionItemDtoCopyWithImpl;
@override @useResult
$Res call({
 int flightId, String reason
});




}
/// @nodoc
class __$AiSuggestionItemDtoCopyWithImpl<$Res>
    implements _$AiSuggestionItemDtoCopyWith<$Res> {
  __$AiSuggestionItemDtoCopyWithImpl(this._self, this._then);

  final _AiSuggestionItemDto _self;
  final $Res Function(_AiSuggestionItemDto) _then;

/// Create a copy of AiSuggestionItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flightId = null,Object? reason = null,}) {
  return _then(_AiSuggestionItemDto(
flightId: null == flightId ? _self.flightId : flightId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
