// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Feature State: Manages the collection of transactions.
/// Responsibility: Provides an observable list of transactions and handles mutative actions.
/// Ownership: Owns the transaction logic; calls repository only.

@ProviderFor(TransactionController)
final transactionControllerProvider = TransactionControllerProvider._();

/// Feature State: Manages the collection of transactions.
/// Responsibility: Provides an observable list of transactions and handles mutative actions.
/// Ownership: Owns the transaction logic; calls repository only.
final class TransactionControllerProvider
    extends
        $StreamNotifierProvider<
          TransactionController,
          List<TransactionEntity>
        > {
  /// Feature State: Manages the collection of transactions.
  /// Responsibility: Provides an observable list of transactions and handles mutative actions.
  /// Ownership: Owns the transaction logic; calls repository only.
  TransactionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionControllerHash();

  @$internal
  @override
  TransactionController create() => TransactionController();
}

String _$transactionControllerHash() =>
    r'618a3255b0a1adc33b0c71d9ef3513034d0d5ed5';

/// Feature State: Manages the collection of transactions.
/// Responsibility: Provides an observable list of transactions and handles mutative actions.
/// Ownership: Owns the transaction logic; calls repository only.

abstract class _$TransactionController
    extends $StreamNotifier<List<TransactionEntity>> {
  Stream<List<TransactionEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TransactionEntity>>,
              List<TransactionEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionEntity>>,
                List<TransactionEntity>
              >,
              AsyncValue<List<TransactionEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Feature State: Exposes a single transaction by its ID.

@ProviderFor(transactionById)
final transactionByIdProvider = TransactionByIdFamily._();

/// Feature State: Exposes a single transaction by its ID.

final class TransactionByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransactionEntity?>,
          TransactionEntity?,
          Stream<TransactionEntity?>
        >
    with
        $FutureModifier<TransactionEntity?>,
        $StreamProvider<TransactionEntity?> {
  /// Feature State: Exposes a single transaction by its ID.
  TransactionByIdProvider._({
    required TransactionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionByIdHash();

  @override
  String toString() {
    return r'transactionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TransactionEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TransactionEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return transactionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionByIdHash() => r'efbe395d6e41108d0eaf13f7b6fe4f4c715f2b2e';

/// Feature State: Exposes a single transaction by its ID.

final class TransactionByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TransactionEntity?>, String> {
  TransactionByIdFamily._()
    : super(
        retry: null,
        name: r'transactionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Feature State: Exposes a single transaction by its ID.

  TransactionByIdProvider call(String id) =>
      TransactionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionByIdProvider';
}

@ProviderFor(AccountFilterController)
final accountFilterControllerProvider = AccountFilterControllerProvider._();

final class AccountFilterControllerProvider
    extends $NotifierProvider<AccountFilterController, String?> {
  AccountFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountFilterControllerHash();

  @$internal
  @override
  AccountFilterController create() => AccountFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$accountFilterControllerHash() =>
    r'f15eb83c10fb69478db7897ee1eaab115f2a0040';

abstract class _$AccountFilterController extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTransactions)
final filteredTransactionsProvider = FilteredTransactionsProvider._();

final class FilteredTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  FilteredTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionEntity>> create(Ref ref) {
    return filteredTransactions(ref);
  }
}

String _$filteredTransactionsHash() =>
    r'e8ae36113b4770e79d9bf37ef92277cb7ded8a28';
