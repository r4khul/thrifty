import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/settings/presentation/providers/currency_provider.dart';
import '../../accounts/domain/account_entity.dart';
import '../../accounts/presentation/providers/account_providers.dart';

import '../../categories/domain/category_entity.dart';
import '../../categories/presentation/providers/category_providers.dart';
import '../../categories/presentation/widgets/category_assets.dart';
import '../domain/attachment_entity.dart';
import '../domain/transaction_entity.dart';
import '../domain/transaction_template_entity.dart';
import 'providers/transaction_providers.dart';
import 'providers/transaction_templates_provider.dart';

/// Presentation: UI for adding or editing a transaction.
class AddEditTransactionPage extends ConsumerStatefulWidget {
  const AddEditTransactionPage({
    super.key,
    this.transactionId,
    this.initialAccountId,
  });

  final String? transactionId;
  final String? initialAccountId;

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
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;
  List<AttachmentEntity> _attachments = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialAccountId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      if (widget.transactionId != null) {
        ref.read(transactionByIdProvider(widget.transactionId!)).whenData((tx) {
          if (tx != null) {
            _amountController.text = tx.absoluteAmount.toString();
            _selectedCategoryId = tx.categoryId;
            _selectedAccountId = tx.accountId;
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
      if (_selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account/bank')),
        );
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
        accountId: _selectedAccountId,
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

  void _showTemplatesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _TemplatesSheet(
          onSelect: (template) {
            setState(() {
              if (template.amount != null) {
                _amountController.text = template.amount.toString();
              }
              if (template.categoryId != null) {
                _selectedCategoryId = template.categoryId;
              }
              if (template.accountId != null) {
                _selectedAccountId = template.accountId;
              }
              if (template.note != null) {
                _noteController.text = template.note!;
              }
              _isIncome = template.isIncome;
            });
            Navigator.pop(context);
          },
          onAutoSave: (template) {
            setState(() {
              if (template.amount != null) {
                _amountController.text = template.amount.toString();
              }
              if (template.categoryId != null) {
                _selectedCategoryId = template.categoryId;
              }
              if (template.accountId != null) {
                _selectedAccountId = template.accountId;
              }
              if (template.note != null) {
                _noteController.text = template.note!;
              }
              _isIncome = template.isIncome;
            });
            Navigator.pop(context);
            // Must delay to allow state updates or just invoke save.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _save();
            });
          },
        );
      },
    );
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
    final accountsAsync = ref.watch(accountControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);
    final currencyAsync = ref.watch(currencyControllerProvider);
    final currencySymbol = currencyAsync.value?.symbol ?? '\$';

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTransaction : l10n.newTransaction),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            color: Colors.amber,
            tooltip: 'Templates',
            onPressed: () => _showTemplatesSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
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

                Text(
                  l10n.amount,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
                  'Account / Bank',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return InkWell(
                        onTap: () => context.push('/add-account'),
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
                          child: const Row(
                            children: [
                              Icon(Icons.account_balance_outlined, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add an account first before creating a transaction',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _AccountSelector(
                      accounts: accounts,
                      selectedId: _selectedAccountId,
                      onSelected: (id) =>
                          setState(() => _selectedAccountId = id),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Failed to load accounts: $e'),
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
                  loading: () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.loading,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
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
                  child: Text(
                    isEditing ? l10n.saveChanges : l10n.addTransaction,
                  ),
                ),
              ],
            ),
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
            const SizedBox(width: 12),
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
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CategoryPicker(
        categories: categories,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
    );
  }
}

class _CategoryPicker extends StatefulWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  final _searchController = TextEditingController();
  late List<CategoryEntity> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = widget.categories
          .where((cat) => cat.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/categories');
                  },
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add Category',
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? const Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(color: AppColors.grey500),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _filteredCategories[index];
                      return ListTile(
                        onTap: () {
                          widget.onSelected(cat.id);
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          CategoryAssets.icons[cat.icon] ??
                              Icons.category_rounded,
                          color: Color(cat.color),
                        ),
                        title: Text(cat.name),
                        selected: cat.id == widget.selectedId,
                        selectedTileColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  const _AccountSelector({
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  final List<AccountEntity> accounts;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = accounts.cast<AccountEntity?>().firstWhere(
      (a) => a?.id == selectedId,
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
                IconData(selected.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(selected.colorValue),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      selected.bankName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Select account',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
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
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return ListTile(
            onTap: () {
              onSelected(account.id);
              Navigator.pop(context);
            },
            leading: Icon(
              IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Color(account.colorValue),
            ),
            title: Text(account.name),
            subtitle: Text(account.bankName),
            selected: account.id == selectedId,
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

class _TemplatesSheet extends ConsumerWidget {
  const _TemplatesSheet({required this.onSelect, required this.onAutoSave});

  final void Function(TransactionTemplateEntity) onSelect;
  final void Function(TransactionTemplateEntity) onAutoSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(transactionTemplatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      minChildSize: 0.4,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply Template',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select to pre-fill parameters',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/templates');
                      },
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Manage Templates',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: templatesAsync.when(
                  data: (templates) {
                    if (templates.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flash_off_rounded,
                              size: 48,
                              color: AppColors.grey300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Templates found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: templates.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        final cardColor = isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard;
                        final borderColor = isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder;
                        final iconColor = template.isIncome
                            ? AppColors.success
                            : AppColors.error;

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  onSelect(template), // Normal tap: apply
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: iconColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        template.isIncome
                                            ? Icons.south_west_rounded
                                            : Icons.north_east_rounded,
                                        color: iconColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            template.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (template.amount != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '\$${template.amount!.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.grey500,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Variable amount',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.grey500,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Thunder button: automatically saves it
                                    Tooltip(
                                      message: 'One-click apply & save',
                                      child: IconButton.filled(
                                        onPressed: () => onAutoSave(template),
                                        icon: const Icon(
                                          Icons.flash_on_rounded,
                                          size: 18,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              Colors.amber.shade100,
                                          foregroundColor:
                                              Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
