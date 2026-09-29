// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewResponseDto {

 int get id; int get bookingId; int get customerId; int get rating; String get comment; DateTime get createdAt;
/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewResponseDtoCopyWith<ReviewResponseDto> get copyWith => _$ReviewResponseDtoCopyWithImpl<ReviewResponseDto>(this as ReviewResponseDto, _$identity);

  /// Serializes this ReviewResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReviewResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReviewResponseDto;
  return Object.hash(runtimeType,_this.id,_this.bookingId,_this.customerId,_this.rating,_this.comment,_this.createdAt);
}

@override
String toString() {
  final _this = this as ReviewResponseDto;
  return 'ReviewResponseDto(id: ${_this.id}, bookingId: ${_this.bookingId}, customerId: ${_this.customerId}, rating: ${_this.rating}, comment: ${_this.comment}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReviewResponseDtoCopyWith<$Res>  {
  factory $ReviewResponseDtoCopyWith(ReviewResponseDto value, $Res Function(ReviewResponseDto) _then) = _$ReviewResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, int bookingId, int customerId, int rating, String comment, DateTime createdAt
});




}
/// @nodoc
class _$ReviewResponseDtoCopyWithImpl<$Res>
    implements $ReviewResponseDtoCopyWith<$Res> {
  _$ReviewResponseDtoCopyWithImpl(this._self, this._then);

  final ReviewResponseDto _self;
  final $Res Function(ReviewResponseDto) _then;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = null,Object? customerId = null,Object? rating = null,Object? comment = null,Object? createdAt = null,}) {
  return _then(ReviewResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewResponseDto].
extension ReviewResponseDtoPatterns on ReviewResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ReviewResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookingId,  int customerId,  int rating,  String comment,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
return $default(_that.id,_that.bookingId,_that.customerId,_that.rating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookingId,  int customerId,  int rating,  String comment,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewResponseDto():
return $default(_that.id,_that.bookingId,_that.customerId,_that.rating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookingId,  int customerId,  int rating,  String comment,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
return $default(_that.id,_that.bookingId,_that.customerId,_that.rating,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewResponseDto extends ReviewResponseDto {
  const _ReviewResponseDto({required this.id, required this.bookingId, required this.customerId, required this.rating, required this.comment, required this.createdAt}): super._();
  factory _ReviewResponseDto.fromJson(Map<String, dynamic> json) => _$ReviewResponseDtoFromJson(json);

@override final  int id;
@override final  int bookingId;
@override final  int customerId;
@override final  int rating;
@override final  String comment;
@override final  DateTime createdAt;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewResponseDtoCopyWith<_ReviewResponseDto> get copyWith => __$ReviewResponseDtoCopyWithImpl<_ReviewResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookingId,customerId,rating,comment,createdAt);
}

@override
String toString() {
    return 'ReviewResponseDto(id: $id, bookingId: $bookingId, customerId: $customerId, rating: $rating, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewResponseDtoCopyWith<$Res> implements $ReviewResponseDtoCopyWith<$Res> {
  factory _$ReviewResponseDtoCopyWith(_ReviewResponseDto value, $Res Function(_ReviewResponseDto) _then) = __$ReviewResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookingId, int customerId, int rating, String comment, DateTime createdAt
});




}
/// @nodoc
class __$ReviewResponseDtoCopyWithImpl<$Res>
    implements _$ReviewResponseDtoCopyWith<$Res> {
  __$ReviewResponseDtoCopyWithImpl(this._self, this._then);

  final _ReviewResponseDto _self;
  final $Res Function(_ReviewResponseDto) _then;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = null,Object? customerId = null,Object? rating = null,Object? comment = null,Object? createdAt = null,}) {
  return _then(_ReviewResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
