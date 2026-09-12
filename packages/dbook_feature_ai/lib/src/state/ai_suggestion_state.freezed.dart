// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_suggestion_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiSuggestionState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AiSuggestionState()';
}


}

/// @nodoc
class $AiSuggestionStateCopyWith<$Res>  {
$AiSuggestionStateCopyWith(AiSuggestionState _, $Res Function(AiSuggestionState) __);
}


/// Adds pattern-matching-related methods to [AiSuggestionState].
extension AiSuggestionStatePatterns on AiSuggestionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AiSuggestionIdle value)?  idle,TResult Function( AiSuggestionLoading value)?  loading,TResult Function( AiSuggestionSuccess value)?  success,TResult Function( AiSuggestionError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AiSuggestionIdle() when idle != null:
return idle(_that);case AiSuggestionLoading() when loading != null:
return loading(_that);case AiSuggestionSuccess() when success != null:
return success(_that);case AiSuggestionError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AiSuggestionIdle value)  idle,required TResult Function( AiSuggestionLoading value)  loading,required TResult Function( AiSuggestionSuccess value)  success,required TResult Function( AiSuggestionError value)  error,}){
final _that = this;
switch (_that) {
case AiSuggestionIdle():
return idle(_that);case AiSuggestionLoading():
return loading(_that);case AiSuggestionSuccess():
return success(_that);case AiSuggestionError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AiSuggestionIdle value)?  idle,TResult? Function( AiSuggestionLoading value)?  loading,TResult? Function( AiSuggestionSuccess value)?  success,TResult? Function( AiSuggestionError value)?  error,}){
final _that = this;
switch (_that) {
case AiSuggestionIdle() when idle != null:
return idle(_that);case AiSuggestionLoading() when loading != null:
return loading(_that);case AiSuggestionSuccess() when success != null:
return success(_that);case AiSuggestionError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( List<AiSuggestion> suggestions)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AiSuggestionIdle() when idle != null:
return idle();case AiSuggestionLoading() when loading != null:
return loading();case AiSuggestionSuccess() when success != null:
return success(_that.suggestions);case AiSuggestionError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( List<AiSuggestion> suggestions)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case AiSuggestionIdle():
return idle();case AiSuggestionLoading():
return loading();case AiSuggestionSuccess():
return success(_that.suggestions);case AiSuggestionError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( List<AiSuggestion> suggestions)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case AiSuggestionIdle() when idle != null:
return idle();case AiSuggestionLoading() when loading != null:
return loading();case AiSuggestionSuccess() when success != null:
return success(_that.suggestions);case AiSuggestionError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AiSuggestionIdle implements AiSuggestionState {
  const AiSuggestionIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AiSuggestionState.idle()';
}


}




/// @nodoc


class AiSuggestionLoading implements AiSuggestionState {
  const AiSuggestionLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AiSuggestionState.loading()';
}


}




/// @nodoc


class AiSuggestionSuccess implements AiSuggestionState {
  const AiSuggestionSuccess( List<AiSuggestion> suggestions): _suggestions = suggestions;
  

 final  List<AiSuggestion> _suggestions;
 List<AiSuggestion> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


/// Create a copy of AiSuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSuggestionSuccessCopyWith<AiSuggestionSuccess> get copyWith => _$AiSuggestionSuccessCopyWithImpl<AiSuggestionSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionSuccess&&const DeepCollectionEquality().equals(other.suggestions, _suggestions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_suggestions));
}

@override
String toString() {
    return 'AiSuggestionState.success(suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class $AiSuggestionSuccessCopyWith<$Res> implements $AiSuggestionStateCopyWith<$Res> {
  factory $AiSuggestionSuccessCopyWith(AiSuggestionSuccess value, $Res Function(AiSuggestionSuccess) _then) = _$AiSuggestionSuccessCopyWithImpl;
@useResult
$Res call({
 List<AiSuggestion> suggestions
});




}
/// @nodoc
class _$AiSuggestionSuccessCopyWithImpl<$Res>
    implements $AiSuggestionSuccessCopyWith<$Res> {
  _$AiSuggestionSuccessCopyWithImpl(this._self, this._then);

  final AiSuggestionSuccess _self;
  final $Res Function(AiSuggestionSuccess) _then;

/// Create a copy of AiSuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? suggestions = null,}) {
  return _then(AiSuggestionSuccess(
null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<AiSuggestion>,
  ));
}


}

/// @nodoc


class AiSuggestionError implements AiSuggestionState {
  const AiSuggestionError(this.message);
  

 final  String message;

/// Create a copy of AiSuggestionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSuggestionErrorCopyWith<AiSuggestionError> get copyWith => _$AiSuggestionErrorCopyWithImpl<AiSuggestionError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuggestionError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AiSuggestionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $AiSuggestionErrorCopyWith<$Res> implements $AiSuggestionStateCopyWith<$Res> {
  factory $AiSuggestionErrorCopyWith(AiSuggestionError value, $Res Function(AiSuggestionError) _then) = _$AiSuggestionErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AiSuggestionErrorCopyWithImpl<$Res>
    implements $AiSuggestionErrorCopyWith<$Res> {
  _$AiSuggestionErrorCopyWithImpl(this._self, this._then);

  final AiSuggestionError _self;
  final $Res Function(AiSuggestionError) _then;

/// Create a copy of AiSuggestionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AiSuggestionError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
