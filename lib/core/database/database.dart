import 'package:drift/drift.dart';
import 'daos/account_dao.dart';
import 'daos/attachment_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/budget_alert_dao.dart';
import 'tables.dart';

part 'database.g.dart';

/// Central database service using Drift.
/// Orchestrates the schema and prepares the app for offline-first data management.
@DriftDatabase(
  tables: [Accounts, Transactions, Categories, Attachments, BudgetAlerts],
  daos: [
    AccountDao,
    TransactionDao,
    CategoryDao,
    AttachmentDao,
    BudgetAlertDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();

        final now = DateTime.now().millisecondsSinceEpoch;
        final defaultCategories = [
          CategoriesCompanion.insert(
            id: 'cat_food',
            name: 'Food & Dining',
            icon: 'restaurant_rounded',
            color: 0xFFEF4444,
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'cat_transport',
            name: 'Transportation',
            icon: 'directions_car_rounded',
            color: 0xFF3B82F6,
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'cat_shopping',
            name: 'Shopping',
            icon: 'shopping_bag_rounded',
            color: 0xFF8B5CF6,
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'cat_bills',
            name: 'Bills & Utilities',
            icon: 'receipt_rounded',
            color: 0xFFF59E0B,
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'cat_health',
            name: 'Healthcare',
            icon: 'local_hospital_rounded',
            color: 0xFF10B981,
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'cat_salary',
            name: 'Salary',
            icon: 'payments_rounded',
            color: 0xFF14B8A6,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        await batch((b) => b.insertAll(categories, defaultCategories));
      },
      onUpgrade: (m, from, to) async {
        if (from < 4) {
          // Add the new Accounts table for schema version 4.
          await m.createTable(accounts);
        }
        if (from < 5) {
          // Add optional account binding for transactions.
          await m.addColumn(transactions, transactions.accountId);
        }
        if (from < 6) {
          // Add budget column to categories.
          await m.addColumn(categories, categories.budget);
        }
        if (from < 7) {
          // Add BudgetAlerts table for schema version 7.
          await m.createTable(budgetAlerts);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        // await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
