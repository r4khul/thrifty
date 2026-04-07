import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/theme_extension.dart';
import 'package:thrifty/features/accounts/domain/account_entity.dart';
import 'package:thrifty/features/analytics/presentation/widgets/category_donut_chart.dart';
import 'package:thrifty/features/categories/domain/category_entity.dart';
import 'package:thrifty/features/settings/presentation/providers/currency_provider.dart';
import 'package:thrifty/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:thrifty/features/transactions/presentation/widgets/date_range_selector.dart';
import 'package:thrifty/features/accounts/presentation/account_transactions_search_page.dart';
import 'package:thrifty/features/accounts/presentation/add_edit_account_page.dart';
import 'package:thrifty/features/transactions/presentation/add_edit_transaction_page.dart';
import 'package:thrifty/features/categories/presentation/providers/category_map_provider.dart';
import 'package:thrifty/features/transactions/domain/transaction_entity.dart';
import 'package:thrifty/features/analytics/domain/financial_data_models.dart';

/// Professional Account Details Screen
/// High-fidelity visualization of account performance and transaction history.
class AccountDetailsPage extends ConsumerStatefulWidget {
  const AccountDetailsPage({super.key, required this.account});

  final AccountEntity account;

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // Set account filter for this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountFilterControllerProvider.notifier).selectAccount(widget.account.id);
    });

    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DateRangeSelector(),
                  const SizedBox(height: 24),
                  transactionsAsync.when(
                    data: (txs) => _buildAnalyticsSection(context, txs, categoryMapAsync.value ?? {}, currencySymbol),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading analytics: $e'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _openSearchPage(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Search transactions...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          transactionsAsync.when(
            data: (txs) {
              final categoryMap = categoryMapAsync.value ?? {};
              final filtered = txs.toList();
              
              filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return _buildTransactionList(context, filtered.take(5).toList(), categoryMap, currencySymbol, filtered.length);
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        backgroundColor: Color(widget.account.colorValue),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _openSearchPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountTransactionsSearchPage(account: widget.account),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final cardColor = Color(widget.account.colorValue);
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: cardColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: () => _openEditAccount(context),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          tooltip: 'Edit Account',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardColor, cardColor.withValues(alpha: 0.8)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.account.name,
                  style: AppTypography.titleMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${widget.account.balance.toStringAsFixed(2)}',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.account.bankName,
                    style: AppTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditAccount(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddEditAccountPage(account: widget.account),
      ),
    );
  }

  Widget _buildAnalyticsSection(
    BuildContext context,
    List<TransactionEntity> transactions,
    Map<String, dynamic> categoryMap,
    String currencySymbol,
  ) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalIncome = 0;
    double totalExpense = 0;
    final expenseByCategory = <String, double>{};

    for (final tx in transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.absoluteAmount;
        expenseByCategory.update(tx.categoryId, (v) => v + tx.absoluteAmount, ifAbsent: () => tx.absoluteAmount);
      }
    }

    final categorySpends = expenseByCategory.entries.map((e) {
      final cat = categoryMap[e.key] as CategoryEntity?;
      return CategorySpend(
        categoryId: e.key,
        categoryName: cat?.name ?? 'Unknown',
        categoryIcon: cat?.icon ?? '',
        categoryColor: cat?.color ?? Colors.grey.toARGB32(),
        amount: e.value,
        percentage: totalExpense > 0 ? (e.value / totalExpense) * 100 : 0,
      );
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Income',
                amount: totalIncome,
                color: AppColors.success,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                label: 'Expense',
                amount: totalExpense,
                color: AppColors.error,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (totalExpense > 0) ...[
          Text('Spending by Category', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          CategoryDonutChart(
            data: categorySpends,
            totalExpense: totalExpense,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
    Map<String, dynamic> categoryMap,
    String currencySymbol,
    int totalCount,
  ) {
    if (transactions.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No transactions for this period')),
      );
    }

    final showViewAll = totalCount > 5;
    final itemCount = transactions.length + (showViewAll ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == transactions.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, left: 20, right: 20),
              child: FilledButton.tonal(
                onPressed: () => _openSearchPage(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View All'),
              ),
            );
          }
          final tx = transactions[index];
          final cat = categoryMap[tx.categoryId] as CategoryEntity?;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(cat?.color ?? Colors.grey.toARGB32()).withValues(alpha: 0.1),
              child: Icon(
                Icons.category,
                color: Color(cat?.color ?? Colors.grey.toARGB32()),
                size: 20,
              ),
            ),
            title: Text(cat?.name ?? 'Unknown', style: AppTypography.titleMedium),
            subtitle: Text(DateFormat('dd MMM, yyyy').format(tx.timestamp)),
            trailing: Text(
              '${tx.isIncome ? '+' : '-'} ₹${tx.absoluteAmount.toStringAsFixed(2)}',
              style: AppTypography.titleMedium.copyWith(
                color: tx.isIncome ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => AddEditTransactionPage(initialAccountId: widget.account.id),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.grey500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
