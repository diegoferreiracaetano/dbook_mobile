// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_payment_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterPaymentRequestDto {

 List<int> get bookingIds; String get cardLast4; String get cardholderName;
/// Create a copy of RegisterPaymentRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterPaymentRequestDtoCopyWith<RegisterPaymentRequestDto> get copyWith => _$RegisterPaymentRequestDtoCopyWithImpl<RegisterPaymentRequestDto>(this as RegisterPaymentRequestDto, _$identity);

  /// Serializes this RegisterPaymentRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterPaymentRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterPaymentRequestDto&&const DeepCollectionEquality().equals(other.bookingIds, _this.bookingIds)&&(identical(other.cardLast4, _this.cardLast4) || other.cardLast4 == _this.cardLast4)&&(identical(other.cardholderName, _this.cardholderName) || other.cardholderName == _this.cardholderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterPaymentRequestDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.bookingIds),_this.cardLast4,_this.cardholderName);
}

@override
String toString() {
  final _this = this as RegisterPaymentRequestDto;
  return 'RegisterPaymentRequestDto(bookingIds: ${_this.bookingIds}, cardLast4: ${_this.cardLast4}, cardholderName: ${_this.cardholderName})';
}


}

/// @nodoc
abstract mixin class $RegisterPaymentRequestDtoCopyWith<$Res>  {
  factory $RegisterPaymentRequestDtoCopyWith(RegisterPaymentRequestDto value, $Res Function(RegisterPaymentRequestDto) _then) = _$RegisterPaymentRequestDtoCopyWithImpl;
@useResult
$Res call({
 List<int> bookingIds, String cardLast4, String cardholderName
});




}
/// @nodoc
class _$RegisterPaymentRequestDtoCopyWithImpl<$Res>
    implements $RegisterPaymentRequestDtoCopyWith<$Res> {
  _$RegisterPaymentRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterPaymentRequestDto _self;
  final $Res Function(RegisterPaymentRequestDto) _then;

/// Create a copy of RegisterPaymentRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingIds = null,Object? cardLast4 = null,Object? cardholderName = null,}) {
  return _then(RegisterPaymentRequestDto(
bookingIds: null == bookingIds ? _self.bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<int>,cardLast4: null == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String,cardholderName: null == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterPaymentRequestDto].
extension RegisterPaymentRequestDtoPatterns on RegisterPaymentRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterPaymentRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterPaymentRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterPaymentRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> bookingIds,  String cardLast4,  String cardholderName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto() when $default != null:
return $default(_that.bookingIds,_that.cardLast4,_that.cardholderName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> bookingIds,  String cardLast4,  String cardholderName)  $default,) {final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto():
return $default(_that.bookingIds,_that.cardLast4,_that.cardholderName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> bookingIds,  String cardLast4,  String cardholderName)?  $default,) {final _that = this;
switch (_that) {
case _RegisterPaymentRequestDto() when $default != null:
return $default(_that.bookingIds,_that.cardLast4,_that.cardholderName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterPaymentRequestDto implements RegisterPaymentRequestDto {
  const _RegisterPaymentRequestDto({required  List<int> bookingIds, required this.cardLast4, required this.cardholderName}): _bookingIds = bookingIds;
  factory _RegisterPaymentRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterPaymentRequestDtoFromJson(json);

 final  List<int> _bookingIds;
@override List<int> get bookingIds {
  if (_bookingIds is EqualUnmodifiableListView) return _bookingIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookingIds);
}

@override final  String cardLast4;
@override final  String cardholderName;

/// Create a copy of RegisterPaymentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterPaymentRequestDtoCopyWith<_RegisterPaymentRequestDto> get copyWith => __$RegisterPaymentRequestDtoCopyWithImpl<_RegisterPaymentRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterPaymentRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterPaymentRequestDto&&const DeepCollectionEquality().equals(other.bookingIds, _bookingIds)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.cardholderName, cardholderName) || other.cardholderName == cardholderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookingIds),cardLast4,cardholderName);
}

@override
String toString() {
    return 'RegisterPaymentRequestDto(bookingIds: $bookingIds, cardLast4: $cardLast4, cardholderName: $cardholderName)';
}


}

/// @nodoc
abstract mixin class _$RegisterPaymentRequestDtoCopyWith<$Res> implements $RegisterPaymentRequestDtoCopyWith<$Res> {
  factory _$RegisterPaymentRequestDtoCopyWith(_RegisterPaymentRequestDto value, $Res Function(_RegisterPaymentRequestDto) _then) = __$RegisterPaymentRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<int> bookingIds, String cardLast4, String cardholderName
});




}
/// @nodoc
class __$RegisterPaymentRequestDtoCopyWithImpl<$Res>
    implements _$RegisterPaymentRequestDtoCopyWith<$Res> {
  __$RegisterPaymentRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterPaymentRequestDto _self;
  final $Res Function(_RegisterPaymentRequestDto) _then;

/// Create a copy of RegisterPaymentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingIds = null,Object? cardLast4 = null,Object? cardholderName = null,}) {
  return _then(_RegisterPaymentRequestDto(
bookingIds: null == bookingIds ? _self._bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<int>,cardLast4: null == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String,cardholderName: null == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
