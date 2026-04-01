import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thrifty/core/providers/locale_provider.dart';
import 'package:thrifty/core/util/notification_service.dart';
import 'package:thrifty/features/settings/data/notification_repository.dart';
import 'package:thrifty/features/settings/domain/notification_settings.dart';
import 'package:thrifty/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  @override
  NotificationSettings build() {
    final repository = ref.watch(notificationRepositoryProvider);
    final settings = repository.getSettings();

    // Listen to transaction changes to update schedule
    ref.listen(transactionControllerProvider, (previous, next) {
      _updateSchedule();
    }, fireImmediately: true);

    // Listen to locale changes to update notification language
    ref.listen(localeControllerProvider, (previous, next) {
      if (previous != next) {
        _updateSchedule();
      }
    });

    return settings;
  }

  Future<void> _updateSchedule() async {
    final settings = state;
    final service = NotificationService();

    if (!settings.isEnabled) {
      await service.cancelAll();
      return;
    }

    // Get all dates that have transactions logged to skip reminders for those days
    final transactionsAsync = ref.read(transactionControllerProvider);

    // Don't schedule if transactions are still loading initially
    if (transactionsAsync.isLoading && !transactionsAsync.hasValue) {
      debugPrint(
        'NotificationController: Transactions still loading, skipping schedule update',
      );
      return;
    }
    final datesToSkip = <DateTime>{};

    if (transactionsAsync.hasValue) {
      final txs = transactionsAsync.value!;
      debugPrint(
        'NotificationController: Found ${txs.length} transactions, checking for dates to skip',
      );
      for (final tx in txs) {
        // Normalize to date only for comparison
        final date = DateTime(
          tx.timestamp.year,
          tx.timestamp.month,
          tx.timestamp.day,
        );
        datesToSkip.add(date);
      }
    }

    debugPrint(
      'NotificationController: Scheduling reminders, skipping ${datesToSkip.length} dates',
    );

    // Get the localized strings
    final locale = ref.read(localeControllerProvider);
    final l10n = await AppLocalizations.delegate.load(locale);

    // Schedule the notifications for the next 14 days
    // Individual days will be skipped if they are in datesToSkip
    await service.scheduleDailyReminder(
      time: settings.reminderTime,
      datesToSkip: datesToSkip,
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      isDebug: kDebugMode,
    );
  }

  Future<void> toggleEnabled(bool value) async {
    state = state.copyWith(isEnabled: value);
    await ref.read(notificationRepositoryProvider).saveSettings(state);
    await _updateSchedule(); // Update schedule immediately on toggle
  }

  Future<void> updateTime(TimeOfDay time) async {
    state = state.copyWith(reminderTimeStr: '${time.hour}:${time.minute}');
    await ref.read(notificationRepositoryProvider).saveSettings(state);
    await _updateSchedule(); // Update schedule immediately on time change
  }
}
