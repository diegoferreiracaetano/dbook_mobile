// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seat_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeatResponseDto {

 int get id; String get label; String get status;
/// Create a copy of SeatResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatResponseDtoCopyWith<SeatResponseDto> get copyWith => _$SeatResponseDtoCopyWithImpl<SeatResponseDto>(this as SeatResponseDto, _$identity);

  /// Serializes this SeatResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SeatResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatResponseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SeatResponseDto;
  return Object.hash(runtimeType,_this.id,_this.label,_this.status);
}

@override
String toString() {
  final _this = this as SeatResponseDto;
  return 'SeatResponseDto(id: ${_this.id}, label: ${_this.label}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $SeatResponseDtoCopyWith<$Res>  {
  factory $SeatResponseDtoCopyWith(SeatResponseDto value, $Res Function(SeatResponseDto) _then) = _$SeatResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, String label, String status
});




}
/// @nodoc
class _$SeatResponseDtoCopyWithImpl<$Res>
    implements $SeatResponseDtoCopyWith<$Res> {
  _$SeatResponseDtoCopyWithImpl(this._self, this._then);

  final SeatResponseDto _self;
  final $Res Function(SeatResponseDto) _then;

/// Create a copy of SeatResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? status = null,}) {
  return _then(SeatResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SeatResponseDto].
extension SeatResponseDtoPatterns on SeatResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeatResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeatResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeatResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SeatResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeatResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SeatResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeatResponseDto() when $default != null:
return $default(_that.id,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label,  String status)  $default,) {final _that = this;
switch (_that) {
case _SeatResponseDto():
return $default(_that.id,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label,  String status)?  $default,) {final _that = this;
switch (_that) {
case _SeatResponseDto() when $default != null:
return $default(_that.id,_that.label,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeatResponseDto extends SeatResponseDto {
  const _SeatResponseDto({required this.id, required this.label, required this.status}): super._();
  factory _SeatResponseDto.fromJson(Map<String, dynamic> json) => _$SeatResponseDtoFromJson(json);

@override final  int id;
@override final  String label;
@override final  String status;

/// Create a copy of SeatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeatResponseDtoCopyWith<_SeatResponseDto> get copyWith => __$SeatResponseDtoCopyWithImpl<_SeatResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeatResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeatResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,status);
}

@override
String toString() {
    return 'SeatResponseDto(id: $id, label: $label, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SeatResponseDtoCopyWith<$Res> implements $SeatResponseDtoCopyWith<$Res> {
  factory _$SeatResponseDtoCopyWith(_SeatResponseDto value, $Res Function(_SeatResponseDto) _then) = __$SeatResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String label, String status
});




}
/// @nodoc
class __$SeatResponseDtoCopyWithImpl<$Res>
    implements _$SeatResponseDtoCopyWith<$Res> {
  __$SeatResponseDtoCopyWithImpl(this._self, this._then);

  final _SeatResponseDto _self;
  final $Res Function(_SeatResponseDto) _then;

/// Create a copy of SeatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? status = null,}) {
  return _then(_SeatResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
