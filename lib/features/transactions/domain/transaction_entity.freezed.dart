// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionEntity {

/// Unique stable identifier. Invariant: Stable and immutable.
 String get id;/// Monetary amount. Sign determines income (+) vs expense (-).
 double get amount;/// The unique identifier of the associated category.
@JsonKey(name: 'category') String get categoryId;/// The unique identifier of the associated account.
 String? get accountId;/// Authoritative timestamp of when the transaction occurred.
@JsonKey(name: 'ts') DateTime get timestamp;/// Optional user-provided description or context.
 String? get note;/// Internal flag representing local state vs remote persistence.
@JsonKey(includeToJson: false) bool get editedLocally;/// Metadata: Last modified timestamp.
 DateTime? get updatedAt;/// List of attached files.
@JsonKey(includeToJson: false) List<AttachmentEntity> get attachments;
/// Create a copy of TransactionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionEntityCopyWith<TransactionEntity> get copyWith => _$TransactionEntityCopyWithImpl<TransactionEntity>(this as TransactionEntity, _$identity);

  /// Serializes this TransactionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.note, note) || other.note == note)&&(identical(other.editedLocally, editedLocally) || other.editedLocally == editedLocally)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,categoryId,accountId,timestamp,note,editedLocally,updatedAt,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'TransactionEntity(id: $id, amount: $amount, categoryId: $categoryId, accountId: $accountId, timestamp: $timestamp, note: $note, editedLocally: $editedLocally, updatedAt: $updatedAt, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $TransactionEntityCopyWith<$Res>  {
  factory $TransactionEntityCopyWith(TransactionEntity value, $Res Function(TransactionEntity) _then) = _$TransactionEntityCopyWithImpl;
@useResult
$Res call({
 String id, double amount,@JsonKey(name: 'category') String categoryId, String? accountId,@JsonKey(name: 'ts') DateTime timestamp, String? note,@JsonKey(includeToJson: false) bool editedLocally, DateTime? updatedAt,@JsonKey(includeToJson: false) List<AttachmentEntity> attachments
});




}
/// @nodoc
class _$TransactionEntityCopyWithImpl<$Res>
    implements $TransactionEntityCopyWith<$Res> {
  _$TransactionEntityCopyWithImpl(this._self, this._then);

  final TransactionEntity _self;
  final $Res Function(TransactionEntity) _then;

/// Create a copy of TransactionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? categoryId = null,Object? accountId = freezed,Object? timestamp = null,Object? note = freezed,Object? editedLocally = null,Object? updatedAt = freezed,Object? attachments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,editedLocally: null == editedLocally ? _self.editedLocally : editedLocally // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionEntity].
extension TransactionEntityPatterns on TransactionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionEntity value)  $default,){
final _that = this;
switch (_that) {
case _TransactionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount, @JsonKey(name: 'category')  String categoryId,  String? accountId, @JsonKey(name: 'ts')  DateTime timestamp,  String? note, @JsonKey(includeToJson: false)  bool editedLocally,  DateTime? updatedAt, @JsonKey(includeToJson: false)  List<AttachmentEntity> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionEntity() when $default != null:
return $default(_that.id,_that.amount,_that.categoryId,_that.accountId,_that.timestamp,_that.note,_that.editedLocally,_that.updatedAt,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount, @JsonKey(name: 'category')  String categoryId,  String? accountId, @JsonKey(name: 'ts')  DateTime timestamp,  String? note, @JsonKey(includeToJson: false)  bool editedLocally,  DateTime? updatedAt, @JsonKey(includeToJson: false)  List<AttachmentEntity> attachments)  $default,) {final _that = this;
switch (_that) {
case _TransactionEntity():
return $default(_that.id,_that.amount,_that.categoryId,_that.accountId,_that.timestamp,_that.note,_that.editedLocally,_that.updatedAt,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount, @JsonKey(name: 'category')  String categoryId,  String? accountId, @JsonKey(name: 'ts')  DateTime timestamp,  String? note, @JsonKey(includeToJson: false)  bool editedLocally,  DateTime? updatedAt, @JsonKey(includeToJson: false)  List<AttachmentEntity> attachments)?  $default,) {final _that = this;
switch (_that) {
case _TransactionEntity() when $default != null:
return $default(_that.id,_that.amount,_that.categoryId,_that.accountId,_that.timestamp,_that.note,_that.editedLocally,_that.updatedAt,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionEntity extends TransactionEntity {
  const _TransactionEntity({required this.id, required this.amount, @JsonKey(name: 'category') required this.categoryId, this.accountId, @JsonKey(name: 'ts') required this.timestamp, this.note, @JsonKey(includeToJson: false) this.editedLocally = false, this.updatedAt, @JsonKey(includeToJson: false) final  List<AttachmentEntity> attachments = const []}): _attachments = attachments,super._();
  factory _TransactionEntity.fromJson(Map<String, dynamic> json) => _$TransactionEntityFromJson(json);

/// Unique stable identifier. Invariant: Stable and immutable.
@override final  String id;
/// Monetary amount. Sign determines income (+) vs expense (-).
@override final  double amount;
/// The unique identifier of the associated category.
@override@JsonKey(name: 'category') final  String categoryId;
/// The unique identifier of the associated account.
@override final  String? accountId;
/// Authoritative timestamp of when the transaction occurred.
@override@JsonKey(name: 'ts') final  DateTime timestamp;
/// Optional user-provided description or context.
@override final  String? note;
/// Internal flag representing local state vs remote persistence.
@override@JsonKey(includeToJson: false) final  bool editedLocally;
/// Metadata: Last modified timestamp.
@override final  DateTime? updatedAt;
/// List of attached files.
 final  List<AttachmentEntity> _attachments;
/// List of attached files.
@override@JsonKey(includeToJson: false) List<AttachmentEntity> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of TransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionEntityCopyWith<_TransactionEntity> get copyWith => __$TransactionEntityCopyWithImpl<_TransactionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.note, note) || other.note == note)&&(identical(other.editedLocally, editedLocally) || other.editedLocally == editedLocally)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,categoryId,accountId,timestamp,note,editedLocally,updatedAt,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'TransactionEntity(id: $id, amount: $amount, categoryId: $categoryId, accountId: $accountId, timestamp: $timestamp, note: $note, editedLocally: $editedLocally, updatedAt: $updatedAt, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$TransactionEntityCopyWith<$Res> implements $TransactionEntityCopyWith<$Res> {
  factory _$TransactionEntityCopyWith(_TransactionEntity value, $Res Function(_TransactionEntity) _then) = __$TransactionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount,@JsonKey(name: 'category') String categoryId, String? accountId,@JsonKey(name: 'ts') DateTime timestamp, String? note,@JsonKey(includeToJson: false) bool editedLocally, DateTime? updatedAt,@JsonKey(includeToJson: false) List<AttachmentEntity> attachments
});




}
/// @nodoc
class __$TransactionEntityCopyWithImpl<$Res>
    implements _$TransactionEntityCopyWith<$Res> {
  __$TransactionEntityCopyWithImpl(this._self, this._then);

  final _TransactionEntity _self;
  final $Res Function(_TransactionEntity) _then;

/// Create a copy of TransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? categoryId = null,Object? accountId = freezed,Object? timestamp = null,Object? note = freezed,Object? editedLocally = null,Object? updatedAt = freezed,Object? attachments = null,}) {
  return _then(_TransactionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,editedLocally: null == editedLocally ? _self.editedLocally : editedLocally // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentEntity>,
  ));
}


}

// dart format on
