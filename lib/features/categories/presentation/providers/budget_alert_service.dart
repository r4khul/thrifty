import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:thrifty/core/database/database.dart';
import 'package:thrifty/core/database/database_providers.dart';
import 'package:thrifty/core/database/daos/budget_alert_dao.dart';
import 'package:thrifty/features/categories/data/category_repository_provider.dart';

part 'budget_alert_service.g.dart';

@riverpod
class BudgetAlertService extends _$BudgetAlertService {
  @override
  void build() {}

  Future<void> checkBudget(String categoryId) async {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final category = await categoryRepo.getById(categoryId);
    
    if (category == null || (category.budget ?? 0) <= 0) {
      return;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final period = now.year * 100 + now.month;

    final txDao = ref.read(transactionDaoProvider);
    final currentSpending = await txDao.getCategorySpendingInRange(
      categoryId,
      startOfMonth,
      endOfMonth,
    );

    final budgetLimit = category.budget ?? 0.0;
    final percentage = (currentSpending / budgetLimit) * 100;

    final alertDao = ref.read(budgetAlertDaoProvider);

    if (percentage >= 95) {
      await _createAlertIfMissing(
        alertDao,
        categoryId,
        95,
        period,
        currentSpending,
        budgetLimit,
      );
    } else if (percentage >= 80) {
      await _createAlertIfMissing(
        alertDao,
        categoryId,
        80,
        period,
        currentSpending,
        budgetLimit,
      );
    }
  }

  Future<void> _createAlertIfMissing(
    BudgetAlertDao alertDao,
    String categoryId,
    int threshold,
    int period,
    double currentSpending,
    double budgetLimit,
  ) async {
    final existing = await alertDao.getAlert(categoryId, threshold, period);
    if (existing == null) {
      final alert = BudgetAlert(
        id: const Uuid().v4(),
        categoryId: categoryId,
        threshold: threshold,
        period: period,
        isRead: false,
        amountSpent: currentSpending,
        budgetLimit: budgetLimit,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await alertDao.upsert(alert);
    }
  }
}
