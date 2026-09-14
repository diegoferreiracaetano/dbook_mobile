// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_booking_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyBookingResponseDto {

 int? get id; String get status; SeatResponseDto get seat; FlightResponseDto get flight;
/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyBookingResponseDtoCopyWith<MyBookingResponseDto> get copyWith => _$MyBookingResponseDtoCopyWithImpl<MyBookingResponseDto>(this as MyBookingResponseDto, _$identity);

  /// Serializes this MyBookingResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MyBookingResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyBookingResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.seat, _this.seat) || other.seat == _this.seat)&&(identical(other.flight, _this.flight) || other.flight == _this.flight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MyBookingResponseDto;
  return Object.hash(runtimeType,_this.id,_this.status,_this.seat,_this.flight);
}

@override
String toString() {
  final _this = this as MyBookingResponseDto;
  return 'MyBookingResponseDto(id: ${_this.id}, status: ${_this.status}, seat: ${_this.seat}, flight: ${_this.flight})';
}


}

/// @nodoc
abstract mixin class $MyBookingResponseDtoCopyWith<$Res>  {
  factory $MyBookingResponseDtoCopyWith(MyBookingResponseDto value, $Res Function(MyBookingResponseDto) _then) = _$MyBookingResponseDtoCopyWithImpl;
@useResult
$Res call({
 int? id, String status, SeatResponseDto seat, FlightResponseDto flight
});


$SeatResponseDtoCopyWith<$Res> get seat;$FlightResponseDtoCopyWith<$Res> get flight;

}
/// @nodoc
class _$MyBookingResponseDtoCopyWithImpl<$Res>
    implements $MyBookingResponseDtoCopyWith<$Res> {
  _$MyBookingResponseDtoCopyWithImpl(this._self, this._then);

  final MyBookingResponseDto _self;
  final $Res Function(MyBookingResponseDto) _then;

/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = null,Object? seat = null,Object? flight = null,}) {
  return _then(MyBookingResponseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as SeatResponseDto,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as FlightResponseDto,
  ));
}
/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatResponseDtoCopyWith<$Res> get seat {
  
  return $SeatResponseDtoCopyWith<$Res>(_self.seat, (value) {
    return _then(_self.copyWith(seat: value));
  });
}/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightResponseDtoCopyWith<$Res> get flight {
  
  return $FlightResponseDtoCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyBookingResponseDto].
extension MyBookingResponseDtoPatterns on MyBookingResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyBookingResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyBookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyBookingResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _MyBookingResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyBookingResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _MyBookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String status,  SeatResponseDto seat,  FlightResponseDto flight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyBookingResponseDto() when $default != null:
return $default(_that.id,_that.status,_that.seat,_that.flight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String status,  SeatResponseDto seat,  FlightResponseDto flight)  $default,) {final _that = this;
switch (_that) {
case _MyBookingResponseDto():
return $default(_that.id,_that.status,_that.seat,_that.flight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String status,  SeatResponseDto seat,  FlightResponseDto flight)?  $default,) {final _that = this;
switch (_that) {
case _MyBookingResponseDto() when $default != null:
return $default(_that.id,_that.status,_that.seat,_that.flight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyBookingResponseDto extends MyBookingResponseDto {
  const _MyBookingResponseDto({required this.id, required this.status, required this.seat, required this.flight}): super._();
  factory _MyBookingResponseDto.fromJson(Map<String, dynamic> json) => _$MyBookingResponseDtoFromJson(json);

@override final  int? id;
@override final  String status;
@override final  SeatResponseDto seat;
@override final  FlightResponseDto flight;

/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyBookingResponseDtoCopyWith<_MyBookingResponseDto> get copyWith => __$MyBookingResponseDtoCopyWithImpl<_MyBookingResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyBookingResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyBookingResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.seat, seat) || other.seat == seat)&&(identical(other.flight, flight) || other.flight == flight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,seat,flight);
}

@override
String toString() {
    return 'MyBookingResponseDto(id: $id, status: $status, seat: $seat, flight: $flight)';
}


}

/// @nodoc
abstract mixin class _$MyBookingResponseDtoCopyWith<$Res> implements $MyBookingResponseDtoCopyWith<$Res> {
  factory _$MyBookingResponseDtoCopyWith(_MyBookingResponseDto value, $Res Function(_MyBookingResponseDto) _then) = __$MyBookingResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, String status, SeatResponseDto seat, FlightResponseDto flight
});


@override $SeatResponseDtoCopyWith<$Res> get seat;@override $FlightResponseDtoCopyWith<$Res> get flight;

}
/// @nodoc
class __$MyBookingResponseDtoCopyWithImpl<$Res>
    implements _$MyBookingResponseDtoCopyWith<$Res> {
  __$MyBookingResponseDtoCopyWithImpl(this._self, this._then);

  final _MyBookingResponseDto _self;
  final $Res Function(_MyBookingResponseDto) _then;

/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = null,Object? seat = null,Object? flight = null,}) {
  return _then(_MyBookingResponseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as SeatResponseDto,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as FlightResponseDto,
  ));
}

/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatResponseDtoCopyWith<$Res> get seat {
  
  return $SeatResponseDtoCopyWith<$Res>(_self.seat, (value) {
    return _then(_self.copyWith(seat: value));
  });
}/// Create a copy of MyBookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightResponseDtoCopyWith<$Res> get flight {
  
  return $FlightResponseDtoCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}
}

// dart format on
