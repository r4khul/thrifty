import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thrifty/core/providers/locale_provider.dart';
import 'package:thrifty/core/providers/network_providers.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/util/theme_extension.dart';
import 'package:thrifty/features/settings/domain/language.dart';
import 'package:thrifty/features/settings/presentation/providers/currency_provider.dart';
import 'package:thrifty/features/settings/presentation/providers/notification_provider.dart';
import 'package:thrifty/features/settings/presentation/widgets/backend_url_sheet.dart';
import 'package:thrifty/features/settings/presentation/widgets/currency_selector_sheet.dart';
import 'package:thrifty/features/settings/presentation/widgets/language_selector_sheet.dart';
import 'package:thrifty/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyAsync = ref.watch(currencyControllerProvider);
    final notificationSettings = ref.watch(notificationControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: l10n.general),
          const SizedBox(height: 8),

          // Language Selector
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: Colors.orange,
            title: l10n.language,
            subtitle: AppLanguage.availableLanguages
                .firstWhere(
                  (l) => l.languageCode == currentLocale.languageCode,
                  orElse: () => AppLanguage.availableLanguages.first,
                )
                .nativeName,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    (context.isDarkMode
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.grey200)
                        .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLanguage.availableLanguages
                        .firstWhere(
                          (l) => l.languageCode == currentLocale.languageCode,
                          orElse: () => AppLanguage.availableLanguages.first,
                        )
                        .flagEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentLocale.languageCode.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => const LanguageSelectorSheet(),
              );
            },
          ),

          const SizedBox(height: 12),

          // Currency Selector
          _SettingsTile(
            icon: Icons.currency_exchange_rounded,
            iconColor: AppColors.primary,
            title: l10n.currency,
            subtitle: currencyAsync.when(
              data: (c) => '${c.name} (${c.symbol})',
              loading: () => l10n.loading,
              error: (e, s) => '${l10n.error} loading currency',
            ),
            trailing: currencyAsync.when(
              data: (c) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (context.isDarkMode
                              ? theme.colorScheme.surfaceContainerHighest
                              : AppColors.grey200)
                          .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.flagEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      c.code,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, s) =>
                  const Icon(Icons.error_outline, color: AppColors.error),
            ),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => const CurrencySelectorSheet(),
              );
            },
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.notifications),
          const SizedBox(height: 8),

          // Notification Toggle
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.accent,
            title: l10n.dailyReminder,
            subtitle: l10n.notifyTransactionsLogged,
            trailing: Switch.adaptive(
              value: notificationSettings.isEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => ref
                  .read(notificationControllerProvider.notifier)
                  .toggleEnabled(value),
            ),
            onTap: () {
              ref
                  .read(notificationControllerProvider.notifier)
                  .toggleEnabled(!notificationSettings.isEnabled);
            },
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.network),
          const SizedBox(height: 8),

          // Base URL Configuration
          _SettingsTile(
            icon: Icons.link_rounded,
            iconColor: Colors.blue,
            title: l10n.backendUrl,
            subtitle: ref.watch(baseUrlControllerProvider),
            onTap: () => _showBaseUrlDialog(context, ref),
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.about),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.version,
            subtitle: '1.0.0 (Build 1)',
            trailing: const SizedBox.shrink(),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showBaseUrlDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const BackendUrlSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? theme.cardColor
                : AppColors.grey100.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDarkMode
                  ? theme.dividerColor.withValues(alpha: 0.1)
                  : AppColors.grey200.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.primaryColor).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      iconColor ??
                      (context.isDarkMode ? Colors.white : theme.primaryColor),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? const SizedBox.shrink(),
              if (trailing == null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.isDarkMode
                      ? AppColors.grey700
                      : theme.dividerColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
