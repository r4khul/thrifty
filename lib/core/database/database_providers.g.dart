// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Derives the database name from auth state.
/// Persists the name during loading states to avoid flickering and unnecessary DB recreations.

@ProviderFor(DbName)
final dbNameProvider = DbNameProvider._();

/// Derives the database name from auth state.
/// Persists the name during loading states to avoid flickering and unnecessary DB recreations.
final class DbNameProvider extends $NotifierProvider<DbName, String> {
  /// Derives the database name from auth state.
  /// Persists the name during loading states to avoid flickering and unnecessary DB recreations.
  DbNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dbNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dbNameHash();

  @$internal
  @override
  DbName create() => DbName();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$dbNameHash() => r'0be2bac22a9370a5fa74d216cb8e1cad14ce438c';

/// Derives the database name from auth state.
/// Persists the name during loading states to avoid flickering and unnecessary DB recreations.

abstract class _$DbName extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for the central database instance.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Provider for the central database instance.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Provider for the central database instance.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'1cfc1b8766f2e8800b161198d47548ef29359af1';

/// Provider for [TransactionDao].

@ProviderFor(transactionDao)
final transactionDaoProvider = TransactionDaoProvider._();

/// Provider for [TransactionDao].

final class TransactionDaoProvider
    extends $FunctionalProvider<TransactionDao, TransactionDao, TransactionDao>
    with $Provider<TransactionDao> {
  /// Provider for [TransactionDao].
  TransactionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDaoHash();

  @$internal
  @override
  $ProviderElement<TransactionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionDao create(Ref ref) {
    return transactionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDao>(value),
    );
  }
}

String _$transactionDaoHash() => r'48ea95b9fcf7511052aee36292a05f55970edf5a';

/// Provider for [CategoryDao].

@ProviderFor(categoryDao)
final categoryDaoProvider = CategoryDaoProvider._();

/// Provider for [CategoryDao].

final class CategoryDaoProvider
    extends $FunctionalProvider<CategoryDao, CategoryDao, CategoryDao>
    with $Provider<CategoryDao> {
  /// Provider for [CategoryDao].
  CategoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryDaoHash();

  @$internal
  @override
  $ProviderElement<CategoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryDao create(Ref ref) {
    return categoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryDao>(value),
    );
  }
}

String _$categoryDaoHash() => r'18f9327b1de0cf114a1d95c297638bab8cb09ffa';

/// Provider for [AttachmentDao].

@ProviderFor(attachmentDao)
final attachmentDaoProvider = AttachmentDaoProvider._();

/// Provider for [AttachmentDao].

final class AttachmentDaoProvider
    extends $FunctionalProvider<AttachmentDao, AttachmentDao, AttachmentDao>
    with $Provider<AttachmentDao> {
  /// Provider for [AttachmentDao].
  AttachmentDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentDaoHash();

  @$internal
  @override
  $ProviderElement<AttachmentDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttachmentDao create(Ref ref) {
    return attachmentDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttachmentDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttachmentDao>(value),
    );
  }
}

String _$attachmentDaoHash() => r'76d05cda6a8bfedb54a45be46968fe3383f99e5c';

/// Provider for [AccountDao].

@ProviderFor(accountDao)
final accountDaoProvider = AccountDaoProvider._();

/// Provider for [AccountDao].

final class AccountDaoProvider
    extends $FunctionalProvider<AccountDao, AccountDao, AccountDao>
    with $Provider<AccountDao> {
  /// Provider for [AccountDao].
  AccountDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDaoHash();

  @$internal
  @override
  $ProviderElement<AccountDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountDao create(Ref ref) {
    return accountDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDao>(value),
    );
  }
}

String _$accountDaoHash() => r'96e41bb5f96f9637bb3ffebd344a47b3a3526194';
