import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_filter_provider.freezed.dart';
part 'date_filter_provider.g.dart';

@freezed
abstract class DateRangeFilter with _$DateRangeFilter {
  const factory DateRangeFilter({
    required DateTime start,
    required DateTime end,
    required String label,
    @Default(false) bool isCustom,
  }) = _DateRangeFilter;
}

@riverpod
class DateFilterController extends _$DateFilterController {
  @override
  DateRangeFilter build() {
    return _today();
  }

  DateRangeFilter _allTime() {
    return DateRangeFilter(
      start: DateTime(2000),
      end: DateTime(2100),
      label: 'All Time',
    );
  }

  DateRangeFilter _today() {
    final now = DateTime.now();
    return DateRangeFilter(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'Today',
    );
  }

  void setAllTime() => state = _allTime();

  void setToday() => state = _today();

  void setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    state = DateRangeFilter(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'This Week',
    );
  }

  void setThisMonth() {
    final now = DateTime.now();
    state = DateRangeFilter(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'This Month',
    );
  }

  void setThisYear() {
    final now = DateTime.now();
    state = DateRangeFilter(
      start: DateTime(now.year),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'This Year',
    );
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = DateRangeFilter(
      start: DateTime(start.year, start.month, start.day),
      end: DateTime(end.year, end.month, end.day, 23, 59, 59),
      label: 'Custom',
      isCustom: true,
    );
  }

  void setSingleDate(DateTime date) {
    final df = DateFormat('d MMM');
    state = DateRangeFilter(
      start: DateTime(date.year, date.month, date.day),
      end: DateTime(date.year, date.month, date.day, 23, 59, 59),
      label: df.format(date),
      isCustom: true,
    );
  }
}
