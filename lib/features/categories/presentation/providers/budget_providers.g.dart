// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetSearchQuery)
final budgetSearchQueryProvider = BudgetSearchQueryProvider._();

final class BudgetSearchQueryProvider
    extends $NotifierProvider<BudgetSearchQuery, String> {
  BudgetSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetSearchQueryHash();

  @$internal
  @override
  BudgetSearchQuery create() => BudgetSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$budgetSearchQueryHash() => r'59cbfdfe1fe358bb9d2d42ff5ad62762d1cdeb09';

abstract class _$BudgetSearchQuery extends $Notifier<String> {
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

@ProviderFor(categoryMonthlySpending)
final categoryMonthlySpendingProvider = CategoryMonthlySpendingProvider._();

final class CategoryMonthlySpendingProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          FutureOr<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  CategoryMonthlySpendingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryMonthlySpendingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryMonthlySpendingHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    return categoryMonthlySpending(ref);
  }
}

String _$categoryMonthlySpendingHash() =>
    r'a027256b848fce81897846f079f68b8016d679ea';

@ProviderFor(filteredBudgetCategories)
final filteredBudgetCategoriesProvider = FilteredBudgetCategoriesProvider._();

final class FilteredBudgetCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryEntity>>,
          List<CategoryEntity>,
          FutureOr<List<CategoryEntity>>
        >
    with
        $FutureModifier<List<CategoryEntity>>,
        $FutureProvider<List<CategoryEntity>> {
  FilteredBudgetCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredBudgetCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredBudgetCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CategoryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryEntity>> create(Ref ref) {
    return filteredBudgetCategories(ref);
  }
}

String _$filteredBudgetCategoriesHash() =>
    r'2039fb79dcb0496e91d9c938123a527799d090f8';
