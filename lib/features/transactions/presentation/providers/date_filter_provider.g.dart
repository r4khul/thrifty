// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DateFilterController)
final dateFilterControllerProvider = DateFilterControllerProvider._();

final class DateFilterControllerProvider
    extends $NotifierProvider<DateFilterController, DateRangeFilter> {
  DateFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dateFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dateFilterControllerHash();

  @$internal
  @override
  DateFilterController create() => DateFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRangeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRangeFilter>(value),
    );
  }
}

String _$dateFilterControllerHash() =>
    r'0c2b26dbf21b613d14957087180750b9bf588704';

abstract class _$DateFilterController extends $Notifier<DateRangeFilter> {
  DateRangeFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateRangeFilter, DateRangeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateRangeFilter, DateRangeFilter>,
              DateRangeFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
