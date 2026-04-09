// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_templates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionTemplateRepository)
final transactionTemplateRepositoryProvider =
    TransactionTemplateRepositoryProvider._();

final class TransactionTemplateRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionTemplateRepository,
          TransactionTemplateRepository,
          TransactionTemplateRepository
        >
    with $Provider<TransactionTemplateRepository> {
  TransactionTemplateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionTemplateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionTemplateRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionTemplateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionTemplateRepository create(Ref ref) {
    return transactionTemplateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionTemplateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionTemplateRepository>(
        value,
      ),
    );
  }
}

String _$transactionTemplateRepositoryHash() =>
    r'671301147827e7fc2648378f8884de46eb9bbb96';

@ProviderFor(TransactionTemplates)
final transactionTemplatesProvider = TransactionTemplatesProvider._();

final class TransactionTemplatesProvider
    extends
        $AsyncNotifierProvider<
          TransactionTemplates,
          List<TransactionTemplateEntity>
        > {
  TransactionTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionTemplatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionTemplatesHash();

  @$internal
  @override
  TransactionTemplates create() => TransactionTemplates();
}

String _$transactionTemplatesHash() =>
    r'29fc785b6ed1538f60894638b4417a877fcc9453';

abstract class _$TransactionTemplates
    extends $AsyncNotifier<List<TransactionTemplateEntity>> {
  FutureOr<List<TransactionTemplateEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TransactionTemplateEntity>>,
              List<TransactionTemplateEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionTemplateEntity>>,
                List<TransactionTemplateEntity>
              >,
              AsyncValue<List<TransactionTemplateEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
