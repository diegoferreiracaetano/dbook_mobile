// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Destination {

 String get iataCode; String get city; String get country; String get photoUrl; double? get lowestPrice;
/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DestinationCopyWith<Destination> get copyWith => _$DestinationCopyWithImpl<Destination>(this as Destination, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Destination;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Destination&&(identical(other.iataCode, _this.iataCode) || other.iataCode == _this.iataCode)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.lowestPrice, _this.lowestPrice) || other.lowestPrice == _this.lowestPrice));
}


@override
int get hashCode {
  final _this = this as Destination;
  return Object.hash(runtimeType,_this.iataCode,_this.city,_this.country,_this.photoUrl,_this.lowestPrice);
}

@override
String toString() {
  final _this = this as Destination;
  return 'Destination(iataCode: ${_this.iataCode}, city: ${_this.city}, country: ${_this.country}, photoUrl: ${_this.photoUrl}, lowestPrice: ${_this.lowestPrice})';
}


}

/// @nodoc
abstract mixin class $DestinationCopyWith<$Res>  {
  factory $DestinationCopyWith(Destination value, $Res Function(Destination) _then) = _$DestinationCopyWithImpl;
@useResult
$Res call({
 String iataCode, String city, String country, String photoUrl, double? lowestPrice
});




}
/// @nodoc
class _$DestinationCopyWithImpl<$Res>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._self, this._then);

  final Destination _self;
  final $Res Function(Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iataCode = null,Object? city = null,Object? country = null,Object? photoUrl = null,Object? lowestPrice = freezed,}) {
  return _then(Destination(
iataCode: null == iataCode ? _self.iataCode : iataCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,lowestPrice: freezed == lowestPrice ? _self.lowestPrice : lowestPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Destination].
extension DestinationPatterns on Destination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Destination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Destination value)  $default,){
final _that = this;
switch (_that) {
case _Destination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Destination value)?  $default,){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String iataCode,  String city,  String country,  String photoUrl,  double? lowestPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.iataCode,_that.city,_that.country,_that.photoUrl,_that.lowestPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String iataCode,  String city,  String country,  String photoUrl,  double? lowestPrice)  $default,) {final _that = this;
switch (_that) {
case _Destination():
return $default(_that.iataCode,_that.city,_that.country,_that.photoUrl,_that.lowestPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String iataCode,  String city,  String country,  String photoUrl,  double? lowestPrice)?  $default,) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.iataCode,_that.city,_that.country,_that.photoUrl,_that.lowestPrice);case _:
  return null;

}
}

}

/// @nodoc


class _Destination extends Destination {
  const _Destination({required this.iataCode, required this.city, required this.country, required this.photoUrl, this.lowestPrice}): super._();
  

@override final  String iataCode;
@override final  String city;
@override final  String country;
@override final  String photoUrl;
@override final  double? lowestPrice;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DestinationCopyWith<_Destination> get copyWith => __$DestinationCopyWithImpl<_Destination>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Destination&&(identical(other.iataCode, iataCode) || other.iataCode == iataCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.lowestPrice, lowestPrice) || other.lowestPrice == lowestPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,iataCode,city,country,photoUrl,lowestPrice);
}

@override
String toString() {
    return 'Destination(iataCode: $iataCode, city: $city, country: $country, photoUrl: $photoUrl, lowestPrice: $lowestPrice)';
}


}

/// @nodoc
abstract mixin class _$DestinationCopyWith<$Res> implements $DestinationCopyWith<$Res> {
  factory _$DestinationCopyWith(_Destination value, $Res Function(_Destination) _then) = __$DestinationCopyWithImpl;
@override @useResult
$Res call({
 String iataCode, String city, String country, String photoUrl, double? lowestPrice
});




}
/// @nodoc
class __$DestinationCopyWithImpl<$Res>
    implements _$DestinationCopyWith<$Res> {
  __$DestinationCopyWithImpl(this._self, this._then);

  final _Destination _self;
  final $Res Function(_Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iataCode = null,Object? city = null,Object? country = null,Object? photoUrl = null,Object? lowestPrice = freezed,}) {
  return _then(_Destination(
iataCode: null == iataCode ? _self.iataCode : iataCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,lowestPrice: freezed == lowestPrice ? _self.lowestPrice : lowestPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
