// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_user_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterUserRequestDto {

 String get email; String get password;
/// Create a copy of RegisterUserRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterUserRequestDtoCopyWith<RegisterUserRequestDto> get copyWith => _$RegisterUserRequestDtoCopyWithImpl<RegisterUserRequestDto>(this as RegisterUserRequestDto, _$identity);

  /// Serializes this RegisterUserRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterUserRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterUserRequestDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterUserRequestDto;
  return Object.hash(runtimeType,_this.email,_this.password);
}

@override
String toString() {
  final _this = this as RegisterUserRequestDto;
  return 'RegisterUserRequestDto(email: ${_this.email}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $RegisterUserRequestDtoCopyWith<$Res>  {
  factory $RegisterUserRequestDtoCopyWith(RegisterUserRequestDto value, $Res Function(RegisterUserRequestDto) _then) = _$RegisterUserRequestDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$RegisterUserRequestDtoCopyWithImpl<$Res>
    implements $RegisterUserRequestDtoCopyWith<$Res> {
  _$RegisterUserRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterUserRequestDto _self;
  final $Res Function(RegisterUserRequestDto) _then;

/// Create a copy of RegisterUserRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(RegisterUserRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterUserRequestDto].
extension RegisterUserRequestDtoPatterns on RegisterUserRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterUserRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterUserRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterUserRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterUserRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterUserRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterUserRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterUserRequestDto() when $default != null:
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _RegisterUserRequestDto():
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _RegisterUserRequestDto() when $default != null:
return $default(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterUserRequestDto implements RegisterUserRequestDto {
  const _RegisterUserRequestDto({required this.email, required this.password});
  factory _RegisterUserRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterUserRequestDtoFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of RegisterUserRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterUserRequestDtoCopyWith<_RegisterUserRequestDto> get copyWith => __$RegisterUserRequestDtoCopyWithImpl<_RegisterUserRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterUserRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterUserRequestDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password);
}

@override
String toString() {
    return 'RegisterUserRequestDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$RegisterUserRequestDtoCopyWith<$Res> implements $RegisterUserRequestDtoCopyWith<$Res> {
  factory _$RegisterUserRequestDtoCopyWith(_RegisterUserRequestDto value, $Res Function(_RegisterUserRequestDto) _then) = __$RegisterUserRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$RegisterUserRequestDtoCopyWithImpl<$Res>
    implements _$RegisterUserRequestDtoCopyWith<$Res> {
  __$RegisterUserRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterUserRequestDto _self;
  final $Res Function(_RegisterUserRequestDto) _then;

/// Create a copy of RegisterUserRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_RegisterUserRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
