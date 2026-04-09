import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/features/categories/domain/category_entity.dart';
import 'package:thrifty/features/categories/presentation/categories_page.dart';
import 'package:thrifty/features/categories/presentation/providers/budget_providers.dart';
import 'package:thrifty/features/categories/presentation/widgets/category_assets.dart';

class BudgetSetupPage extends ConsumerWidget {
  const BudgetSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCategoriesAsync = ref.watch(filteredBudgetCategoriesProvider);
    final spendingAsync = ref.watch(categoryMonthlySpendingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Setup'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                ref.read(budgetSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: filteredCategoriesAsync.when(
              data: (categories) => spendingAsync.when(
                data: (spending) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final currentSpend = spending[category.id] ?? 0.0;
                    return _BudgetCategoryTile(
                      category: category,
                      currentSpend: currentSpend,
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryTile extends StatelessWidget {
  const _BudgetCategoryTile({
    required this.category,
    required this.currentSpend,
  });

  final CategoryEntity category;
  final double currentSpend;

  @override
  Widget build(BuildContext context) {
    final iconData = CategoryAssets.getIcon(category.icon);
    final color = Color(category.color);
    final hasBudget = category.budget != null && category.budget! > 0;
    final progress = hasBudget ? (currentSpend / category.budget!).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = hasBudget && currentSpend > category.budget!;

    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CategoryForm(category: category),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (hasBudget)
                        Text(
                          '${currentSpend.toStringAsFixed(0)} / ${category.budget!.toStringAsFixed(0)} spent',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isOverBudget ? AppColors.error : AppColors.grey500,
                              ),
                        )
                      else
                        Text(
                          'No budget set',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey500,
                              ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
              ],
            ),
            if (hasBudget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? AppColors.error : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
