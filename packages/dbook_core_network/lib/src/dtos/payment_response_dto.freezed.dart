// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentResponseDto {

 int get id; double get amount; String get cardLast4; List<int> get bookingIds; String get status;
/// Create a copy of PaymentResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentResponseDtoCopyWith<PaymentResponseDto> get copyWith => _$PaymentResponseDtoCopyWithImpl<PaymentResponseDto>(this as PaymentResponseDto, _$identity);

  /// Serializes this PaymentResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.cardLast4, _this.cardLast4) || other.cardLast4 == _this.cardLast4)&&const DeepCollectionEquality().equals(other.bookingIds, _this.bookingIds)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentResponseDto;
  return Object.hash(runtimeType,_this.id,_this.amount,_this.cardLast4,const DeepCollectionEquality().hash(_this.bookingIds),_this.status);
}

@override
String toString() {
  final _this = this as PaymentResponseDto;
  return 'PaymentResponseDto(id: ${_this.id}, amount: ${_this.amount}, cardLast4: ${_this.cardLast4}, bookingIds: ${_this.bookingIds}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $PaymentResponseDtoCopyWith<$Res>  {
  factory $PaymentResponseDtoCopyWith(PaymentResponseDto value, $Res Function(PaymentResponseDto) _then) = _$PaymentResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, double amount, String cardLast4, List<int> bookingIds, String status
});




}
/// @nodoc
class _$PaymentResponseDtoCopyWithImpl<$Res>
    implements $PaymentResponseDtoCopyWith<$Res> {
  _$PaymentResponseDtoCopyWithImpl(this._self, this._then);

  final PaymentResponseDto _self;
  final $Res Function(PaymentResponseDto) _then;

/// Create a copy of PaymentResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? cardLast4 = null,Object? bookingIds = null,Object? status = null,}) {
  return _then(PaymentResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,cardLast4: null == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String,bookingIds: null == bookingIds ? _self.bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentResponseDto].
extension PaymentResponseDtoPatterns on PaymentResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  double amount,  String cardLast4,  List<int> bookingIds,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentResponseDto() when $default != null:
return $default(_that.id,_that.amount,_that.cardLast4,_that.bookingIds,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  double amount,  String cardLast4,  List<int> bookingIds,  String status)  $default,) {final _that = this;
switch (_that) {
case _PaymentResponseDto():
return $default(_that.id,_that.amount,_that.cardLast4,_that.bookingIds,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  double amount,  String cardLast4,  List<int> bookingIds,  String status)?  $default,) {final _that = this;
switch (_that) {
case _PaymentResponseDto() when $default != null:
return $default(_that.id,_that.amount,_that.cardLast4,_that.bookingIds,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentResponseDto extends PaymentResponseDto {
  const _PaymentResponseDto({required this.id, required this.amount, required this.cardLast4, required  List<int> bookingIds, required this.status}): _bookingIds = bookingIds,super._();
  factory _PaymentResponseDto.fromJson(Map<String, dynamic> json) => _$PaymentResponseDtoFromJson(json);

@override final  int id;
@override final  double amount;
@override final  String cardLast4;
 final  List<int> _bookingIds;
@override List<int> get bookingIds {
  if (_bookingIds is EqualUnmodifiableListView) return _bookingIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookingIds);
}

@override final  String status;

/// Create a copy of PaymentResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentResponseDtoCopyWith<_PaymentResponseDto> get copyWith => __$PaymentResponseDtoCopyWithImpl<_PaymentResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&const DeepCollectionEquality().equals(other.bookingIds, _bookingIds)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,amount,cardLast4,const DeepCollectionEquality().hash(_bookingIds),status);
}

@override
String toString() {
    return 'PaymentResponseDto(id: $id, amount: $amount, cardLast4: $cardLast4, bookingIds: $bookingIds, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PaymentResponseDtoCopyWith<$Res> implements $PaymentResponseDtoCopyWith<$Res> {
  factory _$PaymentResponseDtoCopyWith(_PaymentResponseDto value, $Res Function(_PaymentResponseDto) _then) = __$PaymentResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, double amount, String cardLast4, List<int> bookingIds, String status
});




}
/// @nodoc
class __$PaymentResponseDtoCopyWithImpl<$Res>
    implements _$PaymentResponseDtoCopyWith<$Res> {
  __$PaymentResponseDtoCopyWithImpl(this._self, this._then);

  final _PaymentResponseDto _self;
  final $Res Function(_PaymentResponseDto) _then;

/// Create a copy of PaymentResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? cardLast4 = null,Object? bookingIds = null,Object? status = null,}) {
  return _then(_PaymentResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,cardLast4: null == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String,bookingIds: null == bookingIds ? _self._bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
