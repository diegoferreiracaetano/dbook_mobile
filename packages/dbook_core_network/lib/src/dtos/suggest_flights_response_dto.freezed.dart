// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggest_flights_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SuggestFlightsResponseDto {

 List<AiSuggestionItemDto> get suggestions;
/// Create a copy of SuggestFlightsResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestFlightsResponseDtoCopyWith<SuggestFlightsResponseDto> get copyWith => _$SuggestFlightsResponseDtoCopyWithImpl<SuggestFlightsResponseDto>(this as SuggestFlightsResponseDto, _$identity);

  /// Serializes this SuggestFlightsResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SuggestFlightsResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestFlightsResponseDto&&const DeepCollectionEquality().equals(other.suggestions, _this.suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SuggestFlightsResponseDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.suggestions));
}

@override
String toString() {
  final _this = this as SuggestFlightsResponseDto;
  return 'SuggestFlightsResponseDto(suggestions: ${_this.suggestions})';
}


}

/// @nodoc
abstract mixin class $SuggestFlightsResponseDtoCopyWith<$Res>  {
  factory $SuggestFlightsResponseDtoCopyWith(SuggestFlightsResponseDto value, $Res Function(SuggestFlightsResponseDto) _then) = _$SuggestFlightsResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<AiSuggestionItemDto> suggestions
});




}
/// @nodoc
class _$SuggestFlightsResponseDtoCopyWithImpl<$Res>
    implements $SuggestFlightsResponseDtoCopyWith<$Res> {
  _$SuggestFlightsResponseDtoCopyWithImpl(this._self, this._then);

  final SuggestFlightsResponseDto _self;
  final $Res Function(SuggestFlightsResponseDto) _then;

/// Create a copy of SuggestFlightsResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? suggestions = null,}) {
  return _then(SuggestFlightsResponseDto(
suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<AiSuggestionItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestFlightsResponseDto].
extension SuggestFlightsResponseDtoPatterns on SuggestFlightsResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestFlightsResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestFlightsResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestFlightsResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AiSuggestionItemDto> suggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto() when $default != null:
return $default(_that.suggestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AiSuggestionItemDto> suggestions)  $default,) {final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto():
return $default(_that.suggestions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AiSuggestionItemDto> suggestions)?  $default,) {final _that = this;
switch (_that) {
case _SuggestFlightsResponseDto() when $default != null:
return $default(_that.suggestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SuggestFlightsResponseDto implements SuggestFlightsResponseDto {
  const _SuggestFlightsResponseDto({required  List<AiSuggestionItemDto> suggestions}): _suggestions = suggestions;
  factory _SuggestFlightsResponseDto.fromJson(Map<String, dynamic> json) => _$SuggestFlightsResponseDtoFromJson(json);

 final  List<AiSuggestionItemDto> _suggestions;
@override List<AiSuggestionItemDto> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


/// Create a copy of SuggestFlightsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestFlightsResponseDtoCopyWith<_SuggestFlightsResponseDto> get copyWith => __$SuggestFlightsResponseDtoCopyWithImpl<_SuggestFlightsResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestFlightsResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestFlightsResponseDto&&const DeepCollectionEquality().equals(other.suggestions, _suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_suggestions));
}

@override
String toString() {
    return 'SuggestFlightsResponseDto(suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class _$SuggestFlightsResponseDtoCopyWith<$Res> implements $SuggestFlightsResponseDtoCopyWith<$Res> {
  factory _$SuggestFlightsResponseDtoCopyWith(_SuggestFlightsResponseDto value, $Res Function(_SuggestFlightsResponseDto) _then) = __$SuggestFlightsResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<AiSuggestionItemDto> suggestions
});




}
/// @nodoc
class __$SuggestFlightsResponseDtoCopyWithImpl<$Res>
    implements _$SuggestFlightsResponseDtoCopyWith<$Res> {
  __$SuggestFlightsResponseDtoCopyWithImpl(this._self, this._then);

  final _SuggestFlightsResponseDto _self;
  final $Res Function(_SuggestFlightsResponseDto) _then;

/// Create a copy of SuggestFlightsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? suggestions = null,}) {
  return _then(_SuggestFlightsResponseDto(
suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<AiSuggestionItemDto>,
  ));
}


}

// dart format on
