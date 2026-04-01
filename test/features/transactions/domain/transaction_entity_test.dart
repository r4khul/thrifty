import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/features/transactions/domain/transaction_entity.dart';

void main() {
  group('TransactionEntity', () {
    group('Business Rules - Amount Sign', () {
      test('isIncome returns true for positive amounts', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction.isIncome, true);
        expect(transaction.isExpense, false);
      });

      test('isExpense returns true for negative amounts', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: -50.0,
          categoryId: 'food',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction.isExpense, true);
        expect(transaction.isIncome, false);
      });

      test(
        'neutral transaction (amount = 0) is neither income nor expense',
        () {
          final transaction = TransactionEntity(
            id: 'tx1',
            amount: 0.0,
            categoryId: 'adjustment',
            timestamp: DateTime(2026, 2, 9, 10),
          );

          expect(transaction.isIncome, false);
          expect(transaction.isExpense, false);
        },
      );
    });

    group('Computed Properties', () {
      test('absoluteAmount returns magnitude regardless of sign', () {
        final income = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        final expense = TransactionEntity(
          id: 'tx2',
          amount: -75.5,
          categoryId: 'food',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(income.absoluteAmount, 100.0);
        expect(expense.absoluteAmount, 75.5);
      });

      test('formattedAbsoluteAmount returns two decimal places', () {
        final transaction1 = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        final transaction2 = TransactionEntity(
          id: 'tx2',
          amount: -75.555,
          categoryId: 'food',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction1.formattedAbsoluteAmount, '100.00');
        expect(transaction2.formattedAbsoluteAmount, '75.56');
      });

      test('displaySign returns correct prefix', () {
        final income = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        final expense = TransactionEntity(
          id: 'tx2',
          amount: -50.0,
          categoryId: 'food',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(income.displaySign, '+');
        expect(expense.displaySign, '-');
      });

      test('compactAbsoluteAmount formats large numbers correctly', () {
        final transaction1 = TransactionEntity(
          id: 'tx1',
          amount: 1500.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        final transaction2 = TransactionEntity(
          id: 'tx2',
          amount: -1234567.0,
          categoryId: 'purchase',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction1.compactAbsoluteAmount, '1.5K');
        expect(transaction2.compactAbsoluteAmount, '1.2M');
      });

      test('displayDate returns correct format', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10, 30),
        );

        expect(transaction.displayDate, '9 Feb');
      });

      test('displayTime returns correct format', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 14, 30),
        );

        expect(transaction.displayTime, '14:30');
      });
    });

    group('JSON Serialization', () {
      test('fromJson creates valid entity', () {
        final json = {
          'id': 'tx1',
          'amount': 100.0,
          'category': 'salary',
          'ts': '2026-02-09T10:00:00.000Z',
          'note': 'Monthly salary',
        };

        final transaction = TransactionEntity.fromJson(json);

        expect(transaction.id, 'tx1');
        expect(transaction.amount, 100.0);
        expect(transaction.categoryId, 'salary');
        expect(transaction.note, 'Monthly salary');
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'tx1',
          'amount': -50.0,
          'category': 'food',
          'ts': '2026-02-09T10:00:00.000Z',
        };

        final transaction = TransactionEntity.fromJson(json);

        expect(transaction.id, 'tx1');
        expect(transaction.note, null);
      });

      test('toJson excludes internal fields', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
          note: 'Test note',
          editedLocally: true,
        );

        final json = transaction.toJson();

        expect(json.containsKey('editedLocally'), false);
        expect(json.containsKey('attachments'), false);
        expect(json['id'], 'tx1');
        expect(json['category'], 'salary');
        expect(json['amount'], 100.0);
      });
    });

    group('Immutability', () {
      test('copyWith creates new instance with modified fields', () {
        final original = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        final modified = original.copyWith(amount: 200.0, note: 'Updated');

        expect(original.amount, 100.0);
        expect(modified.amount, 200.0);
        expect(modified.note, 'Updated');
        expect(modified.id, 'tx1');
      });

      test('copyWith preserves unchanged fields', () {
        final original = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'salary',
          timestamp: DateTime(2026, 2, 9, 10),
          note: 'Original note',
        );

        final modified = original.copyWith(amount: 200.0);

        expect(modified.note, 'Original note');
        expect(modified.categoryId, 'salary');
      });
    });

    group('Edge Cases', () {
      test('handles very small decimal amounts', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 0.01,
          categoryId: 'adjustment',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction.isIncome, true);
        expect(transaction.absoluteAmount, 0.01);
        expect(transaction.formattedAbsoluteAmount, '0.01');
      });

      test('handles very large amounts', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 9999999.99,
          categoryId: 'lottery',
          timestamp: DateTime(2026, 2, 9, 10),
        );

        expect(transaction.isIncome, true);
        expect(transaction.absoluteAmount, 9999999.99);
      });

      test('handles unicode characters in notes', () {
        final transaction = TransactionEntity(
          id: 'tx1',
          amount: 100.0,
          categoryId: 'food',
          timestamp: DateTime(2026, 2, 9, 10),
          note: 'இட்லி வாங்கினேன்', // Tamil text
        );

        expect(transaction.note, 'இட்லி வாங்கினேன்');
      });
    });
  });
}
