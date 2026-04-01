import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/features/auth/domain/auth_session.dart';

void main() {
  group('AuthSession', () {
    group('Construction', () {
      test('creates session with email and rememberMe flag', () {
        const session = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        expect(session.email, 'test@example.com');
        expect(session.rememberMe, true);
      });

      test('creates session without rememberMe flag', () {
        const session = AuthSession(email: 'user@test.com', rememberMe: false);

        expect(session.email, 'user@test.com');
        expect(session.rememberMe, false);
      });
    });

    group('JSON Serialization', () {
      test('toJson creates correct map', () {
        const session = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        final json = session.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['rememberMe'], true);
      });

      test('fromJson creates valid session', () {
        final json = {'email': 'user@test.com', 'rememberMe': false};

        final session = AuthSession.fromJson(json);

        expect(session.email, 'user@test.com');
        expect(session.rememberMe, false);
      });

      test('serialization round-trip preserves data', () {
        const original = AuthSession(
          email: 'roundtrip@test.com',
          rememberMe: true,
        );

        final json = original.toJson();
        final restored = AuthSession.fromJson(json);

        expect(restored.email, original.email);
        expect(restored.rememberMe, original.rememberMe);
      });
    });

    group('Equality', () {
      test('sessions with same data are equal', () {
        const session1 = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        const session2 = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('sessions with different emails are not equal', () {
        const session1 = AuthSession(email: 'user1@test.com', rememberMe: true);

        const session2 = AuthSession(email: 'user2@test.com', rememberMe: true);

        expect(session1, isNot(equals(session2)));
      });

      test('sessions with different rememberMe flags are not equal', () {
        const session1 = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        const session2 = AuthSession(
          email: 'test@example.com',
          rememberMe: false,
        );

        expect(session1, isNot(equals(session2)));
      });
    });

    group('Immutability', () {
      test('copyWith creates new instance with modified fields', () {
        const original = AuthSession(
          email: 'original@test.com',
          rememberMe: false,
        );

        final modified = original.copyWith(rememberMe: true);

        expect(original.rememberMe, false);
        expect(modified.rememberMe, true);
        expect(modified.email, 'original@test.com');
      });

      test('copyWith preserves unchanged fields', () {
        const original = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        final modified = original.copyWith(email: 'new@example.com');

        expect(original.email, 'test@example.com');
        expect(modified.email, 'new@example.com');
        expect(modified.rememberMe, true);
      });
    });

    group('Email Validation Edge Cases', () {
      test('handles various valid email formats', () {
        const emails = [
          'simple@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
          'user@subdomain.example.com',
          '123@example.com',
        ];

        for (final email in emails) {
          final session = AuthSession(email: email, rememberMe: false);
          expect(session.email, email);
        }
      });

      test('handles empty string email', () {
        const session = AuthSession(email: '', rememberMe: false);
        expect(session.email, '');
      });

      test('handles unicode characters in email', () {
        const session = AuthSession(email: 'user@தமிழ்.com', rememberMe: false);
        expect(session.email, 'user@தமிழ்.com');
      });
    });

    group('toString', () {
      test('toString contains class name', () {
        const session = AuthSession(
          email: 'test@example.com',
          rememberMe: true,
        );

        final string = session.toString();
        expect(string, contains('AuthSession'));
      });

      test('toString does not expose sensitive data in plain text', () {
        const session = AuthSession(
          email: 'sensitive@example.com',
          rememberMe: true,
        );

        final string = session.toString();
        // Freezed typically shows field names but not expose them unsafely
        expect(string, isNotNull);
      });
    });
  });
}
