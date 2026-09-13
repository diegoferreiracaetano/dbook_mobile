// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flight_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FlightResponseDto {

 int get id; String get flightNumber; String get airlineIataCode; String get airlineName; String get origin; String get destination; String get departureTime; String get arrivalTime; String get seatClass; double get price; int get availableCapacity;
/// Create a copy of FlightResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlightResponseDtoCopyWith<FlightResponseDto> get copyWith => _$FlightResponseDtoCopyWithImpl<FlightResponseDto>(this as FlightResponseDto, _$identity);

  /// Serializes this FlightResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FlightResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.flightNumber, _this.flightNumber) || other.flightNumber == _this.flightNumber)&&(identical(other.airlineIataCode, _this.airlineIataCode) || other.airlineIataCode == _this.airlineIataCode)&&(identical(other.airlineName, _this.airlineName) || other.airlineName == _this.airlineName)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.departureTime, _this.departureTime) || other.departureTime == _this.departureTime)&&(identical(other.arrivalTime, _this.arrivalTime) || other.arrivalTime == _this.arrivalTime)&&(identical(other.seatClass, _this.seatClass) || other.seatClass == _this.seatClass)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.availableCapacity, _this.availableCapacity) || other.availableCapacity == _this.availableCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FlightResponseDto;
  return Object.hash(runtimeType,_this.id,_this.flightNumber,_this.airlineIataCode,_this.airlineName,_this.origin,_this.destination,_this.departureTime,_this.arrivalTime,_this.seatClass,_this.price,_this.availableCapacity);
}

@override
String toString() {
  final _this = this as FlightResponseDto;
  return 'FlightResponseDto(id: ${_this.id}, flightNumber: ${_this.flightNumber}, airlineIataCode: ${_this.airlineIataCode}, airlineName: ${_this.airlineName}, origin: ${_this.origin}, destination: ${_this.destination}, departureTime: ${_this.departureTime}, arrivalTime: ${_this.arrivalTime}, seatClass: ${_this.seatClass}, price: ${_this.price}, availableCapacity: ${_this.availableCapacity})';
}


}

