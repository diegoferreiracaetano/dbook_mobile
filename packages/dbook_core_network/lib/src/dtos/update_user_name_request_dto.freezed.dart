// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_user_name_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateUserNameRequestDto {

 String get name;
/// Create a copy of UpdateUserNameRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserNameRequestDtoCopyWith<UpdateUserNameRequestDto> get copyWith => _$UpdateUserNameRequestDtoCopyWithImpl<UpdateUserNameRequestDto>(this as UpdateUserNameRequestDto, _$identity);

  /// Serializes this UpdateUserNameRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateUserNameRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserNameRequestDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateUserNameRequestDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as UpdateUserNameRequestDto;
  return 'UpdateUserNameRequestDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $UpdateUserNameRequestDtoCopyWith<$Res>  {
  factory $UpdateUserNameRequestDtoCopyWith(UpdateUserNameRequestDto value, $Res Function(UpdateUserNameRequestDto) _then) = _$UpdateUserNameRequestDtoCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$UpdateUserNameRequestDtoCopyWithImpl<$Res>
    implements $UpdateUserNameRequestDtoCopyWith<$Res> {
  _$UpdateUserNameRequestDtoCopyWithImpl(this._self, this._then);

  final UpdateUserNameRequestDto _self;
  final $Res Function(UpdateUserNameRequestDto) _then;

/// Create a copy of UpdateUserNameRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(UpdateUserNameRequestDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserNameRequestDto].
extension UpdateUserNameRequestDtoPatterns on UpdateUserNameRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserNameRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserNameRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserNameRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserNameRequestDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserNameRequestDto implements UpdateUserNameRequestDto {
  const _UpdateUserNameRequestDto({required this.name});
  factory _UpdateUserNameRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateUserNameRequestDtoFromJson(json);

@override final  String name;

/// Create a copy of UpdateUserNameRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserNameRequestDtoCopyWith<_UpdateUserNameRequestDto> get copyWith => __$UpdateUserNameRequestDtoCopyWithImpl<_UpdateUserNameRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserNameRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserNameRequestDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'UpdateUserNameRequestDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserNameRequestDtoCopyWith<$Res> implements $UpdateUserNameRequestDtoCopyWith<$Res> {
  factory _$UpdateUserNameRequestDtoCopyWith(_UpdateUserNameRequestDto value, $Res Function(_UpdateUserNameRequestDto) _then) = __$UpdateUserNameRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$UpdateUserNameRequestDtoCopyWithImpl<$Res>
    implements _$UpdateUserNameRequestDtoCopyWith<$Res> {
  __$UpdateUserNameRequestDtoCopyWithImpl(this._self, this._then);

  final _UpdateUserNameRequestDto _self;
  final $Res Function(_UpdateUserNameRequestDto) _then;

/// Create a copy of UpdateUserNameRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_UpdateUserNameRequestDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
