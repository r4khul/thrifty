import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:thrifty/core/widgets/charts/chart_types.dart';
import 'package:thrifty/features/transactions/domain/transaction_entity.dart';
import 'package:thrifty/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@riverpod
Future<List<ChartPoint>> aggregatedChartData(
  Ref ref,
  ChartPeriod period,
) async {
  final transactionsAsync = ref.watch(transactionControllerProvider);

  return transactionsAsync.when(
    data: (List<TransactionEntity> transactions) async {
      if (transactions.isEmpty) return <ChartPoint>[];

      // Use compute to offload heavy aggregation to a background isolate
      return compute(_aggregateData, _AggregationParams(transactions, period));
    },
    loading: () => <ChartPoint>[],
    error: (e, s) => <ChartPoint>[],
  );
}

class _AggregationParams {
  _AggregationParams(this.transactions, this.period);

  final List<TransactionEntity> transactions;
  final ChartPeriod period;
}

List<ChartPoint> _aggregateData(_AggregationParams params) {
  final transactions = params.transactions;
  final period = params.period;

  final groupedIncome = <String, double>{};
  final groupedExpense = <String, double>{};
  final dates = <String, DateTime>{};

  for (var tx in transactions) {
    final dateKey = _getDateKey(tx.timestamp, period);
    if (!dates.containsKey(dateKey)) {
      dates[dateKey] = _normalizeDate(tx.timestamp, period);
    }

    if (tx.isIncome) {
      groupedIncome[dateKey] = (groupedIncome[dateKey] ?? 0) + tx.amount;
    } else {
      groupedExpense[dateKey] = (groupedExpense[dateKey] ?? 0) + tx.amount;
    }
  }

  final allKeys = {...groupedIncome.keys, ...groupedExpense.keys}.toList()
    ..sort((a, b) => dates[a]!.compareTo(dates[b]!));

  final result = <ChartPoint>[];
  for (var key in allKeys) {
    final date = dates[key]!;
    final inc = groupedIncome[key] ?? 0;
    final exp = groupedExpense[key] ?? 0;

    result.add(ChartPoint(date: date, income: inc, expense: exp));
  }
  return result;
}

DateTime _normalizeDate(DateTime date, ChartPeriod period) {
  switch (period) {
    case ChartPeriod.daily:
      return DateTime(date.year, date.month, date.day);
    case ChartPeriod.weekly:
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    case ChartPeriod.monthly:
      return DateTime(date.year, date.month);
    case ChartPeriod.yearly:
      return DateTime(date.year);
  }
}

String _getDateKey(DateTime date, ChartPeriod period) {
  switch (period) {
    case ChartPeriod.daily:
      return '${date.year}-${date.month}-${date.day}';
    case ChartPeriod.weekly:
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      return '${startOfWeek.year}-W${_weekNumber(startOfWeek)}';
    case ChartPeriod.monthly:
      return '${date.year}-${date.month}';
    case ChartPeriod.yearly:
      return '${date.year}';
  }
}

int _weekNumber(DateTime date) {
  final dayOfYear = int.parse(DateFormat('D').format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}
