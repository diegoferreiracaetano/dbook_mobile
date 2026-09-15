// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentState()';
}


}

/// @nodoc
class $PaymentStateCopyWith<$Res>  {
$PaymentStateCopyWith(PaymentState _, $Res Function(PaymentState) __);
}


/// Adds pattern-matching-related methods to [PaymentState].
extension PaymentStatePatterns on PaymentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentIdle value)?  idle,TResult Function( PaymentSubmitting value)?  submitting,TResult Function( PaymentError value)?  error,TResult Function( PaymentPaid value)?  paid,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentIdle() when idle != null:
return idle(_that);case PaymentSubmitting() when submitting != null:
return submitting(_that);case PaymentError() when error != null:
return error(_that);case PaymentPaid() when paid != null:
return paid(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentIdle value)  idle,required TResult Function( PaymentSubmitting value)  submitting,required TResult Function( PaymentError value)  error,required TResult Function( PaymentPaid value)  paid,}){
final _that = this;
switch (_that) {
case PaymentIdle():
return idle(_that);case PaymentSubmitting():
return submitting(_that);case PaymentError():
return error(_that);case PaymentPaid():
return paid(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentIdle value)?  idle,TResult? Function( PaymentSubmitting value)?  submitting,TResult? Function( PaymentError value)?  error,TResult? Function( PaymentPaid value)?  paid,}){
final _that = this;
switch (_that) {
case PaymentIdle() when idle != null:
return idle(_that);case PaymentSubmitting() when submitting != null:
return submitting(_that);case PaymentError() when error != null:
return error(_that);case PaymentPaid() when paid != null:
return paid(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function( String message)?  error,TResult Function( Payment payment)?  paid,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentIdle() when idle != null:
return idle();case PaymentSubmitting() when submitting != null:
return submitting();case PaymentError() when error != null:
return error(_that.message);case PaymentPaid() when paid != null:
return paid(_that.payment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function( String message)  error,required TResult Function( Payment payment)  paid,}) {final _that = this;
switch (_that) {
case PaymentIdle():
return idle();case PaymentSubmitting():
return submitting();case PaymentError():
return error(_that.message);case PaymentPaid():
return paid(_that.payment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function( String message)?  error,TResult? Function( Payment payment)?  paid,}) {final _that = this;
switch (_that) {
case PaymentIdle() when idle != null:
return idle();case PaymentSubmitting() when submitting != null:
return submitting();case PaymentError() when error != null:
return error(_that.message);case PaymentPaid() when paid != null:
return paid(_that.payment);case _:
  return null;

}
}

}

/// @nodoc


class PaymentIdle implements PaymentState {
  const PaymentIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentState.idle()';
}


}




/// @nodoc


class PaymentSubmitting implements PaymentState {
  const PaymentSubmitting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PaymentState.submitting()';
}


}




/// @nodoc


class PaymentError implements PaymentState {
  const PaymentError(this.message);
  

 final  String message;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentErrorCopyWith<PaymentError> get copyWith => _$PaymentErrorCopyWithImpl<PaymentError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'PaymentState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $PaymentErrorCopyWith<$Res> implements $PaymentStateCopyWith<$Res> {
  factory $PaymentErrorCopyWith(PaymentError value, $Res Function(PaymentError) _then) = _$PaymentErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PaymentErrorCopyWithImpl<$Res>
    implements $PaymentErrorCopyWith<$Res> {
  _$PaymentErrorCopyWithImpl(this._self, this._then);

  final PaymentError _self;
  final $Res Function(PaymentError) _then;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PaymentError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PaymentPaid implements PaymentState {
  const PaymentPaid(this.payment);
  

 final  Payment payment;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentPaidCopyWith<PaymentPaid> get copyWith => _$PaymentPaidCopyWithImpl<PaymentPaid>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentPaid&&(identical(other.payment, payment) || other.payment == payment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,payment);
}

@override
String toString() {
    return 'PaymentState.paid(payment: $payment)';
}


}

/// @nodoc
abstract mixin class $PaymentPaidCopyWith<$Res> implements $PaymentStateCopyWith<$Res> {
  factory $PaymentPaidCopyWith(PaymentPaid value, $Res Function(PaymentPaid) _then) = _$PaymentPaidCopyWithImpl;
@useResult
$Res call({
 Payment payment
});


$PaymentCopyWith<$Res> get payment;

}
/// @nodoc
class _$PaymentPaidCopyWithImpl<$Res>
    implements $PaymentPaidCopyWith<$Res> {
  _$PaymentPaidCopyWithImpl(this._self, this._then);

  final PaymentPaid _self;
  final $Res Function(PaymentPaid) _then;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payment = null,}) {
  return _then(PaymentPaid(
null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,
  ));
}

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on
