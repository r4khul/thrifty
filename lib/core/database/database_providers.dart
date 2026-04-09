import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'daos/account_dao.dart';
import 'daos/attachment_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/budget_alert_dao.dart';
import 'database.dart';

part 'database_providers.g.dart';

/// Derives the database name from auth state.
/// Persists the name during loading states to avoid flickering and unnecessary DB recreations.
@riverpod
class DbName extends _$DbName {
  @override
  String build() {
    return 'db_default.sqlite';
  }
}

/// Provider for the central database instance.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final name = ref.watch(dbNameProvider);

  // Drift warns if multiple instances of the same class are alive.
  // This happens during user-switch transitions where the old DB is closing async
  // while the new one is opening. Since they use different files/executors, it's safe.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final db = AppDatabase(_openConnection(name));

  // Clean up the database when the provider is disposed or the name changes
  ref.onDispose(() async {
    await db.close();
  });

  return db;
}

LazyDatabase _openConnection(String dbName) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file into the documents folder
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));
    return NativeDatabase.createInBackground(file);
  });
}

/// Provider for [TransactionDao].
@riverpod
TransactionDao transactionDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionDao(db);
}

/// Provider for [CategoryDao].
@riverpod
CategoryDao categoryDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryDao(db);
}

/// Provider for [AttachmentDao].
@riverpod
AttachmentDao attachmentDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AttachmentDao(db);
}

/// Provider for [AccountDao].
@riverpod
AccountDao accountDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountDao(db);
}

/// Provider for [BudgetAlertDao].
@riverpod
BudgetAlertDao budgetAlertDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetAlertDao(db);
}
