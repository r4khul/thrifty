import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/settings/presentation/providers/currency_provider.dart';

import '../../categories/domain/category_entity.dart';
import '../../categories/presentation/providers/category_providers.dart';
import '../../categories/presentation/widgets/category_assets.dart';
import '../domain/attachment_entity.dart';
import '../domain/transaction_entity.dart';
import 'providers/transaction_providers.dart';

/// Presentation: UI for adding or editing a transaction.
class AddEditTransactionPage extends ConsumerStatefulWidget {
  const AddEditTransactionPage({super.key, this.transactionId});

  final String? transactionId;

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;
  List<AttachmentEntity> _attachments = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      if (widget.transactionId != null) {
        ref.read(transactionByIdProvider(widget.transactionId!)).whenData((tx) {
          if (tx != null) {
            _amountController.text = tx.absoluteAmount.toString();
            _selectedCategoryId = tx.categoryId;
            _noteController.text = tx.note ?? '';
            _selectedDate = tx.timestamp;
            _isIncome = tx.isIncome;
            _attachments = List.from(tx.attachments);
            setState(() {});
          }
        });
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final l10n = AppLocalizations.of(context)!;
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectCategory)));
        return;
      }

      final transactionId = widget.transactionId ?? const Uuid().v4();

      final amountValue = double.parse(_amountController.text);

      // Ensure attachments have the correct transaction ID
      final updatedAttachments = _attachments
          .map(
            (a) => a.transactionId.isEmpty
                ? a.copyWith(transactionId: transactionId)
                : a,
          )
          .toList();

      final transaction = TransactionEntity(
        id: transactionId,
        amount: amountValue, // Sign handled in controller based on isIncome
        categoryId: _selectedCategoryId!,
        timestamp: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        editedLocally: true,
        attachments: updatedAttachments,
      );

      await ref
          .read(transactionControllerProvider.notifier)
          .upsertTransaction(transaction, isIncome: _isIncome);
      if (mounted) context.pop();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final attachment = AttachmentEntity(
        id: const Uuid().v4(),
        transactionId: widget.transactionId ?? '', // Will fill on save if new
        fileName: file.name,
        filePath: file.path!,
        sizeBytes: file.size,
        createdAt: DateTime.now(),
      );
      setState(() {
        _attachments.add(attachment);
      });
    }
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments.removeWhere((a) => a.id == id);
    });
  }

  Future<void> _openFile(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.couldNotOpenFile}: ${result.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;
    final categoriesAsync = ref.watch(categoryControllerProvider);
    final currencyAsync = ref.watch(currencyControllerProvider);
    final currencySymbol = currencyAsync.value?.symbol ?? '\$';

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTransaction : l10n.newTransaction),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              Row(
                children: [
                  _TypeButton(
                    label: l10n.expense,
                    isSelected: !_isIncome,
                    color: AppColors.error,
                    onTap: () => setState(() => _isIncome = false),
                  ),
                  const SizedBox(width: 12),
                  _TypeButton(
                    label: l10n.income,
                    isSelected: _isIncome,
                    color: AppColors.success,
                    onTap: () => setState(() => _isIncome = true),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(l10n.amount, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  prefixText: '$currencySymbol ',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: _isIncome ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.required;
                  if (double.tryParse(value) == null) return l10n.error;
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Text(
                l10n.category,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return InkWell(
                      onTap: () => context.push('/categories'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.noCategoriesFound,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              l10n.createCategory,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _CategorySelector(
                    categories: categories,
                    selectedId: _selectedCategoryId,
                    onSelected: (id) =>
                        setState(() => _selectedCategoryId = id),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('${l10n.errorLoadingCategories}: $e'),
              ),
              const SizedBox(height: 24),

              Text(l10n.date, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.noteOptional,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(hintText: l10n.descriptionHint),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Attachments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.attachments,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(l10n.add),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    children: _attachments.map((attachment) {
                      return ListTile(
                        dense: true,
                        onTap: () => _openFile(attachment.filePath),
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(
                          attachment.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: attachment.sizeBytes != null
                            ? Text(
                                '${(attachment.sizeBytes! / 1024).toStringAsFixed(1)} KB',
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeAttachment(attachment.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? l10n.saveChanges : l10n.addTransaction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = categories.cast<CategoryEntity?>().firstWhere(
      (c) => c?.id == selectedId,
      orElse: () => null,
    );

    return InkWell(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Icon(
                CategoryAssets.icons[selected.icon] ?? Icons.category_rounded,
                color: Color(selected.color),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selected.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ] else
              Expanded(
                child: Semantics(
                  label: 'Category selector',
                  child: Text(
                    AppLocalizations.of(context)!.selectCategory,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey500,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return ListTile(
            onTap: () {
              onSelected(cat.id);
              Navigator.pop(context);
            },
            leading: Icon(
              CategoryAssets.icons[cat.icon] ?? Icons.category_rounded,
              color: Color(cat.color),
            ),
            title: Text(cat.name),
            selected: cat.id == selectedId,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: '$label transaction type',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? color : AppColors.grey500,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
