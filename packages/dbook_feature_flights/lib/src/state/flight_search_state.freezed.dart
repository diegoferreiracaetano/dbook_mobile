// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flight_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlightSearchState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightSearchState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlightSearchState()';
}


}

/// @nodoc
class $FlightSearchStateCopyWith<$Res>  {
$FlightSearchStateCopyWith(FlightSearchState _, $Res Function(FlightSearchState) __);
}


/// Adds pattern-matching-related methods to [FlightSearchState].
extension FlightSearchStatePatterns on FlightSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FlightSearchIdle value)?  idle,TResult Function( FlightSearchLoading value)?  loading,TResult Function( FlightSearchSuccess value)?  success,TResult Function( FlightSearchError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FlightSearchIdle() when idle != null:
return idle(_that);case FlightSearchLoading() when loading != null:
return loading(_that);case FlightSearchSuccess() when success != null:
return success(_that);case FlightSearchError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FlightSearchIdle value)  idle,required TResult Function( FlightSearchLoading value)  loading,required TResult Function( FlightSearchSuccess value)  success,required TResult Function( FlightSearchError value)  error,}){
final _that = this;
switch (_that) {
case FlightSearchIdle():
return idle(_that);case FlightSearchLoading():
return loading(_that);case FlightSearchSuccess():
return success(_that);case FlightSearchError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FlightSearchIdle value)?  idle,TResult? Function( FlightSearchLoading value)?  loading,TResult? Function( FlightSearchSuccess value)?  success,TResult? Function( FlightSearchError value)?  error,}){
final _that = this;
switch (_that) {
case FlightSearchIdle() when idle != null:
return idle(_that);case FlightSearchLoading() when loading != null:
return loading(_that);case FlightSearchSuccess() when success != null:
return success(_that);case FlightSearchError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( List<Flight> flights)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FlightSearchIdle() when idle != null:
return idle();case FlightSearchLoading() when loading != null:
return loading();case FlightSearchSuccess() when success != null:
return success(_that.flights);case FlightSearchError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( List<Flight> flights)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case FlightSearchIdle():
return idle();case FlightSearchLoading():
return loading();case FlightSearchSuccess():
return success(_that.flights);case FlightSearchError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( List<Flight> flights)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case FlightSearchIdle() when idle != null:
return idle();case FlightSearchLoading() when loading != null:
return loading();case FlightSearchSuccess() when success != null:
return success(_that.flights);case FlightSearchError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class FlightSearchIdle implements FlightSearchState {
  const FlightSearchIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightSearchIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlightSearchState.idle()';
}


}




/// @nodoc


class FlightSearchLoading implements FlightSearchState {
  const FlightSearchLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightSearchLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlightSearchState.loading()';
}


}




/// @nodoc


class FlightSearchSuccess implements FlightSearchState {
  const FlightSearchSuccess( List<Flight> flights): _flights = flights;
  

 final  List<Flight> _flights;
 List<Flight> get flights {
  if (_flights is EqualUnmodifiableListView) return _flights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flights);
}


/// Create a copy of FlightSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlightSearchSuccessCopyWith<FlightSearchSuccess> get copyWith => _$FlightSearchSuccessCopyWithImpl<FlightSearchSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightSearchSuccess&&const DeepCollectionEquality().equals(other.flights, _flights));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_flights));
}

@override
String toString() {
    return 'FlightSearchState.success(flights: $flights)';
}


}

/// @nodoc
abstract mixin class $FlightSearchSuccessCopyWith<$Res> implements $FlightSearchStateCopyWith<$Res> {
  factory $FlightSearchSuccessCopyWith(FlightSearchSuccess value, $Res Function(FlightSearchSuccess) _then) = _$FlightSearchSuccessCopyWithImpl;
@useResult
$Res call({
 List<Flight> flights
});




}
/// @nodoc
class _$FlightSearchSuccessCopyWithImpl<$Res>
    implements $FlightSearchSuccessCopyWith<$Res> {
  _$FlightSearchSuccessCopyWithImpl(this._self, this._then);

  final FlightSearchSuccess _self;
  final $Res Function(FlightSearchSuccess) _then;

/// Create a copy of FlightSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? flights = null,}) {
  return _then(FlightSearchSuccess(
null == flights ? _self._flights : flights // ignore: cast_nullable_to_non_nullable
as List<Flight>,
  ));
}


}

/// @nodoc


class FlightSearchError implements FlightSearchState {
  const FlightSearchError(this.message);
  

 final  String message;

/// Create a copy of FlightSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlightSearchErrorCopyWith<FlightSearchError> get copyWith => _$FlightSearchErrorCopyWithImpl<FlightSearchError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlightSearchError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'FlightSearchState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $FlightSearchErrorCopyWith<$Res> implements $FlightSearchStateCopyWith<$Res> {
  factory $FlightSearchErrorCopyWith(FlightSearchError value, $Res Function(FlightSearchError) _then) = _$FlightSearchErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FlightSearchErrorCopyWithImpl<$Res>
    implements $FlightSearchErrorCopyWith<$Res> {
  _$FlightSearchErrorCopyWithImpl(this._self, this._then);

  final FlightSearchError _self;
  final $Res Function(FlightSearchError) _then;

/// Create a copy of FlightSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FlightSearchError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
