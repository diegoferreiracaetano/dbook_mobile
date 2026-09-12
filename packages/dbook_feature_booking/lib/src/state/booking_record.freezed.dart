// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingRecord {

 Booking get booking; Flight get flight; Seat get seat;
/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingRecordCopyWith<BookingRecord> get copyWith => _$BookingRecordCopyWithImpl<BookingRecord>(this as BookingRecord, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BookingRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingRecord&&(identical(other.booking, _this.booking) || other.booking == _this.booking)&&(identical(other.flight, _this.flight) || other.flight == _this.flight)&&(identical(other.seat, _this.seat) || other.seat == _this.seat));
}


@override
int get hashCode {
  final _this = this as BookingRecord;
  return Object.hash(runtimeType,_this.booking,_this.flight,_this.seat);
}

@override
String toString() {
  final _this = this as BookingRecord;
  return 'BookingRecord(booking: ${_this.booking}, flight: ${_this.flight}, seat: ${_this.seat})';
}


}

/// @nodoc
abstract mixin class $BookingRecordCopyWith<$Res>  {
  factory $BookingRecordCopyWith(BookingRecord value, $Res Function(BookingRecord) _then) = _$BookingRecordCopyWithImpl;
@useResult
$Res call({
 Booking booking, Flight flight, Seat seat
});


$BookingCopyWith<$Res> get booking;$FlightCopyWith<$Res> get flight;$SeatCopyWith<$Res> get seat;

}
/// @nodoc
class _$BookingRecordCopyWithImpl<$Res>
    implements $BookingRecordCopyWith<$Res> {
  _$BookingRecordCopyWithImpl(this._self, this._then);

  final BookingRecord _self;
  final $Res Function(BookingRecord) _then;

/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? booking = null,Object? flight = null,Object? seat = null,}) {
  return _then(BookingRecord(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as Flight,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as Seat,
  ));
}
/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res> get booking {
  
  return $BookingCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightCopyWith<$Res> get flight {
  
  return $FlightCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatCopyWith<$Res> get seat {
  
  return $SeatCopyWith<$Res>(_self.seat, (value) {
    return _then(_self.copyWith(seat: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingRecord].
extension BookingRecordPatterns on BookingRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingRecord value)  $default,){
final _that = this;
switch (_that) {
case _BookingRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingRecord value)?  $default,){
final _that = this;
switch (_that) {
case _BookingRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Booking booking,  Flight flight,  Seat seat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingRecord() when $default != null:
return $default(_that.booking,_that.flight,_that.seat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Booking booking,  Flight flight,  Seat seat)  $default,) {final _that = this;
switch (_that) {
case _BookingRecord():
return $default(_that.booking,_that.flight,_that.seat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Booking booking,  Flight flight,  Seat seat)?  $default,) {final _that = this;
switch (_that) {
case _BookingRecord() when $default != null:
return $default(_that.booking,_that.flight,_that.seat);case _:
  return null;

}
}

}

/// @nodoc


class _BookingRecord implements BookingRecord {
  const _BookingRecord({required this.booking, required this.flight, required this.seat});
  

@override final  Booking booking;
@override final  Flight flight;
@override final  Seat seat;

/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingRecordCopyWith<_BookingRecord> get copyWith => __$BookingRecordCopyWithImpl<_BookingRecord>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingRecord&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.flight, flight) || other.flight == flight)&&(identical(other.seat, seat) || other.seat == seat));
}


@override
int get hashCode {
    return Object.hash(runtimeType,booking,flight,seat);
}

@override
String toString() {
    return 'BookingRecord(booking: $booking, flight: $flight, seat: $seat)';
}


}

/// @nodoc
abstract mixin class _$BookingRecordCopyWith<$Res> implements $BookingRecordCopyWith<$Res> {
  factory _$BookingRecordCopyWith(_BookingRecord value, $Res Function(_BookingRecord) _then) = __$BookingRecordCopyWithImpl;
@override @useResult
$Res call({
 Booking booking, Flight flight, Seat seat
});


@override $BookingCopyWith<$Res> get booking;@override $FlightCopyWith<$Res> get flight;@override $SeatCopyWith<$Res> get seat;

}
/// @nodoc
class __$BookingRecordCopyWithImpl<$Res>
    implements _$BookingRecordCopyWith<$Res> {
  __$BookingRecordCopyWithImpl(this._self, this._then);

  final _BookingRecord _self;
  final $Res Function(_BookingRecord) _then;

/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? booking = null,Object? flight = null,Object? seat = null,}) {
  return _then(_BookingRecord(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking,flight: null == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as Flight,seat: null == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as Seat,
  ));
}

/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res> get booking {
  
  return $BookingCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlightCopyWith<$Res> get flight {
  
  return $FlightCopyWith<$Res>(_self.flight, (value) {
    return _then(_self.copyWith(flight: value));
  });
}/// Create a copy of BookingRecord
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
