import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_theme.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/theme_extension.dart';
import 'package:thrifty/features/accounts/domain/account_entity.dart';
import 'package:thrifty/features/accounts/presentation/providers/account_providers.dart';
import 'add_edit_account_page.dart';

// ─── Max cards shown inline on the wallet screen ─────────────────────────────
const _kMaxVisibleCards = 3;

/// Accounts Feature Presentation: Wallet screen showing account cards.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountControllerProvider);
    final isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.getOverlayStyle(isDark: isDark),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('My Wallet'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                onPressed: () => _openAddAccount(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        body: accountsAsync.when(
          data: (accounts) => _Body(accounts: accounts),
          loading: () => const _LoadingState(),
          error: (e, s) => _ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(accountControllerProvider),
          ),
        ),
      ),
    );
  }

  void _openAddAccount(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AddEditAccountPage(),
      ),
    );
  }
}

// ─── Main Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.accounts});
  final List<AccountEntity> accounts;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const _EmptyState();

    final visibleAccounts = accounts.take(_kMaxVisibleCards).toList();
    final hasMore = accounts.length > _kMaxVisibleCards;

    final totalBalance = accounts.fold(0.0, (sum, acc) => sum + acc.balance);
    final isDark = context.isDarkMode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // ── Total Balance Pill ────────────────────────────────────────────────
        _TotalBalanceBanner(total: totalBalance, count: accounts.length),
        const SizedBox(height: 24),

        // ── Section title ─────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Accounts',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (hasMore)
              TextButton.icon(
                onPressed: () => _openAllAccountsSheet(context, accounts),
                icon: const Icon(Icons.apps_rounded, size: 18),
                label: const Text('View All'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Cards ─────────────────────────────────────────────────────────────
        ...visibleAccounts.asMap().entries.map((entry) {
          final account = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AccountCard(
              account: account,
              onTap: () => _openEditAccount(context, account),
            ),
          );
        }),

        // ── "View All" card tile if overflow ──────────────────────────────────
        if (hasMore) ...[
          const SizedBox(height: 4),
          _ViewAllTile(
            remaining: accounts.length - _kMaxVisibleCards,
            isDark: isDark,
            onTap: () => _openAllAccountsSheet(context, accounts),
          ),
        ],
      ],
    );
  }

  void _openEditAccount(BuildContext context, AccountEntity account) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddEditAccountPage(account: account),
      ),
    );
  }

  void _openAllAccountsSheet(
    BuildContext context,
    List<AccountEntity> accounts,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AllAccountsSheet(accounts: accounts),
    );
  }
}

// ─── Total Balance Banner ─────────────────────────────────────────────────────

class _TotalBalanceBanner extends StatelessWidget {
  const _TotalBalanceBanner({required this.total, required this.count});
  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Net Worth',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${_formatBalance(total)}',
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Across $count account${count != 1 ? 's' : ''}',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double value) {
    if (value >= 1e7) return '${(value / 1e7).toStringAsFixed(2)} Cr';
    if (value >= 1e5) return '${(value / 1e5).toStringAsFixed(2)} L';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)} K';
    return value.toStringAsFixed(2);
  }
}

// ─── Account Card ─────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});
  final AccountEntity account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(account.colorValue);
    const icon = Icons.account_balance_wallet_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'account_card_${account.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 168,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: icon + name + type badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              account.bankName,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Edit icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom: balance + type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${account.balance.toStringAsFixed(2)}',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          account.type.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── "View All" tile ──────────────────────────────────────────────────────────

class _ViewAllTile extends StatelessWidget {
  const _ViewAllTile({
    required this.remaining,
    required this.isDark,
    required this.onTap,
  });
  final int remaining;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View All Accounts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '+$remaining more account${remaining != 1 ? 's' : ''}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}

// ─── All Accounts Bottom Sheet ────────────────────────────────────────────────

class _AllAccountsSheet extends StatelessWidget {
  const _AllAccountsSheet({required this.accounts});
  final List<AccountEntity> accounts;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Accounts',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${accounts.length} account${accounts.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Scrollable list of cards
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _AccountCard(
                        account: acc,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => AddEditAccountPage(account: acc),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Accounts Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your bank accounts, savings, and wallets to track your total net worth.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const AddEditAccountPage(),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first account'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(240, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading State ────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.grey800.withValues(alpha: 0.4)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
