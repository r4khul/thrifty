import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/auth_repository_provider.dart';
import '../../domain/auth_session.dart';

part 'auth_providers.g.dart';

/// Application State: Manages the global authentication session.
/// Responsibility: Exposes the current session and handles session transitions.
/// Lifecycle: App-wide (keepAlive: true).
@Riverpod(keepAlive: true)
Future<bool> isNewUser(Ref ref) {
  return ref.watch(authRepositoryProvider).isNewUser();
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthSession?> build() async {
    // Startup in locked state by default; unlock is runtime only.
    final repository = ref.watch(authRepositoryProvider);
    return repository.getSession();
  }

  /// Retries loading the session if it failed.
  void retry() {
    ref.invalidateSelf();
  }

  /// Transitions the app to an unauthenticated state.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).clearSession();
      return null;
    });
  }

  /// Unlocks the app with the configured PIN.
  Future<void> unlockWithPin({required String pin}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .unlockWithPin(pin: pin);
      return session;
    });
  }

  /// Completes first-time setup and unlocks the app.
  Future<void> completeOnboarding({
    required String pin,
    required bool enableBiometric,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.setupSecurity(
        pin: pin,
        enableBiometric: enableBiometric,
      );
      ref.invalidate(isNewUserProvider);
      return repository.unlockWithPin(pin: pin);
    });
  }

  /// Unlocks with biometric verification that already happened in UI layer.
  Future<void> unlockWithBiometric() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .unlockWithBiometric();
      return session;
    });
  }

  Future<bool> isBiometricEnabled() {
    return ref.read(authRepositoryProvider).isBiometricEnabled();
  }
}
