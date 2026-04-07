// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryController)
final categoryControllerProvider = CategoryControllerProvider._();

final class CategoryControllerProvider
    extends $StreamNotifierProvider<CategoryController, List<CategoryEntity>> {
  CategoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryControllerHash();

  @$internal
  @override
  CategoryController create() => CategoryController();
}

String _$categoryControllerHash() =>
    r'6d26da03b3625b15fcb30c5de9e91cb987649526';

abstract class _$CategoryController
    extends $StreamNotifier<List<CategoryEntity>> {
  Stream<List<CategoryEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CategoryEntity>>, List<CategoryEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CategoryEntity>>,
                List<CategoryEntity>
              >,
              AsyncValue<List<CategoryEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(categoryById)
final categoryByIdProvider = CategoryByIdFamily._();

final class CategoryByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryEntity?>,
          CategoryEntity?,
          Stream<CategoryEntity?>
        >
    with $FutureModifier<CategoryEntity?>, $StreamProvider<CategoryEntity?> {
  CategoryByIdProvider._({
    required CategoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryByIdHash();

  @override
  String toString() {
    return r'categoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<CategoryEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CategoryEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryByIdHash() => r'0f889716e6ad018d1e26c413e5fbb1c1271d9e36';

final class CategoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<CategoryEntity?>, String> {
  CategoryByIdFamily._()
    : super(
        retry: null,
        name: r'categoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryByIdProvider call(String id) =>
      CategoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryByIdProvider';
}