/// @nodoc
abstract mixin class $FlightResponseDtoCopyWith<$Res>  {
  factory $FlightResponseDtoCopyWith(FlightResponseDto value, $Res Function(FlightResponseDto) _then) = _$FlightResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, String flightNumber, String airlineIataCode, String airlineName, String origin, String destination, String departureTime, String arrivalTime, String seatClass, double price, int availableCapacity
});




}
/// @nodoc
class _$FlightResponseDtoCopyWithImpl<$Res>
    implements $FlightResponseDtoCopyWith<$Res> {
  _$FlightResponseDtoCopyWithImpl(this._self, this._then);

  final FlightResponseDto _self;
  final $Res Function(FlightResponseDto) _then;

/// Create a copy of FlightResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? flightNumber = null,Object? airlineIataCode = null,Object? airlineName = null,Object? origin = null,Object? destination = null,Object? departureTime = null,Object? arrivalTime = null,Object? seatClass = null,Object? price = null,Object? availableCapacity = null,}) {
  return _then(FlightResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,airlineIataCode: null == airlineIataCode ? _self.airlineIataCode : airlineIataCode // ignore: cast_nullable_to_non_nullable
as String,airlineName: null == airlineName ? _self.airlineName : airlineName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as String,seatClass: null == seatClass ? _self.seatClass : seatClass // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,availableCapacity: null == availableCapacity ? _self.availableCapacity : availableCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FlightResponseDto].
extension FlightResponseDtoPatterns on FlightResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlightResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlightResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlightResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _FlightResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlightResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _FlightResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String origin,  String destination,  String departureTime,  String arrivalTime,  String seatClass,  double price,  int availableCapacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlightResponseDto() when $default != null:
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.origin,_that.destination,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String origin,  String destination,  String departureTime,  String arrivalTime,  String seatClass,  double price,  int availableCapacity)  $default,) {final _that = this;
switch (_that) {
case _FlightResponseDto():
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.origin,_that.destination,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String flightNumber,  String airlineIataCode,  String airlineName,  String origin,  String destination,  String departureTime,  String arrivalTime,  String seatClass,  double price,  int availableCapacity)?  $default,) {final _that = this;
switch (_that) {
case _FlightResponseDto() when $default != null:
return $default(_that.id,_that.flightNumber,_that.airlineIataCode,_that.airlineName,_that.origin,_that.destination,_that.departureTime,_that.arrivalTime,_that.seatClass,_that.price,_that.availableCapacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlightResponseDto extends FlightResponseDto {
  const _FlightResponseDto({required this.id, required this.flightNumber, required this.airlineIataCode, required this.airlineName, required this.origin, required this.destination, required this.departureTime, required this.arrivalTime, required this.seatClass, required this.price, required this.availableCapacity}): super._();
  factory _FlightResponseDto.fromJson(Map<String, dynamic> json) => _$FlightResponseDtoFromJson(json);

@override final  int id;
@override final  String flightNumber;
@override final  String airlineIataCode;
@override final  String airlineName;
@override final  String origin;
@override final  String destination;
@override final  String departureTime;
@override final  String arrivalTime;
@override final  String seatClass;
@override final  double price;
@override final  int availableCapacity;

/// Create a copy of FlightResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlightResponseDtoCopyWith<_FlightResponseDto> get copyWith => __$FlightResponseDtoCopyWithImpl<_FlightResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlightResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlightResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.flightNumber, flightNumber) || other.flightNumber == flightNumber)&&(identical(other.airlineIataCode, airlineIataCode) || other.airlineIataCode == airlineIataCode)&&(identical(other.airlineName, airlineName) || other.airlineName == airlineName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.seatClass, seatClass) || other.seatClass == seatClass)&&(identical(other.price, price) || other.price == price)&&(identical(other.availableCapacity, availableCapacity) || other.availableCapacity == availableCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,flightNumber,airlineIataCode,airlineName,origin,destination,departureTime,arrivalTime,seatClass,price,availableCapacity);
}

@override
String toString() {
    return 'FlightResponseDto(id: $id, flightNumber: $flightNumber, airlineIataCode: $airlineIataCode, airlineName: $airlineName, origin: $origin, destination: $destination, departureTime: $departureTime, arrivalTime: $arrivalTime, seatClass: $seatClass, price: $price, availableCapacity: $availableCapacity)';
}


}

/// @nodoc
abstract mixin class _$FlightResponseDtoCopyWith<$Res> implements $FlightResponseDtoCopyWith<$Res> {
  factory _$FlightResponseDtoCopyWith(_FlightResponseDto value, $Res Function(_FlightResponseDto) _then) = __$FlightResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String flightNumber, String airlineIataCode, String airlineName, String origin, String destination, String departureTime, String arrivalTime, String seatClass, double price, int availableCapacity
});




}
/// @nodoc
class __$FlightResponseDtoCopyWithImpl<$Res>
    implements _$FlightResponseDtoCopyWith<$Res> {
  __$FlightResponseDtoCopyWithImpl(this._self, this._then);

  final _FlightResponseDto _self;
  final $Res Function(_FlightResponseDto) _then;

/// Create a copy of FlightResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? flightNumber = null,Object? airlineIataCode = null,Object? airlineName = null,Object? origin = null,Object? destination = null,Object? departureTime = null,Object? arrivalTime = null,Object? seatClass = null,Object? price = null,Object? availableCapacity = null,}) {
  return _then(_FlightResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,airlineIataCode: null == airlineIataCode ? _self.airlineIataCode : airlineIataCode // ignore: cast_nullable_to_non_nullable
as String,airlineName: null == airlineName ? _self.airlineName : airlineName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as String,arrivalTime: null == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as String,seatClass: null == seatClass ? _self.seatClass : seatClass // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,availableCapacity: null == availableCapacity ? _self.availableCapacity : availableCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
