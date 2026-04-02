import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

/// The type of a financial account.
enum AccountType {
  savings,
  checking,
  cash,
  investment,
  credit;

  String get displayName {
    switch (this) {
      case AccountType.savings:
        return 'Savings';
      case AccountType.checking:
        return 'Checking';
      case AccountType.cash:
        return 'Cash';
      case AccountType.investment:
        return 'Investment';
      case AccountType.credit:
        return 'Credit Card';
    }
  }

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountType.savings,
    );
  }
}

/// Domain Entity: Represents a user's financial account (wallet).
///
/// Business Rules:
/// - Each account has a balance that is independently tracked.
/// - Account type determines UI representation (icon, color hints).
@freezed
abstract class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    /// Unique stable identifier.
    required String id,

    /// Account display name (e.g., "My HDFC Savings").
    required String name,

    /// Bank or institution name (e.g., "HDFC", "Cash", "Zerodha").
    required String bankName,

    /// Account type classification.
    @Default(AccountType.savings) AccountType type,

    /// Current balance of this account.
    @Default(0.0) double balance,

    /// Color value (ARGB int) used for card theming.
    @Default(0xFF2E5BFF) int colorValue,

    /// Material icon codepoint for the account card.
    @Default(0xe1b1) int iconCodePoint,

    /// Sync flag: true when local changes need to be pushed remotely.
    @Default(false) bool editedLocally,

    /// When this account was first created.
    DateTime? createdAt,

    /// When this account was last updated.
    DateTime? updatedAt,
  }) = _AccountEntity;

  factory AccountEntity.fromJson(Map<String, dynamic> json) =>
      _$AccountEntityFromJson(json);
}
