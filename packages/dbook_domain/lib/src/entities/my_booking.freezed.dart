// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyBooking {

 int get id; BookingStatus get status; Flight get flight; Seat get seat;
/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyBookingCopyWith<MyBooking> get copyWith => _$MyBookingCopyWithImpl<MyBooking>(this as MyBooking, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MyBooking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyBooking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.flight, _this.flight) || other.flight == _this.flight)&&(identical(other.seat, _this.seat) || other.seat == _this.seat));
}


@override
int get hashCode {
  final _this = this as MyBooking;
  return Object.hash(runtimeType,_this.id,_this.status,_this.flight,_this.seat);
}

@override
String toString() {
  final _this = this as MyBooking;
  return 'MyBooking(id: ${_this.id}, status: ${_this.status}, flight: ${_this.flight}, seat: ${_this.seat})';
}


}

/// @nodoc
abstract mixin class $MyBookingCopyWith<$Res>  {
  factory $MyBookingCopyWith(MyBooking value, $Res Function(MyBooking) _then) = _$MyBookingCopyWithImpl;
@useResult
$Res call({
 int id, BookingStatus status, Flight flight, Seat seat
});


$FlightCopyWith<$Res> get flight;$SeatCopyWith<$Res> get seat;

}
/// @nodoc
class _$MyBookingCopyWithImpl<$Res>
    implements $MyBookingCopyWith<$Res> {
  _$MyBookingCopyWithImpl(this._self, this._then);

  final MyBooking _self;
  final $Res Function(MyBooking) _then;

/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? flight = null,Object? seat = null,}) {
  return _then(MyBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as Flight,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as Seat,
  ));
}
/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightCopyWith<$Res> get flight {
  
  return $FlightCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatCopyWith<$Res> get seat {
  
  return $SeatCopyWith<$Res>(_self.seat, (value) {
    return _then(_self.copyWith(seat: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyBooking].
extension MyBookingPatterns on MyBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyBooking value)  $default,){
final _that = this;
switch (_that) {
case _MyBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyBooking value)?  $default,){
final _that = this;
switch (_that) {
case _MyBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  BookingStatus status,  Flight flight,  Seat seat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyBooking() when $default != null:
return $default(_that.id,_that.status,_that.flight,_that.seat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  BookingStatus status,  Flight flight,  Seat seat)  $default,) {final _that = this;
switch (_that) {
case _MyBooking():
return $default(_that.id,_that.status,_that.flight,_that.seat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  BookingStatus status,  Flight flight,  Seat seat)?  $default,) {final _that = this;
switch (_that) {
case _MyBooking() when $default != null:
return $default(_that.id,_that.status,_that.flight,_that.seat);case _:
  return null;

}
}

}

/// @nodoc


class _MyBooking implements MyBooking {
  const _MyBooking({required this.id, required this.status, required this.flight, required this.seat});
  

@override final  int id;
@override final  BookingStatus status;
@override final  Flight flight;
@override final  Seat seat;

/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyBookingCopyWith<_MyBooking> get copyWith => __$MyBookingCopyWithImpl<_MyBooking>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.flight, flight) || other.flight == flight)&&(identical(other.seat, seat) || other.seat == seat));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,flight,seat);
}

@override
String toString() {
    return 'MyBooking(id: $id, status: $status, flight: $flight, seat: $seat)';
}


}

/// @nodoc
abstract mixin class _$MyBookingCopyWith<$Res> implements $MyBookingCopyWith<$Res> {
  factory _$MyBookingCopyWith(_MyBooking value, $Res Function(_MyBooking) _then) = __$MyBookingCopyWithImpl;
@override @useResult
$Res call({
 int id, BookingStatus status, Flight flight, Seat seat
});


@override $FlightCopyWith<$Res> get flight;@override $SeatCopyWith<$Res> get seat;

}
/// @nodoc
class __$MyBookingCopyWithImpl<$Res>
    implements _$MyBookingCopyWith<$Res> {
  __$MyBookingCopyWithImpl(this._self, this._then);

  final _MyBooking _self;
  final $Res Function(_MyBooking) _then;

/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? flight = null,Object? seat = null,}) {
  return _then(_MyBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as Flight,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as Seat,
  ));
}

/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightCopyWith<$Res> get flight {
  
  return $FlightCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}/// Create a copy of MyBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatCopyWith<$Res> get seat {
  
  return $SeatCopyWith<$Res>(_self.seat, (value) {
    return _then(_self.copyWith(seat: value));
  });
}
}

// dart format on
