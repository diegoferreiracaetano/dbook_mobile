// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AvailabilityState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AvailabilityState()';
}


}

/// @nodoc
class $AvailabilityStateCopyWith<$Res>  {
$AvailabilityStateCopyWith(AvailabilityState _, $Res Function(AvailabilityState) __);
}


/// Adds pattern-matching-related methods to [AvailabilityState].
extension AvailabilityStatePatterns on AvailabilityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AvailabilityConnecting value)?  connecting,TResult Function( AvailabilityLive value)?  live,TResult Function( AvailabilityReconnecting value)?  reconnecting,TResult Function( AvailabilityUnavailable value)?  unavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AvailabilityConnecting() when connecting != null:
return connecting(_that);case AvailabilityLive() when live != null:
return live(_that);case AvailabilityReconnecting() when reconnecting != null:
return reconnecting(_that);case AvailabilityUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AvailabilityConnecting value)  connecting,required TResult Function( AvailabilityLive value)  live,required TResult Function( AvailabilityReconnecting value)  reconnecting,required TResult Function( AvailabilityUnavailable value)  unavailable,}){
final _that = this;
switch (_that) {
case AvailabilityConnecting():
return connecting(_that);case AvailabilityLive():
return live(_that);case AvailabilityReconnecting():
return reconnecting(_that);case AvailabilityUnavailable():
return unavailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AvailabilityConnecting value)?  connecting,TResult? Function( AvailabilityLive value)?  live,TResult? Function( AvailabilityReconnecting value)?  reconnecting,TResult? Function( AvailabilityUnavailable value)?  unavailable,}){
final _that = this;
switch (_that) {
case AvailabilityConnecting() when connecting != null:
return connecting(_that);case AvailabilityLive() when live != null:
return live(_that);case AvailabilityReconnecting() when reconnecting != null:
return reconnecting(_that);case AvailabilityUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  connecting,TResult Function( int availableCapacity)?  live,TResult Function( int? lastKnownCapacity)?  reconnecting,TResult Function( String message)?  unavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AvailabilityConnecting() when connecting != null:
return connecting();case AvailabilityLive() when live != null:
return live(_that.availableCapacity);case AvailabilityReconnecting() when reconnecting != null:
return reconnecting(_that.lastKnownCapacity);case AvailabilityUnavailable() when unavailable != null:
return unavailable(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  connecting,required TResult Function( int availableCapacity)  live,required TResult Function( int? lastKnownCapacity)  reconnecting,required TResult Function( String message)  unavailable,}) {final _that = this;
switch (_that) {
case AvailabilityConnecting():
return connecting();case AvailabilityLive():
return live(_that.availableCapacity);case AvailabilityReconnecting():
return reconnecting(_that.lastKnownCapacity);case AvailabilityUnavailable():
return unavailable(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  connecting,TResult? Function( int availableCapacity)?  live,TResult? Function( int? lastKnownCapacity)?  reconnecting,TResult? Function( String message)?  unavailable,}) {final _that = this;
switch (_that) {
case AvailabilityConnecting() when connecting != null:
return connecting();case AvailabilityLive() when live != null:
return live(_that.availableCapacity);case AvailabilityReconnecting() when reconnecting != null:
return reconnecting(_that.lastKnownCapacity);case AvailabilityUnavailable() when unavailable != null:
return unavailable(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AvailabilityConnecting implements AvailabilityState {
  const AvailabilityConnecting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AvailabilityState.connecting()';
}


}




/// @nodoc


class AvailabilityLive implements AvailabilityState {
  const AvailabilityLive(this.availableCapacity);
  

 final  int availableCapacity;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityLiveCopyWith<AvailabilityLive> get copyWith => _$AvailabilityLiveCopyWithImpl<AvailabilityLive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityLive&&(identical(other.availableCapacity, availableCapacity) || other.availableCapacity == availableCapacity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,availableCapacity);
}

@override
String toString() {
    return 'AvailabilityState.live(availableCapacity: $availableCapacity)';
}


}

/// @nodoc
abstract mixin class $AvailabilityLiveCopyWith<$Res> implements $AvailabilityStateCopyWith<$Res> {
  factory $AvailabilityLiveCopyWith(AvailabilityLive value, $Res Function(AvailabilityLive) _then) = _$AvailabilityLiveCopyWithImpl;
@useResult
$Res call({
 int availableCapacity
});




}
/// @nodoc
class _$AvailabilityLiveCopyWithImpl<$Res>
    implements $AvailabilityLiveCopyWith<$Res> {
  _$AvailabilityLiveCopyWithImpl(this._self, this._then);

  final AvailabilityLive _self;
  final $Res Function(AvailabilityLive) _then;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? availableCapacity = null,}) {
  return _then(AvailabilityLive(
null == availableCapacity ? _self.availableCapacity : availableCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class AvailabilityReconnecting implements AvailabilityState {
  const AvailabilityReconnecting(this.lastKnownCapacity);
  

 final  int? lastKnownCapacity;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityReconnectingCopyWith<AvailabilityReconnecting> get copyWith => _$AvailabilityReconnectingCopyWithImpl<AvailabilityReconnecting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityReconnecting&&(identical(other.lastKnownCapacity, lastKnownCapacity) || other.lastKnownCapacity == lastKnownCapacity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lastKnownCapacity);
}

@override
String toString() {
    return 'AvailabilityState.reconnecting(lastKnownCapacity: $lastKnownCapacity)';
}


}

/// @nodoc
abstract mixin class $AvailabilityReconnectingCopyWith<$Res> implements $AvailabilityStateCopyWith<$Res> {
  factory $AvailabilityReconnectingCopyWith(AvailabilityReconnecting value, $Res Function(AvailabilityReconnecting) _then) = _$AvailabilityReconnectingCopyWithImpl;
@useResult
$Res call({
 int? lastKnownCapacity
});




}
/// @nodoc
class _$AvailabilityReconnectingCopyWithImpl<$Res>
    implements $AvailabilityReconnectingCopyWith<$Res> {
  _$AvailabilityReconnectingCopyWithImpl(this._self, this._then);

  final AvailabilityReconnecting _self;
  final $Res Function(AvailabilityReconnecting) _then;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastKnownCapacity = freezed,}) {
  return _then(AvailabilityReconnecting(
freezed == lastKnownCapacity ? _self.lastKnownCapacity : lastKnownCapacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class AvailabilityUnavailable implements AvailabilityState {
  const AvailabilityUnavailable(this.message);
  

 final  String message;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityUnavailableCopyWith<AvailabilityUnavailable> get copyWith => _$AvailabilityUnavailableCopyWithImpl<AvailabilityUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityUnavailable&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AvailabilityState.unavailable(message: $message)';
}


}

/// @nodoc
abstract mixin class $AvailabilityUnavailableCopyWith<$Res> implements $AvailabilityStateCopyWith<$Res> {
  factory $AvailabilityUnavailableCopyWith(AvailabilityUnavailable value, $Res Function(AvailabilityUnavailable) _then) = _$AvailabilityUnavailableCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AvailabilityUnavailableCopyWithImpl<$Res>
    implements $AvailabilityUnavailableCopyWith<$Res> {
  _$AvailabilityUnavailableCopyWithImpl(this._self, this._then);

  final AvailabilityUnavailable _self;
  final $Res Function(AvailabilityUnavailable) _then;

/// Create a copy of AvailabilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AvailabilityUnavailable(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
