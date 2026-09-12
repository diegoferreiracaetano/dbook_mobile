// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seat_selection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SeatSelectionState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SeatSelectionState()';
}


}

/// @nodoc
class $SeatSelectionStateCopyWith<$Res>  {
$SeatSelectionStateCopyWith(SeatSelectionState _, $Res Function(SeatSelectionState) __);
}


/// Adds pattern-matching-related methods to [SeatSelectionState].
extension SeatSelectionStatePatterns on SeatSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SeatSelectionIdle value)?  idle,TResult Function( SeatSelectionLoadingSeats value)?  loadingSeats,TResult Function( SeatSelectionSeatsError value)?  seatsError,TResult Function( SeatSelectionReady value)?  ready,TResult Function( SeatSelectionBooked value)?  booked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SeatSelectionIdle() when idle != null:
return idle(_that);case SeatSelectionLoadingSeats() when loadingSeats != null:
return loadingSeats(_that);case SeatSelectionSeatsError() when seatsError != null:
return seatsError(_that);case SeatSelectionReady() when ready != null:
return ready(_that);case SeatSelectionBooked() when booked != null:
return booked(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SeatSelectionIdle value)  idle,required TResult Function( SeatSelectionLoadingSeats value)  loadingSeats,required TResult Function( SeatSelectionSeatsError value)  seatsError,required TResult Function( SeatSelectionReady value)  ready,required TResult Function( SeatSelectionBooked value)  booked,}){
final _that = this;
switch (_that) {
case SeatSelectionIdle():
return idle(_that);case SeatSelectionLoadingSeats():
return loadingSeats(_that);case SeatSelectionSeatsError():
return seatsError(_that);case SeatSelectionReady():
return ready(_that);case SeatSelectionBooked():
return booked(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SeatSelectionIdle value)?  idle,TResult? Function( SeatSelectionLoadingSeats value)?  loadingSeats,TResult? Function( SeatSelectionSeatsError value)?  seatsError,TResult? Function( SeatSelectionReady value)?  ready,TResult? Function( SeatSelectionBooked value)?  booked,}){
final _that = this;
switch (_that) {
case SeatSelectionIdle() when idle != null:
return idle(_that);case SeatSelectionLoadingSeats() when loadingSeats != null:
return loadingSeats(_that);case SeatSelectionSeatsError() when seatsError != null:
return seatsError(_that);case SeatSelectionReady() when ready != null:
return ready(_that);case SeatSelectionBooked() when booked != null:
return booked(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loadingSeats,TResult Function( String message)?  seatsError,TResult Function( List<Seat> seats,  Seat? selected,  bool isBooking,  String? bookingError)?  ready,TResult Function( BookingRecord record)?  booked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SeatSelectionIdle() when idle != null:
return idle();case SeatSelectionLoadingSeats() when loadingSeats != null:
return loadingSeats();case SeatSelectionSeatsError() when seatsError != null:
return seatsError(_that.message);case SeatSelectionReady() when ready != null:
return ready(_that.seats,_that.selected,_that.isBooking,_that.bookingError);case SeatSelectionBooked() when booked != null:
return booked(_that.record);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loadingSeats,required TResult Function( String message)  seatsError,required TResult Function( List<Seat> seats,  Seat? selected,  bool isBooking,  String? bookingError)  ready,required TResult Function( BookingRecord record)  booked,}) {final _that = this;
switch (_that) {
case SeatSelectionIdle():
return idle();case SeatSelectionLoadingSeats():
return loadingSeats();case SeatSelectionSeatsError():
return seatsError(_that.message);case SeatSelectionReady():
return ready(_that.seats,_that.selected,_that.isBooking,_that.bookingError);case SeatSelectionBooked():
return booked(_that.record);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loadingSeats,TResult? Function( String message)?  seatsError,TResult? Function( List<Seat> seats,  Seat? selected,  bool isBooking,  String? bookingError)?  ready,TResult? Function( BookingRecord record)?  booked,}) {final _that = this;
switch (_that) {
case SeatSelectionIdle() when idle != null:
return idle();case SeatSelectionLoadingSeats() when loadingSeats != null:
return loadingSeats();case SeatSelectionSeatsError() when seatsError != null:
return seatsError(_that.message);case SeatSelectionReady() when ready != null:
return ready(_that.seats,_that.selected,_that.isBooking,_that.bookingError);case SeatSelectionBooked() when booked != null:
return booked(_that.record);case _:
  return null;

}
}

}

/// @nodoc


class SeatSelectionIdle implements SeatSelectionState {
  const SeatSelectionIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SeatSelectionState.idle()';
}


}




/// @nodoc


class SeatSelectionLoadingSeats implements SeatSelectionState {
  const SeatSelectionLoadingSeats();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionLoadingSeats);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SeatSelectionState.loadingSeats()';
}


}




/// @nodoc


class SeatSelectionSeatsError implements SeatSelectionState {
  const SeatSelectionSeatsError(this.message);
  

