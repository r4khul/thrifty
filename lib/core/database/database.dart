import 'package:drift/drift.dart';
import 'daos/account_dao.dart';
import 'daos/attachment_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables.dart';

part 'database.g.dart';

/// Central database service using Drift.
/// Orchestrates the schema and prepares the app for offline-first data management.
@DriftDatabase(
  tables: [Accounts, Transactions, Categories, Attachments],
  daos: [AccountDao, TransactionDao, CategoryDao, AttachmentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 4) {
          // Add the new Accounts table for schema version 4.
          await m.createTable(accounts);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        // await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
