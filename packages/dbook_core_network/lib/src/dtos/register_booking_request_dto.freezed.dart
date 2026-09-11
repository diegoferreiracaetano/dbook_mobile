// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_booking_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterBookingRequestDto {

 int get bookableId; int get seatId;
/// Create a copy of RegisterBookingRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterBookingRequestDtoCopyWith<RegisterBookingRequestDto> get copyWith => _$RegisterBookingRequestDtoCopyWithImpl<RegisterBookingRequestDto>(this as RegisterBookingRequestDto, _$identity);

  /// Serializes this RegisterBookingRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterBookingRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterBookingRequestDto&&(identical(other.bookableId, _this.bookableId) || other.bookableId == _this.bookableId)&&(identical(other.seatId, _this.seatId) || other.seatId == _this.seatId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterBookingRequestDto;
  return Object.hash(runtimeType,_this.bookableId,_this.seatId);
}

@override
String toString() {
  final _this = this as RegisterBookingRequestDto;
  return 'RegisterBookingRequestDto(bookableId: ${_this.bookableId}, seatId: ${_this.seatId})';
}


}

/// @nodoc
abstract mixin class $RegisterBookingRequestDtoCopyWith<$Res>  {
  factory $RegisterBookingRequestDtoCopyWith(RegisterBookingRequestDto value, $Res Function(RegisterBookingRequestDto) _then) = _$RegisterBookingRequestDtoCopyWithImpl;
@useResult
$Res call({
 int bookableId, int seatId
});




}
/// @nodoc
class _$RegisterBookingRequestDtoCopyWithImpl<$Res>
    implements $RegisterBookingRequestDtoCopyWith<$Res> {
  _$RegisterBookingRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterBookingRequestDto _self;
  final $Res Function(RegisterBookingRequestDto) _then;

/// Create a copy of RegisterBookingRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookableId = null,Object? seatId = null,}) {
  return _then(RegisterBookingRequestDto(
bookableId: null == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int,seatId: null == seatId ? _self.seatId : seatId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterBookingRequestDto].
extension RegisterBookingRequestDtoPatterns on RegisterBookingRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterBookingRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterBookingRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterBookingRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterBookingRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterBookingRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterBookingRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookableId,  int seatId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterBookingRequestDto() when $default != null:
return $default(_that.bookableId,_that.seatId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookableId,  int seatId)  $default,) {final _that = this;
switch (_that) {
case _RegisterBookingRequestDto():
return $default(_that.bookableId,_that.seatId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookableId,  int seatId)?  $default,) {final _that = this;
switch (_that) {
case _RegisterBookingRequestDto() when $default != null:
return $default(_that.bookableId,_that.seatId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterBookingRequestDto implements RegisterBookingRequestDto {
  const _RegisterBookingRequestDto({required this.bookableId, required this.seatId});
  factory _RegisterBookingRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterBookingRequestDtoFromJson(json);

@override final  int bookableId;
@override final  int seatId;

/// Create a copy of RegisterBookingRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterBookingRequestDtoCopyWith<_RegisterBookingRequestDto> get copyWith => __$RegisterBookingRequestDtoCopyWithImpl<_RegisterBookingRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterBookingRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterBookingRequestDto&&(identical(other.bookableId, bookableId) || other.bookableId == bookableId)&&(identical(other.seatId, seatId) || other.seatId == seatId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookableId,seatId);
}

@override
String toString() {
    return 'RegisterBookingRequestDto(bookableId: $bookableId, seatId: $seatId)';
}


}

/// @nodoc
abstract mixin class _$RegisterBookingRequestDtoCopyWith<$Res> implements $RegisterBookingRequestDtoCopyWith<$Res> {
  factory _$RegisterBookingRequestDtoCopyWith(_RegisterBookingRequestDto value, $Res Function(_RegisterBookingRequestDto) _then) = __$RegisterBookingRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 int bookableId, int seatId
});




}
/// @nodoc
class __$RegisterBookingRequestDtoCopyWithImpl<$Res>
    implements _$RegisterBookingRequestDtoCopyWith<$Res> {
  __$RegisterBookingRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterBookingRequestDto _self;
  final $Res Function(_RegisterBookingRequestDto) _then;

/// Create a copy of RegisterBookingRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookableId = null,Object? seatId = null,}) {
  return _then(_RegisterBookingRequestDto(
bookableId: null == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int,seatId: null == seatId ? _self.seatId : seatId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
