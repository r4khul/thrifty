import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/features/transactions/domain/transaction_entity.dart';
import 'package:thrifty/features/transactions/domain/transaction_summary_calculator.dart';

void main() {
  group('TransactionSummaryCalculator', () {
    const calculator = TransactionSummaryCalculator();

    test(
      'calculateMonthlySummary should return correct summary for mixed transactions',
      () {
        // Setup
        final now = DateTime(2023, 10, 15);
        final transactions = [
          TransactionEntity(
            id: '1',
            amount: 100,
            categoryId: 'cat1',
            timestamp: now,
          ),
          TransactionEntity(
            id: '2',
            amount: -50,
            categoryId: 'cat2',
            timestamp: now,
          ),
          TransactionEntity(
            id: '3',
            amount: -20,
            categoryId: 'cat2',
            timestamp: now,
          ),
          TransactionEntity(
            id: '4',
            amount: 0,
            categoryId: 'cat3',
            timestamp: now,
          ), // Neutral
          TransactionEntity(
            id: '5',
            amount: 200,
            categoryId: 'cat1',
            timestamp: DateTime(2023, 11),
          ), // Different month
        ];

        // Execute
        final summary = calculator.calculateMonthlySummary(
          transactions: transactions,
          year: 2023,
          month: 10,
        );

        // Verify
        expect(summary.totalIncome, 100);
        expect(summary.totalExpense, 70); // 50 + 20
        expect(summary.net, 30); // 100 - 70
        expect(summary.categoryBreakdown, {'cat2': 70});
      },
    );

    test(
      'calculateMonthlySummary should result in zero values for empty list',
      () {
        final summary = calculator.calculateMonthlySummary(
          transactions: [],
          year: 2023,
          month: 10,
        );

        expect(summary.totalIncome, 0);
        expect(summary.totalExpense, 0);
        expect(summary.net, 0);
        expect(summary.categoryBreakdown, isEmpty);
      },
    );

    test(
      'calculateMonthlySummary should handle transactions with only income',
      () {
        final now = DateTime(2023, 10, 15);
        final transactions = [
          TransactionEntity(
            id: '1',
            amount: 100,
            categoryId: 'cat1',
            timestamp: now,
          ),
        ];

        // Execute
        final summary = calculator.calculateMonthlySummary(
          transactions: transactions,
          year: 2023,
          month: 10,
        );

        // Verify
        expect(summary.totalIncome, 100);
        expect(summary.totalExpense, 0);
        expect(summary.net, 100);
        expect(summary.categoryBreakdown, isEmpty);
      },
    );

    test(
      'calculateMonthlySummary should handle transactions with only expense',
      () {
        final now = DateTime(2023, 10, 15);
        final transactions = [
          TransactionEntity(
            id: '1',
            amount: -50,
            categoryId: 'cat1',
            timestamp: now,
          ),
        ];

        // Execute
        final summary = calculator.calculateMonthlySummary(
          transactions: transactions,
          year: 2023,
          month: 10,
        );

        // Verify
        expect(summary.totalIncome, 0);
        expect(summary.totalExpense, 50);
        expect(summary.net, -50);
        expect(summary.categoryBreakdown, {'cat1': 50});
      },
    );

    test(
      'calculateMonthlySummary should ignore transactions outside the target month/year',
      () {
        final transactions = [
          TransactionEntity(
            id: '1',
            amount: 100,
            categoryId: 'cat1',
            timestamp: DateTime(2023, 9, 30),
          ),
          TransactionEntity(
            id: '2',
            amount: 100,
            categoryId: 'cat1',
            timestamp: DateTime(2023, 10),
          ),
          TransactionEntity(
            id: '3',
            amount: 100,
            categoryId: 'cat1',
            timestamp: DateTime(2023, 11),
          ),
          TransactionEntity(
            id: '4',
            amount: 100,
            categoryId: 'cat1',
            timestamp: DateTime(2022, 10),
          ),
        ];

        final summary = calculator.calculateMonthlySummary(
          transactions: transactions,
          year: 2023,
          month: 10,
        );

        expect(summary.totalIncome, 100); // Only one transaction matches
        expect(summary.net, 100);
      },
    );
  });
}
