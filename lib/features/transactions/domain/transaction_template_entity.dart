import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_template_entity.freezed.dart';
part 'transaction_template_entity.g.dart';

@freezed
abstract class TransactionTemplateEntity with _$TransactionTemplateEntity {
  const factory TransactionTemplateEntity({
    required String id,
    required String name,
    double? amount,
    String? categoryId,
    String? accountId,
    String? note,
    @Default(false) bool isIncome,
  }) = _TransactionTemplateEntity;

  factory TransactionTemplateEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionTemplateEntityFromJson(json);
}
