// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Flight {

 int get id; String get flightNumber; String get airlineIataCode; String get airlineName; String get originIataCode; String get destinationIataCode; DateTime get departureTime; DateTime get arrivalTime; SeatClass get seatClass; double get price; int get availableCapacity;
/// Create a copy of Flight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlightCopyWith<Flight> get copyWith => _$FlightCopyWithImpl<Flight>(this as Flight, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Flight;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Flight&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.flightNumber, _this.flightNumber) || other.flightNumber == _this.flightNumber)&&(identical(other.airlineIataCode, _this.airlineIataCode) || other.airlineIataCode == _this.airlineIataCode)&&(identical(other.airlineName, _this.airlineName) || other.airlineName == _this.airlineName)&&(identical(other.originIataCode, _this.originIataCode) || other.originIataCode == _this.originIataCode)&&(identical(other.destinationIataCode, _this.destinationIataCode) || other.destinationIataCode == _this.destinationIataCode)&&(identical(other.departureTime, _this.departureTime) || other.departureTime == _this.departureTime)&&(identical(other.arrivalTime, _this.arrivalTime) || other.arrivalTime == _this.arrivalTime)&&(identical(other.seatClass, _this.seatClass) || other.seatClass == _this.seatClass)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.availableCapacity, _this.availableCapacity) || other.availableCapacity == _this.availableCapacity));
}


@override
int get hashCode {
  final _this = this as Flight;
  return Object.hash(runtimeType,_this.id,_this.flightNumber,_this.airlineIataCode,_this.airlineName,_this.originIataCode,_this.destinationIataCode,_this.departureTime,_this.arrivalTime,_this.seatClass,_this.price,_this.availableCapacity);
}

@override
String toString() {
  final _this = this as Flight;
  return 'Flight(id: ${_this.id}, flightNumber: ${_this.flightNumber}, airlineIataCode: ${_this.airlineIataCode}, airlineName: ${_this.airlineName}, originIataCode: ${_this.originIataCode}, destinationIataCode: ${_this.destinationIataCode}, departureTime: ${_this.departureTime}, arrivalTime: ${_this.arrivalTime}, seatClass: ${_this.seatClass}, price: ${_this.price}, availableCapacity: ${_this.availableCapacity})';
}


}

/// @nodoc
abstract mixin class $FlightCopyWith<$Res>  {
  factory $FlightCopyWith(Flight value, $Res Function(Flight) _then) = _$FlightCopyWithImpl;
@useResult
$Res call({
 int id, String flightNumber, String airlineIataCode, String airlineName, String originIataCode, String destinationIataCode, DateTime departureTime, DateTime arrivalTime, SeatClass seatClass, double price, int availableCapacity
});




}
/// @nodoc
class _$FlightCopyWithImpl<$Res>
    implements $FlightCopyWith<$Res> {
  _$FlightCopyWithImpl(this._self, this._then);

  final Flight _self;
  final $Res Function(Flight) _then;

/// Create a copy of Flight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? flightNumber = null,Object? airlineIataCode = null,Object? airlineName = null,Object? originIataCode = null,Object? destinationIataCode = null,Object? departureTime = null,Object? arrivalTime = null,Object? seatClass = null,Object? price = null,Object? availableCapacity = null,}) {
  return _then(Flight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,airlineIataCode: null == airlineIataCode ? _self.airlineIataCode : airlineIataCode // ignore: cast_nullable_to_non_nullable
as String,airlineName: null == airlineName ? _self.airlineName : airlineName // ignore: cast_nullable_to_non_nullable
as String,originIataCode: null == originIataCode ? _self.originIataCode : originIataCode // ignore: cast_nullable_to_non_nullable
as String,destinationIataCode: null == destinationIataCode ? _self.destinationIataCode : destinationIataCode // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime,seatClass: null == seatClass ? _self.seatClass : seatClass // ignore: cast_nullable_to_non_nullable
as SeatClass,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,availableCapacity: null == availableCapacity ? _self.availableCapacity : availableCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Flight].
extension FlightPatterns on Flight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Flight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Flight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Flight value)  $default,){
final _that = this;
switch (_that) {
case _Flight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Flight value)?  $default,){
final _that = this;
switch (_that) {
case _Flight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String originIataCode,  String destinationIataCode,  DateTime departureTime,  DateTime arrivalTime,  SeatClass seatClass,  double price,  int availableCapacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Flight() when $default != null:
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.originIataCode,_that.destinationIataCode,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String originIataCode,  String destinationIataCode,  DateTime departureTime,  DateTime arrivalTime,  SeatClass seatClass,  double price,  int availableCapacity)  $default,) {final _that = this;
switch (_that) {
case _Flight():
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.originIataCode,_that.destinationIataCode,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String originIataCode,  String destinationIataCode,  DateTime departureTime,  DateTime arrivalTime,  SeatClass seatClass,  double price,  int availableCapacity)?  $default,) {final _that = this;
switch (_that) {
case _Flight() when $default != null:
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.originIataCode,_that.destinationIataCode,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
  return null;

}
}

}

