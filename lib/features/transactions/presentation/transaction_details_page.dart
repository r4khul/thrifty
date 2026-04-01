import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/util/formatting_utils.dart';
import '../../../core/util/theme_extension.dart';
import '../../../features/settings/presentation/providers/currency_provider.dart';
import '../../categories/presentation/providers/category_map_provider.dart';
import '../../categories/presentation/widgets/category_assets.dart';
import '../domain/transaction_entity.dart';
import 'providers/transaction_providers.dart';

/// Transaction Details Feature Presentation: Detailed view of a specific transaction.
/// Implements a sophisticated, read-only view with edit capability.
class TransactionDetailsPage extends ConsumerWidget {
  const TransactionDetailsPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details),
        actions: [
          transactionAsync.whenOrNull(
                data: (tx) => tx != null
                    ? IconButton(
                        onPressed: () => context.push('/edit-tx/$id'),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: AppLocalizations.of(context)!.editTransaction,
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: transactionAsync.when(
        data: (tx) =>
            tx == null ? const _NotFoundState() : _DetailsView(transaction: tx),
        loading: () => const _LoadingState(),
        error: (e, s) => _ErrorState(message: e.toString()),
      ),
    );
  }
}

class _DetailsView extends ConsumerWidget {
  const _DetailsView({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountColor = transaction.isIncome
        ? AppColors.success
        : AppColors.error;
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final category = categoryMapAsync.value?[transaction.categoryId];

    final currencyAsync = ref.watch(currencyControllerProvider);
    final currencySymbol = currencyAsync.value?.symbol ?? '\$';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Header
          Center(
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    final iconData = category != null
                        ? CategoryAssets.getIcon(category.icon)
                        : (transaction.isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded);
                    final color = category != null
                        ? Color(category.color)
                        : amountColor;
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: color,
                        size: 48,
                        semanticLabel: category?.name ?? 'Category icon',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Semantics(
                  label:
                      '${transaction.isIncome ? AppLocalizations.of(context)!.income : AppLocalizations.of(context)!.expense}: ${transaction.formattedAbsoluteAmount}',
                  child: Text(
                    '${transaction.displaySign}${FormattingUtils.formatFullCurrency(transaction.absoluteAmount, symbol: currencySymbol)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  category?.name ?? 'Unknown',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Details List
          _DetailRow(
            label: AppLocalizations.of(context)!.status,
            value: AppLocalizations.of(context)!.completed,
            icon: Icons.check_circle_outline,
          ),
          _DetailRow(
            label: AppLocalizations.of(context)!.date,
            value: transaction.displayDate,
            icon: Icons.calendar_today_outlined,
          ),
          _DetailRow(
            label: AppLocalizations.of(context)!.time,
            value: transaction.displayTime,
            icon: Icons.access_time_rounded,
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            _DetailRow(
              label: AppLocalizations.of(context)!.note,
              value: transaction.note!,
              icon: Icons.notes_rounded,
            ),

          if (transaction.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.attachments,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...transaction.attachments.map(
              (attachment) => InkWell(
                onTap: () => _openAttachment(context, attachment.filePath),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 20,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (attachment.sizeBytes != null)
                              Text(
                                '${(attachment.sizeBytes! / 1024).toStringAsFixed(1)} KB',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.grey500),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 20,
                        color: AppColors.grey400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Delete Action
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              label: Text(
                AppLocalizations.of(context)!.deleteTransaction,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteTransactionConfirmTitle,
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteTransactionConfirmMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(transactionControllerProvider.notifier)
            .deleteTransaction(transaction.id);

        if (context.mounted) {
          // Success Feedback
          // Go back to the transactions list
          context.pop();
        }
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _openAttachment(BuildContext context, String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.couldNotOpenFile}: ${result.message}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.grey600),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: context.isDarkMode ? AppColors.grey800 : AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.transactionNotFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.movedOrDeleted,
            style: TextStyle(color: AppColors.grey500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.goBack),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $message',
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}
