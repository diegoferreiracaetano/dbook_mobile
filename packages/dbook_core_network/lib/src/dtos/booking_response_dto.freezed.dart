// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingResponseDto {

 int get id; int? get bookableId; int get seatId; int get customerId; String get status;
/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingResponseDtoCopyWith<BookingResponseDto> get copyWith => _$BookingResponseDtoCopyWithImpl<BookingResponseDto>(this as BookingResponseDto, _$identity);

  /// Serializes this BookingResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookableId, _this.bookableId) || other.bookableId == _this.bookableId)&&(identical(other.seatId, _this.seatId) || other.seatId == _this.seatId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingResponseDto;
  return Object.hash(runtimeType,_this.id,_this.bookableId,_this.seatId,_this.customerId,_this.status);
}

@override
String toString() {
  final _this = this as BookingResponseDto;
  return 'BookingResponseDto(id: ${_this.id}, bookableId: ${_this.bookableId}, seatId: ${_this.seatId}, customerId: ${_this.customerId}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BookingResponseDtoCopyWith<$Res>  {
  factory $BookingResponseDtoCopyWith(BookingResponseDto value, $Res Function(BookingResponseDto) _then) = _$BookingResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, int? bookableId, int seatId, int customerId, String status
});




}
/// @nodoc
class _$BookingResponseDtoCopyWithImpl<$Res>
    implements $BookingResponseDtoCopyWith<$Res> {
  _$BookingResponseDtoCopyWithImpl(this._self, this._then);

  final BookingResponseDto _self;
  final $Res Function(BookingResponseDto) _then;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookableId = freezed,Object? seatId = null,Object? customerId = null,Object? status = null,}) {
  return _then(BookingResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookableId: freezed == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int?,seatId: null == seatId ? _self.seatId : seatId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingResponseDto].
extension BookingResponseDtoPatterns on BookingResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _BookingResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? bookableId,  int seatId,  int customerId,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
return $default(_that.id,_that.bookableId,_that.seatId,_that.customerId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? bookableId,  int seatId,  int customerId,  String status)  $default,) {final _that = this;
switch (_that) {
case _BookingResponseDto():
return $default(_that.id,_that.bookableId,_that.seatId,_that.customerId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? bookableId,  int seatId,  int customerId,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
return $default(_that.id,_that.bookableId,_that.seatId,_that.customerId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingResponseDto extends BookingResponseDto {
  const _BookingResponseDto({required this.id, required this.bookableId, required this.seatId, required this.customerId, required this.status}): super._();
  factory _BookingResponseDto.fromJson(Map<String, dynamic> json) => _$BookingResponseDtoFromJson(json);

@override final  int id;
@override final  int? bookableId;
@override final  int seatId;
@override final  int customerId;
@override final  String status;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingResponseDtoCopyWith<_BookingResponseDto> get copyWith => __$BookingResponseDtoCopyWithImpl<_BookingResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.bookableId, bookableId) || other.bookableId == bookableId)&&(identical(other.seatId, seatId) || other.seatId == seatId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookableId,seatId,customerId,status);
}

@override
String toString() {
    return 'BookingResponseDto(id: $id, bookableId: $bookableId, seatId: $seatId, customerId: $customerId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BookingResponseDtoCopyWith<$Res> implements $BookingResponseDtoCopyWith<$Res> {
  factory _$BookingResponseDtoCopyWith(_BookingResponseDto value, $Res Function(_BookingResponseDto) _then) = __$BookingResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int? bookableId, int seatId, int customerId, String status
});




}
/// @nodoc
class __$BookingResponseDtoCopyWithImpl<$Res>
    implements _$BookingResponseDtoCopyWith<$Res> {
  __$BookingResponseDtoCopyWithImpl(this._self, this._then);

  final _BookingResponseDto _self;
  final $Res Function(_BookingResponseDto) _then;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookableId = freezed,Object? seatId = null,Object? customerId = null,Object? status = null,}) {
  return _then(_BookingResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookableId: freezed == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int?,seatId: null == seatId ? _self.seatId : seatId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
