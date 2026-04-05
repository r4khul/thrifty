import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/theme_extension.dart';
import 'package:thrifty/features/accounts/domain/account_entity.dart';
import 'package:thrifty/features/accounts/presentation/providers/account_providers.dart';
import 'package:thrifty/features/categories/presentation/widgets/category_assets.dart';

// ─── Predefined colour palette for account cards ─────────────────────────────

const _kCardColors = CategoryAssets.palette;

const _kDefaultAccountIcon = Icons.account_balance_wallet_rounded;

/// Add / Edit Account Modal-style Page.
class AddEditAccountPage extends ConsumerStatefulWidget {
  const AddEditAccountPage({super.key, this.account});

  /// If non-null, we are editing. Otherwise creating.
  final AccountEntity? account;

  @override
  ConsumerState<AddEditAccountPage> createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends ConsumerState<AddEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedType = AccountType.savings;
  Color _selectedColor = _kCardColors.first;
  bool _loading = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    if (acc != null) {
      _nameController.text = acc.name;
      _bankController.text = acc.bankName;
      _balanceController.text = acc.balance.toStringAsFixed(2);
      _selectedType = acc.type;
      _selectedColor = Color(acc.colorValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final acc =
        widget.account?.copyWith(
          name: _nameController.text.trim(),
          bankName: _bankController.text.trim(),
          balance: double.tryParse(_balanceController.text) ?? 0.0,
          type: _selectedType,
          colorValue: _selectedColor.toARGB32(),
          iconCodePoint: _kDefaultAccountIcon.codePoint,
        ) ??
        AccountEntity(
          id: '',
          name: _nameController.text.trim(),
          bankName: _bankController.text.trim(),
          balance: double.tryParse(_balanceController.text) ?? 0.0,
          type: _selectedType,
          colorValue: _selectedColor.toARGB32(),
          iconCodePoint: _kDefaultAccountIcon.codePoint,
        );

    try {
      await ref.read(accountControllerProvider.notifier).upsertAccount(acc);
      if (mounted) {
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go('/home');
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Card Preview ─────────────────────────────────────────────────
            _CardPreview(
              name: _nameController.text.isEmpty
                  ? 'Account Name'
                  : _nameController.text,
              bank: _bankController.text.isEmpty
                  ? 'Bank Name'
                  : _bankController.text,
              type: _selectedType,
              balance: double.tryParse(_balanceController.text) ?? 0.0,
              color: _selectedColor,
              icon: _kDefaultAccountIcon,
            ),
            const SizedBox(height: 28),

            // ── Account Name ─────────────────────────────────────────────────
            _SectionLabel('Account Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., My HDFC Savings',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter an account name'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Bank Name ────────────────────────────────────────────────────
            TextFormField(
              controller: _bankController,
              decoration: const InputDecoration(
                labelText: 'Bank / Institution',
                hintText: 'e.g., HDFC, SBI, Cash',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a bank name'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Balance ──────────────────────────────────────────────────────
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Current Balance',
                hintText: '0.00',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a balance';
                }
                if (double.tryParse(v) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Card Colour ──────────────────────────────────────────────────
            _SectionLabel('Card Color'),
            const SizedBox(height: 12),
            _ColorPicker(
              selected: _selectedColor,
              colors: _kCardColors,
              onChanged: (c) => setState(() => _selectedColor = c),
            ),
            const SizedBox(height: 40),

            // ── Save Button ──────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: Text(_isEditing ? 'Update Account' : 'Create Account'),
            ),

            // ── Delete button for edit mode ──────────────────────────────────
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Delete Account'),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(accountControllerProvider.notifier)
          .deleteAccount(widget.account!.id);
      // ignore: use_build_context_synchronously
      if (mounted) Navigator.of(context).pop(true);
    }
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.grey500,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selected,
    required this.colors,
    required this.onChanged,
  });

  final Color selected;
  final List<Color> colors;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = selected == color;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Live card preview at the top of the form.
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.name,
    required this.bank,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
  });

  final String name;
  final String bank;
  final AccountType type;
  final double balance;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
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
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        bank,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type.displayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Current Balance',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${balance.toStringAsFixed(2)}',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
