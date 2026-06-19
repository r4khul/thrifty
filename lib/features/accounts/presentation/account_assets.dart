import 'package:flutter/material.dart';

class AccountAssets {
  AccountAssets._();

  static const IconData _fallback = Icons.account_balance_wallet_rounded;

  static final Map<int, IconData> icons = {
    Icons.account_balance_wallet_rounded.codePoint:
        Icons.account_balance_wallet_rounded,
    Icons.account_balance_rounded.codePoint: Icons.account_balance_rounded,
    Icons.savings_rounded.codePoint: Icons.savings_rounded,
    Icons.payments_rounded.codePoint: Icons.payments_rounded,
    Icons.credit_card_rounded.codePoint: Icons.credit_card_rounded,
    Icons.trending_up_rounded.codePoint: Icons.trending_up_rounded,
    Icons.monetization_on_rounded.codePoint: Icons.monetization_on_rounded,
    Icons.wallet_rounded.codePoint: Icons.wallet_rounded,
    Icons.attach_money_rounded.codePoint: Icons.attach_money_rounded,
    Icons.currency_exchange_rounded.codePoint: Icons.currency_exchange_rounded,
    Icons.receipt_long_rounded.codePoint: Icons.receipt_long_rounded,
    Icons.business_center_rounded.codePoint: Icons.business_center_rounded,
  };

  /// Returns the [IconData] for the given [codePoint].
  /// Falls back to [Icons.account_balance_wallet_rounded] for unknown values.
  static IconData getIcon(int codePoint) => icons[codePoint] ?? _fallback;
}
