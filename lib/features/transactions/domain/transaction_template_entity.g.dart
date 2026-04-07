// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_template_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionTemplateEntity _$TransactionTemplateEntityFromJson(
  Map<String, dynamic> json,
) => _TransactionTemplateEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num?)?.toDouble(),
  categoryId: json['categoryId'] as String?,
  accountId: json['accountId'] as String?,
  note: json['note'] as String?,
  isIncome: json['isIncome'] as bool? ?? false,
);

Map<String, dynamic> _$TransactionTemplateEntityToJson(
  _TransactionTemplateEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'accountId': instance.accountId,
  'note': instance.note,
  'isIncome': instance.isIncome,
};
