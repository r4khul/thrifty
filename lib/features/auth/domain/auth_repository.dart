import 'auth_session.dart';

/// Auth Feature Domain: Interface for authentication operations.
/// Boundary Rules: Pure Dart only.
abstract class AuthRepository {
  /// Retrieves the current active in-memory session, if any.
  Future<AuthSession?> getSession();

  /// Unlocks the app using the configured [pin].
  Future<AuthSession> unlockWithPin({required String pin});

  /// Creates security setup for first-time user.
  Future<void> setupSecurity({
    required String pin,
    required bool enableBiometric,
  });

  /// Creates an unlocked session after successful biometric verification.
  Future<AuthSession> unlockWithBiometric();

  /// Removes the current active in-memory session.
  Future<void> clearSession();

  /// Checks if the app is being run for the first time.
  Future<bool> isNewUser();

  /// Returns whether biometric unlock is enabled.
  Future<bool> isBiometricEnabled();
}
