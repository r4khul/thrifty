// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_alert_dao.dart';

// ignore_for_file: type=lint
mixin _$BudgetAlertDaoMixin on DatabaseAccessor<AppDatabase> {
  $BudgetAlertsTable get budgetAlerts => attachedDatabase.budgetAlerts;
  BudgetAlertDaoManager get managers => BudgetAlertDaoManager(this);
}

class BudgetAlertDaoManager {
  final _$BudgetAlertDaoMixin _db;
  BudgetAlertDaoManager(this._db);
  $$BudgetAlertsTableTableManager get budgetAlerts =>
      $$BudgetAlertsTableTableManager(_db.attachedDatabase, _db.budgetAlerts);
}
