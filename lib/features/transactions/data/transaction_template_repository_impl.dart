import '../domain/transaction_template_entity.dart';
import '../domain/transaction_template_repository.dart';
import 'transaction_template_local_source.dart';

class TransactionTemplateRepositoryImpl
    implements TransactionTemplateRepository {
  TransactionTemplateRepositoryImpl(this.localSource);

  final TransactionTemplateLocalSource localSource;

  @override
  Future<List<TransactionTemplateEntity>> getTemplates() {
    return localSource.getTemplates();
  }

  @override
  Future<void> addTemplate(TransactionTemplateEntity template) {
    return localSource.addTemplate(template);
  }

  @override
  Future<void> updateTemplate(TransactionTemplateEntity template) {
    return localSource.updateTemplate(template);
  }

  @override
  Future<void> deleteTemplate(String id) {
    return localSource.deleteTemplate(id);
  }
}
