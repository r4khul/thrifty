import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/theme_extension.dart';
import 'package:thrifty/features/accounts/domain/account_entity.dart';
import 'package:thrifty/features/categories/presentation/providers/category_map_provider.dart';
import 'package:thrifty/features/settings/presentation/providers/currency_provider.dart';
import 'package:thrifty/features/transactions/presentation/providers/transaction_providers.dart';

class AccountTransactionsSearchPage extends ConsumerStatefulWidget {
  const AccountTransactionsSearchPage({super.key, required this.account});

  final AccountEntity account;

  @override
  ConsumerState<AccountTransactionsSearchPage> createState() =>
      _AccountTransactionsSearchPageState();
}

class _AccountTransactionsSearchPageState
    extends ConsumerState<AccountTransactionsSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortByDateDesc = true;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('${widget.account.name} Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(_sortByDateDesc ? 'Newest First' : 'Oldest First'),
                      selected: true,
                      onSelected: (_) => setState(() => _sortByDateDesc = !_sortByDateDesc),
                    ),
                    const SizedBox(width: 8),
                    categoryMapAsync.when(
                      data: (categoryMap) {
                        return Wrap(
                          spacing: 8,
                          children: categoryMap.values.map((cat) {
                            final category = cat;
                            final isSelected = _selectedCategoryId == category.id;
                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategoryId = selected ? category.id : null;
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final categoryMap = categoryMapAsync.value ?? {};
          
          var filtered = transactions.where((tx) {
            final category = categoryMap[tx.categoryId];
            final matchesSearch = (tx.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) || 
                                (category?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
            final matchesCategory = _selectedCategoryId == null || tx.categoryId == _selectedCategoryId;
            return matchesSearch && matchesCategory;
          }).toList();

          filtered.sort((a, b) => _sortByDateDesc 
              ? b.timestamp.compareTo(a.timestamp) 
              : a.timestamp.compareTo(b.timestamp));

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.grey500),
                  const SizedBox(height: 16),
                  Text('No transactions found', style: AppTypography.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final tx = filtered[index];
              final category = categoryMap[tx.categoryId];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category?.color ?? Colors.grey.value).withValues(alpha: 0.1),
                  child: Icon(
                    Icons.category,
                    color: Color(category?.color ?? Colors.grey.value),
                    size: 20,
                  ),
                ),
                title: Text(category?.name ?? 'Unknown', style: AppTypography.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd MMM, yyyy • HH:mm').format(tx.timestamp)),
                    if (tx.note != null && tx.note!.isNotEmpty)
                      Text(tx.note!, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Text(
                  '${tx.isIncome ? '+' : '-'} $currencySymbol${tx.absoluteAmount.toStringAsFixed(2)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: tx.isIncome ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
