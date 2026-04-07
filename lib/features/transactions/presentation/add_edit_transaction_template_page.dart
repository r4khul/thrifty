import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/settings/presentation/providers/currency_provider.dart';
import '../../accounts/domain/account_entity.dart';
import '../../accounts/presentation/providers/account_providers.dart';
import '../../categories/domain/category_entity.dart';
import '../../categories/presentation/providers/category_providers.dart';
import '../../categories/presentation/widgets/category_assets.dart';
import '../domain/transaction_template_entity.dart';
import 'providers/transaction_templates_provider.dart';

class AddEditTransactionTemplatePage extends ConsumerStatefulWidget {
  const AddEditTransactionTemplatePage({super.key, this.template});

  final TransactionTemplateEntity? template;

  @override
  ConsumerState<AddEditTransactionTemplatePage> createState() =>
      _AddEditTransactionTemplatePageState();
}

class _AddEditTransactionTemplatePageState
    extends ConsumerState<AddEditTransactionTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedAccountId;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      if (widget.template!.amount != null) {
        _amountController.text = widget.template!.amount.toString();
      }
      _selectedCategoryId = widget.template!.categoryId;
      _selectedAccountId = widget.template!.accountId;
      _noteController.text = widget.template!.note ?? '';
      _isIncome = widget.template!.isIncome;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      double? amount;
      if (_amountController.text.trim().isNotEmpty) {
        amount = double.tryParse(_amountController.text);
      }

      final template = TransactionTemplateEntity(
        id: widget.template?.id ?? const Uuid().v4(),
        name: name,
        amount: amount,
        categoryId: _selectedCategoryId,
        accountId: _selectedAccountId,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isIncome: _isIncome,
      );

      if (widget.template == null) {
        await ref
            .read(transactionTemplatesProvider.notifier)
            .addTemplate(template);
      } else {
        await ref
            .read(transactionTemplatesProvider.notifier)
            .updateTemplate(template);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;
    final accountsAsync = ref.watch(accountControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);
    final currencyAsync = ref.watch(currencyControllerProvider);
    final currencySymbol = currencyAsync.value?.symbol ?? '\$';

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Template' : 'New Template')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                Text(
                  'Template Name *',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Monthly Rent',
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 24),

                // Type Toggle
                Row(
                  children: [
                    _TypeButton(
                      label: 'Expense',
                      isSelected: !_isIncome,
                      color: AppColors.error,
                      onTap: () => setState(() => _isIncome = false),
                    ),
                    const SizedBox(width: 12),
                    _TypeButton(
                      label: 'Income',
                      isSelected: _isIncome,
                      color: AppColors.success,
                      onTap: () => setState(() => _isIncome = true),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  'Amount (Optional)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    prefixText: '$currencySymbol ',
                    hintText: 'Leave empty to input later',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _isIncome ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Account / Bank (Optional)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                accountsAsync.when(
                  data: (accounts) => _AccountSelector(
                    accounts: accounts,
                    selectedId: _selectedAccountId,
                    onSelected: (id) => setState(() => _selectedAccountId = id),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),

                Text(
                  'Category (Optional)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  data: (categories) => _CategorySelector(
                    categories: categories,
                    selectedId: _selectedCategoryId,
                    onSelected: (id) =>
                        setState(() => _selectedCategoryId = id),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),

                Text(
                  'Note (Optional)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(hintText: 'Template note'),
                  maxLines: 3,
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Template' : 'Create Template'),
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
                child: Text(
                  'Select category',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
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
              color: isSelected ? color : Theme.of(context).colorScheme.outline,
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
          ),
        ),
      ),
    );
  }
}
