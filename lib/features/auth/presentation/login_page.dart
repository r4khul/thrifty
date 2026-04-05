import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thrifty/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/presentation/providers/user_profile_provider.dart';
import 'providers/auth_providers.dart';
import 'widgets/pin_code_field.dart';

/// Local security unlock screen for returning users.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _pinController = TextEditingController();
  final _localAuth = LocalAuthentication();
  bool _checkingBiometric = true;
  bool _biometricAvailable = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricAvailability() async {
    final enabled = await ref
        .read(authControllerProvider.notifier)
        .isBiometricEnabled();
    var available = false;

    if (enabled) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final supported = await _localAuth.isDeviceSupported();
        available = canCheck && supported;
      } on Object {
        available = false;
      }
    }

    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _checkingBiometric = false;
      });
    }
  }

  Future<void> _handleUnlock() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _pinError = l10n.pinRequired);
      return;
    }
    if (pin.length != 4) {
      setState(() => _pinError = l10n.pinLengthError);
      return;
    }

    setState(() => _pinError = null);
    await ref.read(authControllerProvider.notifier).unlockWithPin(pin: pin);
  }

  Future<void> _unlockWithBiometric() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to unlock Thrifty',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: false,
        ),
      );

      if (didAuthenticate && mounted) {
        await ref.read(authControllerProvider.notifier).unlockWithBiometric();
      }
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProfile = ref.watch(userProfileControllerProvider).asData?.value;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final greetingName = userProfile?.name.trim().isNotEmpty == true
        ? userProfile!.name
        : 'there';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Image.asset('assets/icons/app_icon_without_bg.png'),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome back, $greetingName',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock your wallet with your PIN',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 40),
              Text(
                l10n.securityPIN,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              PinCodeField(
                controller: _pinController,
                enabled: !isLoading,
                hintText: l10n.pinHint,
                errorText: _pinError,
                autofocus: true,
                obscureText: true,
                onChanged: (_) {
                  if (_pinError != null) {
                    setState(() => _pinError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Enter 4 digits',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleUnlock,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Unlock'),
                ),
              ),
              const SizedBox(height: 12),
              if (!_checkingBiometric && _biometricAvailable)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _unlockWithBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Use fingerprint'),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
