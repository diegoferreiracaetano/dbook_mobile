// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Seat {

 int get id; int get bookableId; String get label; SeatStatus get status;
/// Create a copy of Seat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatCopyWith<Seat> get copyWith => _$SeatCopyWithImpl<Seat>(this as Seat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Seat&&(identical(other.id, id) || other.id == id)&&(identical(other.bookableId, bookableId) || other.bookableId == bookableId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookableId,label,status);

@override
String toString() {
  return 'Seat(id: $id, bookableId: $bookableId, label: $label, status: $status)';
}


}

/// @nodoc
abstract mixin class $SeatCopyWith<$Res>  {
  factory $SeatCopyWith(Seat value, $Res Function(Seat) _then) = _$SeatCopyWithImpl;
@useResult
$Res call({
 int id, int bookableId, String label, SeatStatus status
});




}
/// @nodoc
class _$SeatCopyWithImpl<$Res>
    implements $SeatCopyWith<$Res> {
  _$SeatCopyWithImpl(this._self, this._then);

  final Seat _self;
  final $Res Function(Seat) _then;

/// Create a copy of Seat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookableId = null,Object? label = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookableId: null == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SeatStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Seat].
extension SeatPatterns on Seat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Seat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Seat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Seat value)  $default,){
final _that = this;
switch (_that) {
case _Seat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Seat value)?  $default,){
final _that = this;
switch (_that) {
case _Seat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookableId,  String label,  SeatStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Seat() when $default != null:
return $default(_that.id,_that.bookableId,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookableId,  String label,  SeatStatus status)  $default,) {final _that = this;
switch (_that) {
case _Seat():
return $default(_that.id,_that.bookableId,_that.label,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookableId,  String label,  SeatStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Seat() when $default != null:
return $default(_that.id,_that.bookableId,_that.label,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Seat implements Seat {
  const _Seat({required this.id, required this.bookableId, required this.label, required this.status});
  

@override final  int id;
@override final  int bookableId;
@override final  String label;
@override final  SeatStatus status;

/// Create a copy of Seat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeatCopyWith<_Seat> get copyWith => __$SeatCopyWithImpl<_Seat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Seat&&(identical(other.id, id) || other.id == id)&&(identical(other.bookableId, bookableId) || other.bookableId == bookableId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookableId,label,status);

@override
String toString() {
  return 'Seat(id: $id, bookableId: $bookableId, label: $label, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SeatCopyWith<$Res> implements $SeatCopyWith<$Res> {
  factory _$SeatCopyWith(_Seat value, $Res Function(_Seat) _then) = __$SeatCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookableId, String label, SeatStatus status
});




}
/// @nodoc
class __$SeatCopyWithImpl<$Res>
    implements _$SeatCopyWith<$Res> {
  __$SeatCopyWithImpl(this._self, this._then);

  final _Seat _self;
  final $Res Function(_Seat) _then;

/// Create a copy of Seat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookableId = null,Object? label = null,Object? status = null,}) {
  return _then(_Seat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookableId: null == bookableId ? _self.bookableId : bookableId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SeatStatus,
  ));
}


}

// dart format on