/// @nodoc


class _Flight implements Flight {
  const _Flight({required this.id, required this.flightNumber, required this.airlineIataCode, required this.airlineName, required this.originIataCode, required this.destinationIataCode, required this.departureTime, required this.arrivalTime, required this.seatClass, required this.price, required this.availableCapacity});
  

@override final  int id;
@override final  String flightNumber;
@override final  String airlineIataCode;
@override final  String airlineName;
@override final  String originIataCode;
@override final  String destinationIataCode;
@override final  DateTime departureTime;
@override final  DateTime arrivalTime;
@override final  SeatClass seatClass;
@override final  double price;
@override final  int availableCapacity;

/// Create a copy of Flight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlightCopyWith<_Flight> get copyWith => __$FlightCopyWithImpl<_Flight>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Flight&&(identical(other.id, id) || other.id == id)&&(identical(other.flightNumber, flightNumber) || other.flightNumber == flightNumber)&&(identical(other.airlineIataCode, airlineIataCode) || other.airlineIataCode == airlineIataCode)&&(identical(other.airlineName, airlineName) || other.airlineName == airlineName)&&(identical(other.originIataCode, originIataCode) || other.originIataCode == originIataCode)&&(identical(other.destinationIataCode, destinationIataCode) || other.destinationIataCode == destinationIataCode)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.seatClass, seatClass) || other.seatClass == seatClass)&&(identical(other.price, price) || other.price == price)&&(identical(other.availableCapacity, availableCapacity) || other.availableCapacity == availableCapacity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,flightNumber,airlineIataCode,airlineName,originIataCode,destinationIataCode,departureTime,arrivalTime,seatClass,price,availableCapacity);
}

@override
String toString() {
    return 'Flight(id: $id, flightNumber: $flightNumber, airlineIataCode: $airlineIataCode, airlineName: $airlineName, originIataCode: $originIataCode, destinationIataCode: $destinationIataCode, departureTime: $departureTime, arrivalTime: $arrivalTime, seatClass: $seatClass, price: $price, availableCapacity: $availableCapacity)';
}


}

/// @nodoc
abstract mixin class _$FlightCopyWith<$Res> implements $FlightCopyWith<$Res> {
  factory _$FlightCopyWith(_Flight value, $Res Function(_Flight) _then) = __$FlightCopyWithImpl;
@override @useResult
$Res call({
 int id, String flightNumber, String airlineIataCode, String airlineName, String originIataCode, String destinationIataCode, DateTime departureTime, DateTime arrivalTime, SeatClass seatClass, double price, int availableCapacity
});




}
/// @nodoc
class __$FlightCopyWithImpl<$Res>
    implements _$FlightCopyWith<$Res> {
  __$FlightCopyWithImpl(this._self, this._then);

  final _Flight _self;
  final $Res Function(_Flight) _then;

/// Create a copy of Flight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? flightNumber = null,Object? airlineIataCode = null,Object? airlineName = null,Object? originIataCode = null,Object? destinationIataCode = null,Object? departureTime = null,Object? arrivalTime = null,Object? seatClass = null,Object? price = null,Object? availableCapacity = null,}) {
  return _then(_Flight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,airlineIataCode: null == airlineIataCode ? _self.airlineIataCode : airlineIataCode // ignore: cast_nullable_to_non_nullable
as String,airlineName: null == airlineName ? _self.airlineName : airlineName // ignore: cast_nullable_to_non_nullable
as String,originIataCode: null == originIataCode ? _self.originIataCode : originIataCode // ignore: cast_nullable_to_non_nullable
as String,destinationIataCode: null == destinationIataCode ? _self.destinationIataCode : destinationIataCode // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime,seatClass: null == seatClass ? _self.seatClass : seatClass // ignore: cast_nullable_to_non_nullable
as SeatClass,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,availableCapacity: null == availableCapacity ? _self.availableCapacity : availableCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
