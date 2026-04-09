import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_alert_dao.g.dart';

/// DAO for [BudgetAlerts] table.
@DriftAccessor(tables: [BudgetAlerts])
class BudgetAlertDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetAlertDaoMixin {
  BudgetAlertDao(super.db);

  /// Watches all alerts ordered by creation time descending.
  Stream<List<BudgetAlert>> watchAll() {
    return (select(budgetAlerts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Watches unread alerts.
  Stream<List<BudgetAlert>> watchUnread() {
    return (select(budgetAlerts)
          ..where((t) => t.isRead.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Returns count of unread alerts.
  Stream<int> watchUnreadCount() {
    final query = select(budgetAlerts)..where((t) => t.isRead.equals(false));
    return query.watch().map((list) => list.length);
  }

  /// Marks all alerts as read.
  Future<void> markAllAsRead() {
    return (update(budgetAlerts)..where((t) => t.isRead.equals(false)))
        .write(const BudgetAlertsCompanion(isRead: Value(true)));
  }

  /// Marks a specific alert as read.
  Future<void> markAsRead(String id) {
    return (update(budgetAlerts)..where((t) => t.id.equals(id)))
        .write(const BudgetAlertsCompanion(isRead: Value(true)));
  }

  /// Upserts an alert.
  Future<void> upsert(BudgetAlert row) {
    return into(budgetAlerts).insertOnConflictUpdate(row);
  }

  /// Deletes an alert.
  Future<int> deleteById(String id) {
    return (delete(budgetAlerts)..where((t) => t.id.equals(id))).go();
  }

  /// Checks if an alert for a specific category, threshold, and period already exists.
  Future<BudgetAlert?> getAlert(String categoryId, int threshold, int period) {
    return (select(budgetAlerts)
          ..where((t) =>
              t.categoryId.equals(categoryId) &
              t.threshold.equals(threshold) &
              t.period.equals(period)))
        .getSingleOrNull();
  }
}
