import 'transaction_template_entity.dart';

abstract class TransactionTemplateRepository {
  Future<List<TransactionTemplateEntity>> getTemplates();
  Future<void> addTemplate(TransactionTemplateEntity template);
  Future<void> updateTemplate(TransactionTemplateEntity template);
  Future<void> deleteTemplate(String id);
}
