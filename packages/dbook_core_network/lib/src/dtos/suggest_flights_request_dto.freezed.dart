// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggest_flights_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SuggestFlightsRequestDto {

 String get query;
/// Create a copy of SuggestFlightsRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestFlightsRequestDtoCopyWith<SuggestFlightsRequestDto> get copyWith => _$SuggestFlightsRequestDtoCopyWithImpl<SuggestFlightsRequestDto>(this as SuggestFlightsRequestDto, _$identity);

  /// Serializes this SuggestFlightsRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SuggestFlightsRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestFlightsRequestDto&&(identical(other.query, _this.query) || other.query == _this.query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SuggestFlightsRequestDto;
  return Object.hash(runtimeType,_this.query);
}

@override
String toString() {
  final _this = this as SuggestFlightsRequestDto;
  return 'SuggestFlightsRequestDto(query: ${_this.query})';
}


}

/// @nodoc
abstract mixin class $SuggestFlightsRequestDtoCopyWith<$Res>  {
  factory $SuggestFlightsRequestDtoCopyWith(SuggestFlightsRequestDto value, $Res Function(SuggestFlightsRequestDto) _then) = _$SuggestFlightsRequestDtoCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SuggestFlightsRequestDtoCopyWithImpl<$Res>
    implements $SuggestFlightsRequestDtoCopyWith<$Res> {
  _$SuggestFlightsRequestDtoCopyWithImpl(this._self, this._then);

  final SuggestFlightsRequestDto _self;
  final $Res Function(SuggestFlightsRequestDto) _then;

/// Create a copy of SuggestFlightsRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,}) {
  return _then(SuggestFlightsRequestDto(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestFlightsRequestDto].
extension SuggestFlightsRequestDtoPatterns on SuggestFlightsRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestFlightsRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestFlightsRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestFlightsRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto() when $default != null:
return $default(_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query)  $default,) {final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto():
return $default(_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query)?  $default,) {final _that = this;
switch (_that) {
case _SuggestFlightsRequestDto() when $default != null:
return $default(_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SuggestFlightsRequestDto implements SuggestFlightsRequestDto {
  const _SuggestFlightsRequestDto({required this.query});
  factory _SuggestFlightsRequestDto.fromJson(Map<String, dynamic> json) => _$SuggestFlightsRequestDtoFromJson(json);

@override final  String query;

/// Create a copy of SuggestFlightsRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestFlightsRequestDtoCopyWith<_SuggestFlightsRequestDto> get copyWith => __$SuggestFlightsRequestDtoCopyWithImpl<_SuggestFlightsRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestFlightsRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestFlightsRequestDto&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,query);
}

@override
String toString() {
    return 'SuggestFlightsRequestDto(query: $query)';
}


}

/// @nodoc
abstract mixin class _$SuggestFlightsRequestDtoCopyWith<$Res> implements $SuggestFlightsRequestDtoCopyWith<$Res> {
  factory _$SuggestFlightsRequestDtoCopyWith(_SuggestFlightsRequestDto value, $Res Function(_SuggestFlightsRequestDto) _then) = __$SuggestFlightsRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String query
});




}
/// @nodoc
class __$SuggestFlightsRequestDtoCopyWithImpl<$Res>
    implements _$SuggestFlightsRequestDtoCopyWith<$Res> {
  __$SuggestFlightsRequestDtoCopyWithImpl(this._self, this._then);

  final _SuggestFlightsRequestDto _self;
  final $Res Function(_SuggestFlightsRequestDto) _then;

/// Create a copy of SuggestFlightsRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_SuggestFlightsRequestDto(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
