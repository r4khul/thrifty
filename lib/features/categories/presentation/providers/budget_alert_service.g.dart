// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_alert_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetAlertService)
final budgetAlertServiceProvider = BudgetAlertServiceProvider._();

final class BudgetAlertServiceProvider
    extends $NotifierProvider<BudgetAlertService, void> {
  BudgetAlertServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertServiceHash();

  @$internal
  @override
  BudgetAlertService create() => BudgetAlertService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$budgetAlertServiceHash() =>
    r'212cd472e098ed3c6f5c2e990ded337e70455877';

abstract class _$BudgetAlertService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
