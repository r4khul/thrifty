import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_providers.dart';
import '../domain/account_repository.dart';
import 'account_repository_impl.dart';

part 'account_repository_provider.g.dart';

/// Provider for [AccountRepository].
@riverpod
AccountRepository accountRepository(Ref ref) {
  final dao = ref.watch(accountDaoProvider);
  return AccountRepositoryImpl(dao);
}