 final  String message;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatSelectionSeatsErrorCopyWith<SeatSelectionSeatsError> get copyWith => _$SeatSelectionSeatsErrorCopyWithImpl<SeatSelectionSeatsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionSeatsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'SeatSelectionState.seatsError(message: $message)';
}


}

/// @nodoc
abstract mixin class $SeatSelectionSeatsErrorCopyWith<$Res> implements $SeatSelectionStateCopyWith<$Res> {
  factory $SeatSelectionSeatsErrorCopyWith(SeatSelectionSeatsError value, $Res Function(SeatSelectionSeatsError) _then) = _$SeatSelectionSeatsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SeatSelectionSeatsErrorCopyWithImpl<$Res>
    implements $SeatSelectionSeatsErrorCopyWith<$Res> {
  _$SeatSelectionSeatsErrorCopyWithImpl(this._self, this._then);

  final SeatSelectionSeatsError _self;
  final $Res Function(SeatSelectionSeatsError) _then;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SeatSelectionSeatsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SeatSelectionReady implements SeatSelectionState {
  const SeatSelectionReady({required  List<Seat> seats, this.selected, this.isBooking = false, this.bookingError}): _seats = seats;
  

 final  List<Seat> _seats;
 List<Seat> get seats {
  if (_seats is EqualUnmodifiableListView) return _seats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seats);
}

 final  Seat? selected;
@JsonKey() final  bool isBooking;
 final  String? bookingError;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatSelectionReadyCopyWith<SeatSelectionReady> get copyWith => _$SeatSelectionReadyCopyWithImpl<SeatSelectionReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionReady&&const DeepCollectionEquality().equals(other.seats, _seats)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.isBooking, isBooking) || other.isBooking == isBooking)&&(identical(other.bookingError, bookingError) || other.bookingError == bookingError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_seats),selected,isBooking,bookingError);
}

@override
String toString() {
    return 'SeatSelectionState.ready(seats: $seats, selected: $selected, isBooking: $isBooking, bookingError: $bookingError)';
}


}

/// @nodoc
abstract mixin class $SeatSelectionReadyCopyWith<$Res> implements $SeatSelectionStateCopyWith<$Res> {
  factory $SeatSelectionReadyCopyWith(SeatSelectionReady value, $Res Function(SeatSelectionReady) _then) = _$SeatSelectionReadyCopyWithImpl;
@useResult
$Res call({
 List<Seat> seats, Seat? selected, bool isBooking, String? bookingError
});


$SeatCopyWith<$Res>? get selected;

}
/// @nodoc
class _$SeatSelectionReadyCopyWithImpl<$Res>
    implements $SeatSelectionReadyCopyWith<$Res> {
  _$SeatSelectionReadyCopyWithImpl(this._self, this._then);

  final SeatSelectionReady _self;
  final $Res Function(SeatSelectionReady) _then;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? seats = null,Object? selected = freezed,Object? isBooking = null,Object? bookingError = freezed,}) {
  return _then(SeatSelectionReady(
seats: null == seats ? _self._seats : seats // ignore: cast_nullable_to_non_nullable
as List<Seat>,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Seat?,isBooking: null == isBooking ? _self.isBooking : isBooking // ignore: cast_nullable_to_non_nullable
as bool,bookingError: freezed == bookingError ? _self.bookingError : bookingError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $SeatCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}

/// @nodoc


class SeatSelectionBooked implements SeatSelectionState {
  const SeatSelectionBooked(this.record);
  

 final  BookingRecord record;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatSelectionBookedCopyWith<SeatSelectionBooked> get copyWith => _$SeatSelectionBookedCopyWithImpl<SeatSelectionBooked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatSelectionBooked&&(identical(other.record, record) || other.record == record));
}


@override
int get hashCode {
    return Object.hash(runtimeType,record);
}

@override
String toString() {
    return 'SeatSelectionState.booked(record: $record)';
}


}

/// @nodoc
abstract mixin class $SeatSelectionBookedCopyWith<$Res> implements $SeatSelectionStateCopyWith<$Res> {
  factory $SeatSelectionBookedCopyWith(SeatSelectionBooked value, $Res Function(SeatSelectionBooked) _then) = _$SeatSelectionBookedCopyWithImpl;
@useResult
$Res call({
 BookingRecord record
});


$BookingRecordCopyWith<$Res> get record;

}
/// @nodoc
class _$SeatSelectionBookedCopyWithImpl<$Res>
    implements $SeatSelectionBookedCopyWith<$Res> {
  _$SeatSelectionBookedCopyWithImpl(this._self, this._then);

  final SeatSelectionBooked _self;
  final $Res Function(SeatSelectionBooked) _then;

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? record = null,}) {
  return _then(SeatSelectionBooked(
null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as BookingRecord,
  ));
}

/// Create a copy of SeatSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingRecordCopyWith<$Res> get record {
  
  return $BookingRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

// dart format on
