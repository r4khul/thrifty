// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_template_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionTemplateEntity {

 String get id; String get name; double? get amount; String? get categoryId; String? get accountId; String? get note; bool get isIncome;
/// Create a copy of TransactionTemplateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionTemplateEntityCopyWith<TransactionTemplateEntity> get copyWith => _$TransactionTemplateEntityCopyWithImpl<TransactionTemplateEntity>(this as TransactionTemplateEntity, _$identity);

  /// Serializes this TransactionTemplateEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionTemplateEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.note, note) || other.note == note)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,categoryId,accountId,note,isIncome);

@override
String toString() {
  return 'TransactionTemplateEntity(id: $id, name: $name, amount: $amount, categoryId: $categoryId, accountId: $accountId, note: $note, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class $TransactionTemplateEntityCopyWith<$Res>  {
  factory $TransactionTemplateEntityCopyWith(TransactionTemplateEntity value, $Res Function(TransactionTemplateEntity) _then) = _$TransactionTemplateEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, double? amount, String? categoryId, String? accountId, String? note, bool isIncome
});




}
/// @nodoc
class _$TransactionTemplateEntityCopyWithImpl<$Res>
    implements $TransactionTemplateEntityCopyWith<$Res> {
  _$TransactionTemplateEntityCopyWithImpl(this._self, this._then);

  final TransactionTemplateEntity _self;
  final $Res Function(TransactionTemplateEntity) _then;

/// Create a copy of TransactionTemplateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = freezed,Object? categoryId = freezed,Object? accountId = freezed,Object? note = freezed,Object? isIncome = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionTemplateEntity].
extension TransactionTemplateEntityPatterns on TransactionTemplateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionTemplateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionTemplateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionTemplateEntity value)  $default,){
final _that = this;
switch (_that) {
case _TransactionTemplateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionTemplateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionTemplateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double? amount,  String? categoryId,  String? accountId,  String? note,  bool isIncome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionTemplateEntity() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.note,_that.isIncome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double? amount,  String? categoryId,  String? accountId,  String? note,  bool isIncome)  $default,) {final _that = this;
switch (_that) {
case _TransactionTemplateEntity():
return $default(_that.id,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.note,_that.isIncome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double? amount,  String? categoryId,  String? accountId,  String? note,  bool isIncome)?  $default,) {final _that = this;
switch (_that) {
case _TransactionTemplateEntity() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.categoryId,_that.accountId,_that.note,_that.isIncome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionTemplateEntity implements TransactionTemplateEntity {
  const _TransactionTemplateEntity({required this.id, required this.name, this.amount, this.categoryId, this.accountId, this.note, this.isIncome = false});
  factory _TransactionTemplateEntity.fromJson(Map<String, dynamic> json) => _$TransactionTemplateEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  double? amount;
@override final  String? categoryId;
@override final  String? accountId;
@override final  String? note;
@override@JsonKey() final  bool isIncome;

/// Create a copy of TransactionTemplateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionTemplateEntityCopyWith<_TransactionTemplateEntity> get copyWith => __$TransactionTemplateEntityCopyWithImpl<_TransactionTemplateEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionTemplateEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionTemplateEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.note, note) || other.note == note)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,categoryId,accountId,note,isIncome);

@override
String toString() {
  return 'TransactionTemplateEntity(id: $id, name: $name, amount: $amount, categoryId: $categoryId, accountId: $accountId, note: $note, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class _$TransactionTemplateEntityCopyWith<$Res> implements $TransactionTemplateEntityCopyWith<$Res> {
  factory _$TransactionTemplateEntityCopyWith(_TransactionTemplateEntity value, $Res Function(_TransactionTemplateEntity) _then) = __$TransactionTemplateEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double? amount, String? categoryId, String? accountId, String? note, bool isIncome
});




}
/// @nodoc
class __$TransactionTemplateEntityCopyWithImpl<$Res>
    implements _$TransactionTemplateEntityCopyWith<$Res> {
  __$TransactionTemplateEntityCopyWithImpl(this._self, this._then);

  final _TransactionTemplateEntity _self;
  final $Res Function(_TransactionTemplateEntity) _then;

/// Create a copy of TransactionTemplateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = freezed,Object? categoryId = freezed,Object? accountId = freezed,Object? note = freezed,Object? isIncome = null,}) {
  return _then(_TransactionTemplateEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
