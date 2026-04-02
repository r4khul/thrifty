// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountEntity _$AccountEntityFromJson(Map<String, dynamic> json) =>
    _AccountEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      bankName: json['bankName'] as String,
      type:
          $enumDecodeNullable(_$AccountTypeEnumMap, json['type']) ??
          AccountType.savings,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF2E5BFF,
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0xe1b1,
      editedLocally: json['editedLocally'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AccountEntityToJson(_AccountEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bankName': instance.bankName,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'balance': instance.balance,
      'colorValue': instance.colorValue,
      'iconCodePoint': instance.iconCodePoint,
      'editedLocally': instance.editedLocally,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AccountTypeEnumMap = {
  AccountType.savings: 'savings',
  AccountType.checking: 'checking',
  AccountType.cash: 'cash',
  AccountType.investment: 'investment',
  AccountType.credit: 'credit',
};
