// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionEntity _$TransactionEntityFromJson(Map<String, dynamic> json) =>
    _TransactionEntity(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category'] as String,
      accountId: json['accountId'] as String?,
      timestamp: DateTime.parse(json['ts'] as String),
      note: json['note'] as String?,
      editedLocally: json['editedLocally'] as bool? ?? false,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TransactionEntityToJson(_TransactionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'category': instance.categoryId,
      'accountId': instance.accountId,
      'ts': instance.timestamp.toIso8601String(),
      'note': instance.note,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
