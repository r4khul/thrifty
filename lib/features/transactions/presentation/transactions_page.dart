import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/features/analytics/domain/financial_data_models.dart';
import 'package:thrifty/features/analytics/presentation/widgets/category_donut_chart.dart';
import 'package:thrifty/core/util/formatting_utils.dart';
import 'package:thrifty/l10n/app_localizations.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/theme_extension.dart';
import '../../../features/settings/presentation/providers/currency_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../categories/domain/category_entity.dart';
import '../../categories/presentation/providers/category_map_provider.dart';
import '../../categories/presentation/widgets/category_assets.dart';
import '../../profile/presentation/providers/user_profile_provider.dart';
import '../data/transaction_repository_provider.dart';
import '../domain/transaction_entity.dart';
import 'providers/date_filter_provider.dart';
import 'providers/transaction_providers.dart';
import 'widgets/date_range_selector.dart';
import '../../../core/providers/privacy_provider.dart';

/// Transactions Feature Presentation: List of financial transactions.
/// Implements a professional fintech-grade list with states.
class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final dateRangeFilter = ref.watch(dateFilterControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thrifty.'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: transactionsAsync.when(
                data: (txs) => Text(
                  l10n.transactionCount(txs.length),
                  key: const ValueKey('count'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                loading: () => Text(
                  ' ',
                  key: const ValueKey('loading'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                error: (error, stack) => Text(
                  ' ',
                  key: const ValueKey('error'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
      endDrawer: const _AppDrawer(),
      body: Column(
        children: [
          const DateRangeSelector(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _EmptyState(
                      key: const ValueKey('empty'),
                      onAction: () => _openAddTransaction(context),
                    );
                  }
                  return categoryMapAsync.when(
                    data: (categoryMap) => RefreshIndicator(
                      key: const ValueKey('list'),
                      onRefresh: () async {
                        try {
                          await ref
                              .read(transactionRepositoryProvider)
                              .syncWithRemote();
                        } on Object catch (_) {
                          // Fail silently or show toast
                        }
                      },
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverPersistentHeader(
                              floating: true,
                              delegate: _SummaryHeaderDelegate(
                                child: _CashFlowSummarySection(
                                  transactions: transactions,
                                  categoryMap: categoryMap,
                                  currencySymbol: currencySymbol,
                                  activeFilterLabel: dateRangeFilter.label,
                                ),
                              ),
                            ),
                          ];
                        },
                        body: RepaintBoundary(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.05, 0.95, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: transactions.length,
                              itemExtent: 72,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final category = categoryMap[tx.categoryId];
                                return Dismissible(
                                  key: Key(tx.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) =>
                                      _showDeleteConfirmation(context, ref, tx),
                                  onDismissed: (direction) {
                                    ref
                                        .read(
                                          transactionControllerProvider
                                              .notifier,
                                        )
                                        .deleteTransaction(tx.id);
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                  },
                                  child: _TransactionTile(
                                    transaction: tx,
                                    category: category,
                                    currencySymbol: currencySymbol,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    loading: () =>
                        const _LoadingState(key: ValueKey('loading_cats')),
                    error: (e, s) => _ErrorState(
                      key: const ValueKey('error_cats'),
                      message: l10n.failedLoadCategories,
                      onRetry: () => ref.refresh(categoryMapProvider),
                    ),
                  );
                },
                loading: () =>
                    const _LoadingState(key: ValueKey('loading_txs')),
                error: (error, stack) => _ErrorState(
                  key: const ValueKey('error_txs'),
                  message: error.toString(),
                  onRetry: () => ref
                      .read(transactionControllerProvider.notifier)
                      .refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        tooltip: l10n.addTransaction,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    context.push('/add-tx');
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity transaction,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransactionConfirmTitle),
        content: Text(l10n.deleteTransactionConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _CashFlowSummarySection extends ConsumerWidget {
  const _CashFlowSummarySection({
    required this.transactions,
    required this.categoryMap,
    required this.currencySymbol,
    required this.activeFilterLabel,
  });

  final List<TransactionEntity> transactions;
  final Map<String, CategoryEntity> categoryMap;
  final String currencySymbol;
  final String activeFilterLabel;

  String _obscureText(String text, bool isObscured) {
    return isObscured ? '••••' : text;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.isDarkMode;
    final isObscured = ref.watch(privacyModeProvider);

    var totalIncome = 0.0;
    var totalExpense = 0.0;
    final expenseByCategory = <String, double>{};

    for (final tx in transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        final amount = tx.absoluteAmount;
        totalExpense += amount;
        expenseByCategory.update(
          tx.categoryId,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }

    final net = totalIncome - totalExpense;
    final categoryBreakdown = expenseByCategory.entries.map((entry) {
      final category = categoryMap[entry.key];
      final percentage = totalExpense == 0
          ? 0.0
          : (entry.value / totalExpense) * 100;

      return CategorySpend(
        categoryId: entry.key,
        categoryName: category?.name ?? 'Unknown',
        categoryIcon: category?.icon ?? 'category',
        categoryColor: category?.color ?? AppColors.grey500.toARGB32(),
        amount: entry.value,
        percentage: percentage,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.incomeVsExpense,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                        Text(
                          activeFilterLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.grey500,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      ref.read(privacyModeProvider.notifier).toggle();
                    },
                    icon: Icon(
                      isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.grey500,
                    ),
                    tooltip: isObscured ? 'Show' : 'Hide',
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: totalExpense > 0
                        ? () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              backgroundColor: Theme.of(context).canvasColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) => _WhereMoneyWentSheet(
                                categoryBreakdown: categoryBreakdown,
                                totalExpense: totalExpense,
                                currencySymbol: currencySymbol,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: AppColors.grey500,
                    ),
                    tooltip: l10n.whereYourMoneyGoes,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _FlowMetricCard(
                      label: l10n.income,
                      value: _obscureText(
                        FormattingUtils.formatCompact(
                          totalIncome,
                          symbol: currencySymbol,
                        ),
                        isObscured,
                      ),
                      color: AppColors.success,
                      icon: Icons.south_west_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FlowMetricCard(
                      label: l10n.expense,
                      value: _obscureText(
                        FormattingUtils.formatCompact(
                          totalExpense,
                          symbol: currencySymbol,
                        ),
                        isObscured,
                      ),
                      color: AppColors.error,
                      icon: Icons.north_east_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.net,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.grey500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _obscureText(
                        FormattingUtils.formatCompact(
                          net,
                          symbol: currencySymbol,
                        ),
                        isObscured,
                      ),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: net >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowMetricCard extends StatelessWidget {
  const _FlowMetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhereMoneyWentSheet extends StatelessWidget {
  const _WhereMoneyWentSheet({
    required this.categoryBreakdown,
    required this.totalExpense,
    required this.currencySymbol,
  });

  final List<CategorySpend> categoryBreakdown;
  final double totalExpense;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whereYourMoneyGoes,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Center(
              child: CategoryDonutChart(
                data: categoryBreakdown,
                totalExpense: totalExpense,
                size: 220,
                currencySymbol: currencySymbol,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categoryBreakdown.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = categoryBreakdown[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color(item.categoryColor),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.currencySymbol,
  });

  final TransactionEntity transaction;
  final CategoryEntity? category;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscured = ref.watch(privacyModeProvider);
    final l10n = AppLocalizations.of(context)!;
    final amountColor = transaction.isIncome
        ? AppColors.success
        : AppColors.error;
    final semanticsLabel =
        '${transaction.isIncome ? 'Income' : 'Expense'}: ${transaction.formattedAbsoluteAmount}';

    final amountText = isObscured
        ? '••••'
        : '${transaction.displaySign}$currencySymbol${transaction.compactAbsoluteAmount}';

    final iconData = CategoryAssets.getIcon(category?.icon);
    final color = category != null ? Color(category!.color) : AppColors.grey500;

    return InkWell(
      onTap: () => context.push('/tx/${transaction.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: color,
                size: 24,
                semanticLabel: category?.name ?? 'Category icon',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.displayDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.editedLocally) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.edited,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.fontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Semantics(
              label: semanticsLabel,
              child: Text(
                amountText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.grey200.withValues(alpha: 0.1),
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    color: AppColors.grey200.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: AppColors.grey200.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
              width: 60,
              color: AppColors.grey200.withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noTransactionsYet,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.startTrackingDescription,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: Text(l10n.addTransaction),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.somethingWentWrong,
              textAlign: TextAlign.center,
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 50)),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.getOverlayStyle(isDark: context.isDarkMode),
      child: Drawer(
        backgroundColor: Theme.of(context).canvasColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final profileAsync = ref.watch(
                      userProfileControllerProvider,
                    );
                    final savingsAsync = ref.watch(currentYearSavingsProvider);
                    final currencyAsync = ref.watch(currencyControllerProvider);
                    final currencySymbol = currencyAsync.value?.symbol ?? '\$';

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          profileAsync.value?.name ?? l10n.user,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.push('/profile');
                                        },
                                        icon: const Icon(
                                          Icons.edit_note_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: l10n.editProfile,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    l10n.savingsTarget,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.grey500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Savings Progress Graph (Linear Loader)
                        if (profileAsync.hasValue && savingsAsync.hasValue) ...[
                          Builder(
                            builder: (context) {
                              final goal =
                                  profileAsync.value?.yearlySavingsGoal ?? 1.0;
                              final current = savingsAsync.value ?? 0.0;
                              final isOverTarget = current > goal;
                              final barProgress = (current / goal)
                                  .clamp(0.0, 1.0)
                                  .toDouble();
                              final realPercentage = (current / goal * 100)
                                  .toInt();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              FormattingUtils.formatCompact(
                                                current,
                                                symbol: currencySymbol,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isOverTarget
                                                        ? AppColors.success
                                                        : AppColors.primary,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (isOverTarget)
                                              Text(
                                                '${l10n.surplus}: ${FormattingUtils.formatCompact(current - goal, symbol: currencySymbol)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: AppColors.success,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (isOverTarget) ...[
                                            const Icon(
                                              Icons.stars_rounded,
                                              color: AppColors.success,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            '$realPercentage%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: isOverTarget
                                                      ? AppColors.success
                                                      : AppColors.grey500,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: barProgress,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isOverTarget
                                                ? AppColors.success
                                                : AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${l10n.goal}: ${FormattingUtils.formatCompact(goal, symbol: currencySymbol)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.grey500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Divider(height: 1),
              _ThemeToggle(),

              // Menu Items
              _DrawerItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Accounts',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/accounts');
                },
              ),
              _DrawerItem(
                icon: Icons.category_outlined,
                label: l10n.categories,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.push('/categories');
                },
              ),
              _DrawerItem(
                icon: Icons.refresh_rounded,
                label: l10n.syncData,
                onTap: () {
                  ref.read(transactionControllerProvider.notifier).refresh();
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.bar_chart_rounded,
                label: l10n.analytics,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/analytics');
                },
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: l10n.settings,
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.push('/settings');
                },
              ),
              const Spacer(),

              // Logout
              const Divider(height: 1),
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: l10n.signOut,
                color: AppColors.error,
                onTap: () {
                  ref.read(authControllerProvider.notifier).logout();
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: color ?? AppColors.grey500, size: 24),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(
        isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: AppColors.grey500,
        size: 24,
      ),
      title: Text(
        isDark ? l10n.darkMode : l10n.lightMode,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (_) =>
            ref.read(themeControllerProvider.notifier).toggleTheme(),
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

class _SummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SummaryHeaderDelegate({required this.child, this.maxHeight = 170.0});

  final Widget child;
  final double maxHeight;

  @override
  double get minExtent => 0.0;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    double progress = shrinkOffset / maxExtent;
    double opacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);

    return ClipRect(
      child: OverflowBox(
        maxHeight: maxExtent,
        alignment: Alignment.topCenter,
        child: Opacity(opacity: opacity, child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SummaryHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.maxHeight != maxHeight;
  }
}
