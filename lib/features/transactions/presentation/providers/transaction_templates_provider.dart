import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/transaction_template_repository_impl.dart';
import '../../data/transaction_template_local_source_impl.dart';
import '../../domain/transaction_template_entity.dart';
import '../../domain/transaction_template_repository.dart';

part 'transaction_templates_provider.g.dart';

@riverpod
TransactionTemplateRepository transactionTemplateRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final localSource = TransactionTemplateLocalSourceImpl(prefs);
  return TransactionTemplateRepositoryImpl(localSource);
}

@riverpod
class TransactionTemplates extends _$TransactionTemplates {
  @override
  FutureOr<List<TransactionTemplateEntity>> build() async {
    final repository = ref.watch(transactionTemplateRepositoryProvider);
    return repository.getTemplates();
  }

  Future<void> addTemplate(TransactionTemplateEntity template) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionTemplateRepositoryProvider)
          .addTemplate(template);
      return ref.read(transactionTemplateRepositoryProvider).getTemplates();
    });
  }

  Future<void> updateTemplate(TransactionTemplateEntity template) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionTemplateRepositoryProvider)
          .updateTemplate(template);
      return ref.read(transactionTemplateRepositoryProvider).getTemplates();
    });
  }

  Future<void> deleteTemplate(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionTemplateRepositoryProvider).deleteTemplate(id);
      return ref.read(transactionTemplateRepositoryProvider).getTemplates();
    });
  }
}
