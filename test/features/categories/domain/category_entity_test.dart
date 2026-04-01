import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/features/categories/domain/category_entity.dart';

void main() {
  group('CategoryEntity', () {
    group('Construction and Basic Properties', () {
      test('creates category with all required fields', () {
        const category = CategoryEntity(
          id: 'food',
          name: 'Food & Dining',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category.id, 'food');
        expect(category.name, 'Food & Dining');
        expect(category.icon, 'restaurant');
        expect(category.color, 0xFFFF5722);
      });

      test('creates category with optional editedLocally flag', () {
        const category = CategoryEntity(
          id: 'travel',
          name: 'Travel',
          icon: 'flight',
          color: 0xFF2196F3,
          editedLocally: true,
        );

        expect(category.editedLocally, true);
      });

      test('editedLocally defaults to false', () {
        const category = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category.editedLocally, false);
      });
    });

    group('JSON Serialization', () {
      test('toJson creates correct json map', () {
        final updatedAt = DateTime(2026, 2, 9, 10, 30);
        final category = CategoryEntity(
          id: 'food',
          name: 'Food & Dining',
          icon: 'restaurant',
          color: 0xFFFF5722,
          updatedAt: updatedAt,
        );

        final json = category.toJson();

        expect(json['id'], 'food');
        expect(json['name'], 'Food & Dining');
        expect(json['icon'], 'restaurant');
        expect(json['color'], 0xFFFF5722);
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('fromJson creates valid category entity', () {
        final json = {
          'id': 'travel',
          'name': 'Travel & Transport',
          'icon': 'flight',
          'color': 0xFF2196F3,
          'updatedAt': '2026-02-09T10:30:00.000Z',
        };

        final category = CategoryEntity.fromJson(json);

        expect(category.id, 'travel');
        expect(category.name, 'Travel & Transport');
        expect(category.icon, 'flight');
        expect(category.color, 0xFF2196F3);
        expect(category.updatedAt, isNotNull);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'food',
          'name': 'Food',
          'icon': 'restaurant',
          'color': 0xFFFF5722,
        };

        final category = CategoryEntity.fromJson(json);

        expect(category.id, 'food');
        expect(category.updatedAt, null);
      });
    });

    group('Equality and HashCode', () {
      test('categories with same id are equal', () {
        const category1 = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        const category2 = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category1, equals(category2));
        expect(category1.hashCode, equals(category2.hashCode));
      });

      test('categories with different ids are not equal', () {
        const category1 = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        const category2 = CategoryEntity(
          id: 'travel',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category1, isNot(equals(category2)));
      });
    });

    group('Immutability', () {
      test('copyWith creates new instance with modified fields', () {
        const original = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        final modified = original.copyWith(
          name: 'Food & Dining',
          editedLocally: true,
        );

        expect(original.name, 'Food');
        expect(original.editedLocally, false);
        expect(modified.name, 'Food & Dining');
        expect(modified.editedLocally, true);
        expect(modified.id, 'food');
      });

      test('copyWith preserves unchanged fields', () {
        const original = CategoryEntity(
          id: 'travel',
          name: 'Travel',
          icon: 'flight',
          color: 0xFF2196F3,
        );

        final modified = original.copyWith(color: 0xFFFF0000);

        expect(modified.id, 'travel');
        expect(modified.name, 'Travel');
        expect(modified.icon, 'flight');
        expect(modified.color, 0xFFFF0000);
      });
    });

    group('Edge Cases', () {
      test('handles special characters in name', () {
        const category = CategoryEntity(
          id: 'special',
          name: 'Food & Dining / Restaurants',
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category.name, 'Food & Dining / Restaurants');
      });

      test('handles unicode characters in name', () {
        const category = CategoryEntity(
          id: 'tamil',
          name: 'உணவு மற்றும் உணவருந்துதல்', // Tamil
          icon: 'restaurant',
          color: 0xFFFF5722,
        );

        expect(category.name, 'உணவு மற்றும் உணவருந்துதல்');
      });

      test('handles various color values', () {
        const transparentCategory = CategoryEntity(
          id: 'c1',
          name: 'Transparent',
          icon: 'circle',
          color: 0x00000000, // Fully transparent
        );

        const opaqueCategory = CategoryEntity(
          id: 'c2',
          name: 'Opaque',
          icon: 'circle',
          color: 0xFFFFFFFF, // Fully opaque white
        );

        expect(transparentCategory.color, 0x00000000);
        expect(opaqueCategory.color, 0xFFFFFFFF);
      });

      test('handles long category names', () {
        const category = CategoryEntity(
          id: 'long',
          name:
              'This is a very long category name that might cause issues in UI rendering if not handled properly',
          icon: 'label',
          color: 0xFF9C27B0,
        );

        expect(category.name.length, greaterThan(50));
      });
    });

    group('Timestamp Handling', () {
      test('preserves updatedAt timestamp', () {
        final timestamp = DateTime(2026, 2, 9, 10, 30);
        final category = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
          updatedAt: timestamp,
        );

        expect(category.updatedAt, equals(timestamp));
      });

      test('copyWith can update updatedAt', () {
        final original = CategoryEntity(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 0xFFFF5722,
          updatedAt: DateTime(2026, 2),
        );

        final newTimestamp = DateTime(2026, 2, 9);
        final updated = original.copyWith(updatedAt: newTimestamp);

        expect(updated.updatedAt, equals(newTimestamp));
        expect(original.updatedAt, isNot(equals(newTimestamp)));
      });
    });
  });
}
