import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/error/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

/// Auth Feature Data: Implementation of AuthRepository.
/// Uses [FlutterSecureStorage] for persistency.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _pinKey = 'auth_pin';
  static const _biometricEnabledKey = 'auth_biometric_enabled';
  static const _onboardingDoneKey = 'onboarding_done';

  AuthSession? _session;

  @override
  Future<AuthSession?> getSession() async {
    return _session;
  }

  @override
  Future<AuthSession> unlockWithPin({required String pin}) async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      if (storedPin == null) {
        throw const AuthFailure('Security PIN is not configured yet.');
      }
      if (storedPin != pin) {
        throw const AuthFailure('Incorrect PIN.');
      }

      final session = _createSession();
      _session = session;
      return session;
    } on AuthFailure {
      rethrow;
    } on Object catch (e) {
      throw AuthFailure('Authentication error: ${e.toString()}');
    }
  }

  @override
  Future<void> setupSecurity({
    required String pin,
    required bool enableBiometric,
  }) async {
    if (pin.length != 4 || int.tryParse(pin) == null) {
      throw const AuthFailure('PIN must be exactly 4 digits.');
    }

    try {
      await _storage.write(key: _pinKey, value: pin);
      await _storage.write(
        key: _biometricEnabledKey,
        value: jsonEncode(enableBiometric),
      );
      await _storage.write(key: _onboardingDoneKey, value: jsonEncode(true));
    } on Object catch (_) {
      throw const AuthFailure('Failed to save security setup.');
    }
  }

  @override
  Future<AuthSession> unlockWithBiometric() async {
    final hasSetup = !(await isNewUser());
    if (!hasSetup) {
      throw const AuthFailure('Security is not configured yet.');
    }

    final session = _createSession();
    _session = session;
    return session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<bool> isNewUser() async {
    try {
      final onboardingDone = await _storage.read(key: _onboardingDoneKey);
      final pin = await _storage.read(key: _pinKey);
      if (onboardingDone == null || pin == null) return true;

      return jsonDecode(onboardingDone) != true;
    } on Object catch (_) {
      return true;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      if (value == null) return false;
      return jsonDecode(value) == true;
    } on Object catch (_) {
      return false;
    }
  }

  AuthSession _createSession() {
    return const AuthSession(email: 'local_user', rememberMe: false);
  }
}
