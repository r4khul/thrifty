import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thrifty/core/database/database.dart';
import 'package:thrifty/core/database/database_providers.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/features/categories/presentation/providers/category_providers.dart';
import 'package:thrifty/features/categories/presentation/widgets/category_assets.dart';
import 'package:intl/intl.dart';

class BudgetAlertsPage extends ConsumerWidget {
  const BudgetAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsStream = ref.watch(budgetAlertDaoProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Alerts'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(budgetAlertDaoProvider).markAllAsRead();
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: alertsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final alerts = snapshot.data ?? [];
          
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, 
                    size: 64, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text('No budget alerts yet', 
                    style: TextStyle(color: AppColors.grey500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(alert: alert);
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});

  final BudgetAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryControllerProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == alert.categoryId,
          orElse: () => categories.first,
        );
        
        final iconData = CategoryAssets.getIcon(category.icon);
        final color = Color(category.color);
        final date = DateTime.fromMillisecondsSinceEpoch(alert.createdAt);
        final dateStr = DateFormat('MMM d, h:mm a').format(date);

        return InkWell(
          onTap: () {
            ref.read(budgetAlertDaoProvider).markAsRead(alert.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: alert.isRead 
                  ? Theme.of(context).colorScheme.surface 
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: alert.isRead 
                    ? Theme.of(context).colorScheme.outline 
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            alert.threshold >= 95 
                                ? 'Critical Budget Alert' 
                                : 'Budget Warning',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: alert.threshold >= 95 ? AppColors.error : AppColors.warning,
                                ),
                          ),
                          Text(
                            dateStr,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.grey500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have spent ${alert.amountSpent.toStringAsFixed(0)} of your ${alert.budgetLimit.toStringAsFixed(0)} budget for ${category.name}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spend wisely to stay within your limits!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.grey600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!alert.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, left: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
