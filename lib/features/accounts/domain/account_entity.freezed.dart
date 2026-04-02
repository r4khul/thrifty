// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountEntity {

/// Unique stable identifier.
 String get id;/// Account display name (e.g., "My HDFC Savings").
 String get name;/// Bank or institution name (e.g., "HDFC", "Cash", "Zerodha").
 String get bankName;/// Account type classification.
 AccountType get type;/// Current balance of this account.
 double get balance;/// Color value (ARGB int) used for card theming.
 int get colorValue;/// Material icon codepoint for the account card.
 int get iconCodePoint;/// Sync flag: true when local changes need to be pushed remotely.
 bool get editedLocally;/// When this account was first created.
 DateTime? get createdAt;/// When this account was last updated.
 DateTime? get updatedAt;
/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountEntityCopyWith<AccountEntity> get copyWith => _$AccountEntityCopyWithImpl<AccountEntity>(this as AccountEntity, _$identity);

  /// Serializes this AccountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.type, type) || other.type == type)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.iconCodePoint, iconCodePoint) || other.iconCodePoint == iconCodePoint)&&(identical(other.editedLocally, editedLocally) || other.editedLocally == editedLocally)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,bankName,type,balance,colorValue,iconCodePoint,editedLocally,createdAt,updatedAt);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, bankName: $bankName, type: $type, balance: $balance, colorValue: $colorValue, iconCodePoint: $iconCodePoint, editedLocally: $editedLocally, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AccountEntityCopyWith<$Res>  {
  factory $AccountEntityCopyWith(AccountEntity value, $Res Function(AccountEntity) _then) = _$AccountEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String bankName, AccountType type, double balance, int colorValue, int iconCodePoint, bool editedLocally, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AccountEntityCopyWithImpl<$Res>
    implements $AccountEntityCopyWith<$Res> {
  _$AccountEntityCopyWithImpl(this._self, this._then);

  final AccountEntity _self;
  final $Res Function(AccountEntity) _then;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? bankName = null,Object? type = null,Object? balance = null,Object? colorValue = null,Object? iconCodePoint = null,Object? editedLocally = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,iconCodePoint: null == iconCodePoint ? _self.iconCodePoint : iconCodePoint // ignore: cast_nullable_to_non_nullable
as int,editedLocally: null == editedLocally ? _self.editedLocally : editedLocally // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountEntity].
extension AccountEntityPatterns on AccountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountEntity value)  $default,){
final _that = this;
switch (_that) {
case _AccountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String bankName,  AccountType type,  double balance,  int colorValue,  int iconCodePoint,  bool editedLocally,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.bankName,_that.type,_that.balance,_that.colorValue,_that.iconCodePoint,_that.editedLocally,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String bankName,  AccountType type,  double balance,  int colorValue,  int iconCodePoint,  bool editedLocally,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AccountEntity():
return $default(_that.id,_that.name,_that.bankName,_that.type,_that.balance,_that.colorValue,_that.iconCodePoint,_that.editedLocally,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String bankName,  AccountType type,  double balance,  int colorValue,  int iconCodePoint,  bool editedLocally,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AccountEntity() when $default != null:
return $default(_that.id,_that.name,_that.bankName,_that.type,_that.balance,_that.colorValue,_that.iconCodePoint,_that.editedLocally,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountEntity implements AccountEntity {
  const _AccountEntity({required this.id, required this.name, required this.bankName, this.type = AccountType.savings, this.balance = 0.0, this.colorValue = 0xFF2E5BFF, this.iconCodePoint = 0xe1b1, this.editedLocally = false, this.createdAt, this.updatedAt});
  factory _AccountEntity.fromJson(Map<String, dynamic> json) => _$AccountEntityFromJson(json);

/// Unique stable identifier.
@override final  String id;
/// Account display name (e.g., "My HDFC Savings").
@override final  String name;
/// Bank or institution name (e.g., "HDFC", "Cash", "Zerodha").
@override final  String bankName;
/// Account type classification.
@override@JsonKey() final  AccountType type;
/// Current balance of this account.
@override@JsonKey() final  double balance;
/// Color value (ARGB int) used for card theming.
@override@JsonKey() final  int colorValue;
/// Material icon codepoint for the account card.
@override@JsonKey() final  int iconCodePoint;
/// Sync flag: true when local changes need to be pushed remotely.
@override@JsonKey() final  bool editedLocally;
/// When this account was first created.
@override final  DateTime? createdAt;
/// When this account was last updated.
@override final  DateTime? updatedAt;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountEntityCopyWith<_AccountEntity> get copyWith => __$AccountEntityCopyWithImpl<_AccountEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.type, type) || other.type == type)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.iconCodePoint, iconCodePoint) || other.iconCodePoint == iconCodePoint)&&(identical(other.editedLocally, editedLocally) || other.editedLocally == editedLocally)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,bankName,type,balance,colorValue,iconCodePoint,editedLocally,createdAt,updatedAt);

@override
String toString() {
  return 'AccountEntity(id: $id, name: $name, bankName: $bankName, type: $type, balance: $balance, colorValue: $colorValue, iconCodePoint: $iconCodePoint, editedLocally: $editedLocally, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AccountEntityCopyWith<$Res> implements $AccountEntityCopyWith<$Res> {
  factory _$AccountEntityCopyWith(_AccountEntity value, $Res Function(_AccountEntity) _then) = __$AccountEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String bankName, AccountType type, double balance, int colorValue, int iconCodePoint, bool editedLocally, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AccountEntityCopyWithImpl<$Res>
    implements _$AccountEntityCopyWith<$Res> {
  __$AccountEntityCopyWithImpl(this._self, this._then);

  final _AccountEntity _self;
  final $Res Function(_AccountEntity) _then;

/// Create a copy of AccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? bankName = null,Object? type = null,Object? balance = null,Object? colorValue = null,Object? iconCodePoint = null,Object? editedLocally = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AccountEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,iconCodePoint: null == iconCodePoint ? _self.iconCodePoint : iconCodePoint // ignore: cast_nullable_to_non_nullable
as int,editedLocally: null == editedLocally ? _self.editedLocally : editedLocally // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
