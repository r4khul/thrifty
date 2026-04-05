import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/util/formatting_utils.dart';
import 'attachment_entity.dart';

part 'transaction_entity.freezed.dart';
part 'transaction_entity.g.dart';

/// Domain Entity: Represents a financial transaction.
///
/// **Business Rules & Invariants:**
/// 1. **Amount Sign**: The sign of [amount] determines its type:
///    - Positive (> 0) represents Income.
///    - Negative (< 0) represents Expense.
///    - Neutral (0) is valid but has no impact on balances.
/// 2. **Immutability**: Once created, the [id] and [timestamp] are authoritative
///    and must not change.
/// 3. **Sync State**: [editedLocally] reflects only the synchronization status
///    with remote sources and does not affect domain logic.
/// 4. **Unified Treatment**: All transactions (imported vs manual) are equal
///    citizens in the domain.
@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    /// Unique stable identifier. Invariant: Stable and immutable.
    required String id,

    /// Monetary amount. Sign determines income (+) vs expense (-).
    required double amount,

    /// The unique identifier of the associated category.
    @JsonKey(name: 'category') required String categoryId,

    /// The unique identifier of the associated account.
    String? accountId,

    /// Authoritative timestamp of when the transaction occurred.
    @JsonKey(name: 'ts') required DateTime timestamp,

    /// Optional user-provided description or context.
    String? note,

    /// Internal flag representing local state vs remote persistence.
    @JsonKey(includeToJson: false) @Default(false) bool editedLocally,

    /// Metadata: Last modified timestamp.
    DateTime? updatedAt,

    /// List of attached files.
    @JsonKey(includeToJson: false)
    @Default([])
    List<AttachmentEntity> attachments,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntityFromJson(json);

  const TransactionEntity._();

  /// Returns true if the transaction represents an inflow of funds.
  bool get isIncome => amount > 0;

  /// Returns true if the transaction represents an outflow of funds.
  bool get isExpense => amount < 0;

  /// Returns the absolute magnitude of the transaction regardless of sign.
  double get absoluteAmount => amount.abs();

  /// Returns the amount formatted for display (e.g., "50.00").
  /// Constraint: Moved from UI to maintain pure widgets.
  String get formattedAbsoluteAmount => absoluteAmount.toStringAsFixed(2);

  /// Returns a human-readable compact version of the amount (e.g. 1.2K).
  String get compactAbsoluteAmount =>
      FormattingUtils.formatCompact(absoluteAmount);

  /// Returns the symbol prefix based on transaction type.
  String get displaySign => isIncome ? '+' : '-';

  /// Returns a formatted date string (e.g., "8 Feb").
  String get displayDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]}';
  }

  /// Returns a formatted time string (e.g., "14:30").
  String get displayTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}
