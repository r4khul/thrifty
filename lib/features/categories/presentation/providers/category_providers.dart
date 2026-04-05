import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/category_repository_provider.dart';
import '../../domain/category_entity.dart';

part 'category_providers.g.dart';

@riverpod
class CategoryController extends _$CategoryController {
  @override
  Stream<List<CategoryEntity>> build() async* {
    final repository = ref.watch(categoryRepositoryProvider);

    // Emit local categories immediately so UI can render empty-state cards
    // instead of staying in loading state.
    try {
      final categories = await repository.getAll();
      yield categories;

      if (categories.isEmpty) {
        unawaited(
          Future<void>(() async {
            try {
              await repository.syncWithRemote();
            } on Object catch (_) {
              // If sync fails (e.g. no internet), keep local state.
            }
          }),
        );
      }
    } on Object catch (_) {
      // Fall back to an empty list if initial fetch fails.
      yield const <CategoryEntity>[];
    }

    yield* repository.watchAll();
  }

  void refresh() {
    ref.invalidateSelf();
  }

  Future<void> upsertCategory(CategoryEntity category) async {
    final categoryToSave = category.id.isEmpty
        ? category.copyWith(id: const Uuid().v4())
        : category;
    await ref.read(categoryRepositoryProvider).upsert(categoryToSave);
  }

  Future<void> deleteCategory(String id) async {
    final isUsed = await ref
        .read(categoryRepositoryProvider)
        .isCategoryUsed(id);
    if (isUsed) {
      throw Exception('This category is in use and cannot be deleted.');
    }
    await ref.read(categoryRepositoryProvider).delete(id);
  }

  Future<void> deleteCategoryWithTransactions(String id) async {
    await ref.read(categoryRepositoryProvider).deleteWithTransactions(id);
  }

  Future<void> reassignAndDeleteCategory(String oldId, String newId) async {
    await ref
        .read(categoryRepositoryProvider)
        .reassignAndAndDelete(oldId, newId);
  }
}

@riverpod
Stream<CategoryEntity?> categoryById(Ref ref, String id) {
  return ref.watch(categoryRepositoryProvider).watchById(id);
}
