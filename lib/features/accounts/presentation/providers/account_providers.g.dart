// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Feature State: Reactive stream of all accounts.

@ProviderFor(AccountController)
final accountControllerProvider = AccountControllerProvider._();

/// Feature State: Reactive stream of all accounts.
final class AccountControllerProvider
    extends $StreamNotifierProvider<AccountController, List<AccountEntity>> {
  /// Feature State: Reactive stream of all accounts.
  AccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountControllerHash();

  @$internal
  @override
  AccountController create() => AccountController();
}

String _$accountControllerHash() => r'b2273a97787383fd36ac1968f78092f5b5170d76';

/// Feature State: Reactive stream of all accounts.

abstract class _$AccountController
    extends $StreamNotifier<List<AccountEntity>> {
  Stream<List<AccountEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AccountEntity>>, List<AccountEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AccountEntity>>, List<AccountEntity>>,
              AsyncValue<List<AccountEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
