import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/core/util/formatting_utils.dart';

void main() {
  group('FormattingUtils', () {
    group('formatCompact', () {
      test('formats numbers less than 1000 without suffix', () {
        expect(FormattingUtils.formatCompact(0), '0');
        expect(FormattingUtils.formatCompact(1), '1');
        expect(FormattingUtils.formatCompact(50.5), '50.5');
        expect(FormattingUtils.formatCompact(999), '999');
      });

      test('formats thousands with K suffix', () {
        expect(FormattingUtils.formatCompact(1000), '1K');
        expect(FormattingUtils.formatCompact(1500), '1.5K');
        expect(FormattingUtils.formatCompact(10000), '10K');
        expect(FormattingUtils.formatCompact(99500), '99.5K');
      });

      test('formats millions with M suffix', () {
        expect(FormattingUtils.formatCompact(1000000), '1M');
        expect(FormattingUtils.formatCompact(1500000), '1.5M');
        expect(FormattingUtils.formatCompact(10000000), '10M');
      });

      test('formats billions with B suffix or T suffix', () {
        expect(FormattingUtils.formatCompact(1000000000), '1B');
        expect(FormattingUtils.formatCompact(1500000000), '1.5B');
      });

      test('handles negative numbers correctly', () {
        expect(FormattingUtils.formatCompact(-500), '500');
        expect(FormattingUtils.formatCompact(-1500), '1.5K');
        expect(FormattingUtils.formatCompact(-1500000), '1.5M');
      });

      test('removes trailing zeros for small numbers', () {
        expect(FormattingUtils.formatCompact(100.00), '100');
        expect(FormattingUtils.formatCompact(50.10), '50.1');
        expect(FormattingUtils.formatCompact(75.99), '75.99');
      });
    });

    group('Edge Cases', () {
      test('handles zero correctly', () {
        expect(FormattingUtils.formatCompact(0.0), '0');
        expect(FormattingUtils.formatCompact(-0.0), '0');
      });

      test('handles very small decimals', () {
        expect(FormattingUtils.formatCompact(0.1), '0.1');
        expect(FormattingUtils.formatCompact(0.99), '0.99');
      });
    });

    group('Real World Scenarios', () {
      test('formats common transaction amounts', () {
        expect(FormattingUtils.formatCompact(50.0), '50');
        expect(FormattingUtils.formatCompact(250.99), '250.99');
        expect(FormattingUtils.formatCompact(1500.0), '1.5K');
        expect(FormattingUtils.formatCompact(25000.0), '25K');
      });

      test('formats salary amounts', () {
        final result1 = FormattingUtils.formatCompact(50000);
        final result2 = FormattingUtils.formatCompact(75000);
        final result3 = FormattingUtils.formatCompact(100000);
        final result4 = FormattingUtils.formatCompact(1000000);

        expect(result1, contains('K'));
        expect(result2, contains('K'));
        expect(result3, contains('K'));
        expect(result4, contains('M'));
      });

      test('formats large business transactions', () {
        final result1 = FormattingUtils.formatCompact(5000000);
        final result2 = FormattingUtils.formatCompact(25000000);
        final result3 = FormattingUtils.formatCompact(100000000);
        final result4 = FormattingUtils.formatCompact(1000000000);

        expect(result1, contains('M'));
        expect(result2, contains('M'));
        expect(result3, contains('M'));
        expect(result4, anyOf(contains('B'), contains('G')));
      });
    });

    group('formatFullCurrency', () {
      test('formats currency with default dollar symbol', () {
        expect(FormattingUtils.formatFullCurrency(100.50), '\$100.50');
        expect(FormattingUtils.formatFullCurrency(1234.56), '\$1,234.56');
      });

      test('formats currency with custom symbol', () {
        expect(
          FormattingUtils.formatFullCurrency(100.50, symbol: '₹'),
          '₹100.50',
        );
      });

      test('formats zero correctly', () {
        expect(FormattingUtils.formatFullCurrency(0), '\$0.00');
      });

      test('formats negative amounts correctly', () {
        expect(FormattingUtils.formatFullCurrency(-50.25), '-\$50.25');
      });

      test('always shows two decimal places', () {
        expect(FormattingUtils.formatFullCurrency(100), '\$100.00');
        expect(FormattingUtils.formatFullCurrency(100.5), '\$100.50');
      });
    });
  });
}
