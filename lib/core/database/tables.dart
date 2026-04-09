import 'package:drift/drift.dart';

/// Accounts table schema.
/// Represents wallet/bank accounts owned by the user.
class Accounts extends Table {
  /// Unique stable identifier. Primary Key.
  TextColumn get id => text()();

  /// Display name of the account (e.g., "My Savings").
  TextColumn get name => text()();

  /// Name of the bank or institution (e.g., "Chase", "SBI").
  TextColumn get bankName => text()();

  /// Account type string: "savings", "checking", "cash", "investment", "credit".
  TextColumn get type => text().withDefault(const Constant('savings'))();

  /// Current balance of the account.
  RealColumn get balance => real().withDefault(const Constant(0.0))();

  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFF6366F1))();

  /// Icon codepoint for the account (Material icon code).
  IntColumn get iconCodePoint =>
      integer().withDefault(const Constant(0xe1b1))(); // account_balance_wallet

  /// Synchronization state.
  BoolColumn get editedLocally =>
      boolean().withDefault(const Constant(false))();

  /// Metadata: Timestamp of when the record was first inserted.
  IntColumn get createdAt => integer()();

  /// Metadata: Timestamp of when the record was last modified locally.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Categories table schema.
/// Unique classifications for transactions, acting as a lookup for the Transactions table.
class Categories extends Table {
  /// Unique stable identifier. Primary Key.
  TextColumn get id => text()();

  /// The display name of the category.
  TextColumn get name => text()();

  /// Icon name or code point.
  TextColumn get icon => text()();

  /// Color value (ARGB hex or int).
  IntColumn get color => integer()();

  /// Optional budget limit for this category.
  RealColumn get budget => real().nullable()();

  /// Synchronization state.
  BoolColumn get editedLocally =>
      boolean().withDefault(const Constant(false))();

  /// Metadata: Timestamp of when the record was first inserted.
  IntColumn get createdAt => integer()();

  /// Metadata: Timestamp of when the record was last modified locally.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transactions table schema.
/// Represents the authoritative local record of all financial events.
@TableIndex(name: 'tx_filter_idx', columns: {#timestamp, #categoryId})
class Transactions extends Table {
  /// Unique stable identifier. Primary Key.
  /// This ID is preserved across syncs to ensure idempotency.
  TextColumn get id => text()();

  /// Monetary amount. Sign determines income (+) vs expense (-).
  /// Aligned with the TransactionEntity domain invariant.
  RealColumn get amount => real()();

  /// The category ID associated with this transaction.
  /// References [Categories.id].
  TextColumn get categoryId => text()();

  /// Optional account/wallet ID associated with this transaction.
  /// References [Accounts.id] logically; kept nullable for backward compatibility.
  TextColumn get accountId => text().nullable()();

  /// Authoritative domain timestamp (stored as epoch millis).
  /// Represents when the transaction actually occurred.
  IntColumn get timestamp => integer()();

  /// Optional user-provided description or context.
  TextColumn get note => text().nullable()();

  /// Synchronization state: true if the record was modified locally
  /// and needs to be pushed to the remote source.
  BoolColumn get editedLocally =>
      boolean().withDefault(const Constant(false))();

  /// Metadata: Timestamp of when the record was first inserted into the local DB.
  IntColumn get createdAt => integer()();

  /// Metadata: Timestamp of when the record was last modified in the local DB.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Attachments table schema.
/// Stores metadata for files attached to transactions.
class Attachments extends Table {
  /// Unique identifier. Primary Key.
  TextColumn get id => text()();

  /// The transaction this attachment belongs to.
  /// References [Transactions.id].
  TextColumn get transactionId => text().references(Transactions, #id)();

  /// Original file name.
  TextColumn get fileName => text()();

  /// Absolute local file path.
  TextColumn get filePath => text()();

  /// File MIME type (e.g. image/jpeg).
  TextColumn get mimeType => text().nullable()();

  /// File size in bytes.
  IntColumn get sizeBytes => integer().nullable()();

  /// When the attachment was added.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// BudgetAlerts table schema.
/// Tracks notifications when category spending exceeds budget thresholds (e.g. 80%, 95%).
class BudgetAlerts extends Table {
  /// Unique identifier. Primary Key.
  TextColumn get id => text()();

  /// The category this alert belongs to.
  TextColumn get categoryId => text()();

  /// The threshold percentage reached (e.g. 80, 95).
  IntColumn get threshold => integer()();

  /// Month and year of the alert (stored as YYYYMM).
  IntColumn get period => integer()();

  /// Whether the alert has been read by the user.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// Amount spent at the time of the alert.
  RealColumn get amountSpent => real()();

  /// Budget limit at the time of the alert.
  RealColumn get budgetLimit => real()();

  /// Metadata: Timestamp of when the alert was triggered.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
