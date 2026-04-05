import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/presentation/providers/user_profile_provider.dart';
import 'providers/auth_providers.dart';
import 'widgets/pin_code_field.dart';

class OnboardingSetupPage extends ConsumerStatefulWidget {
  const OnboardingSetupPage({super.key});

  @override
  ConsumerState<OnboardingSetupPage> createState() =>
      _OnboardingSetupPageState();
}

class _OnboardingSetupPageState extends ConsumerState<OnboardingSetupPage> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _localAuth = LocalAuthentication();

  bool _biometricSupported = false;
  bool _enableBiometric = false;
  String? _pinError;
  String? _confirmPinError;

  @override
  void initState() {
    super.initState();
    _detectBiometric();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _detectBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();

      if (!mounted) return;
      setState(() {
        _biometricSupported = canCheck && supported;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _biometricSupported = false;
      });
    }
  }

  Future<void> _submit() async {
    final isNameValid = _formKey.currentState?.validate() ?? false;
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    var hasPinError = false;
    setState(() {
      _pinError = null;
      _confirmPinError = null;

      if (pin.isEmpty) {
        _pinError = 'PIN is required';
        hasPinError = true;
      } else if (pin.length != 4) {
        _pinError = 'PIN must be exactly 4 digits';
        hasPinError = true;
      }

      if (confirmPin.isEmpty) {
        _confirmPinError = 'Please confirm your PIN';
        hasPinError = true;
      } else if (confirmPin != pin) {
        _confirmPinError = 'PINs do not match';
        hasPinError = true;
      }
    });

    if (!isNameValid || hasPinError) {
      return;
    }

    final name = _nameController.text.trim();

    await ref
        .read(userProfileControllerProvider.notifier)
        .updateProfile(name: name);

    await ref
        .read(authControllerProvider.notifier)
        .completeOnboarding(pin: pin, enableBiometric: _enableBiometric);

    if (!mounted) return;
    context.go('/add-account');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup your account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about you',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your name appears in greetings and profile sections.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your name',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Create PIN',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                PinCodeField(
                  controller: _pinController,
                  enabled: !isLoading,
                  hintText: '4-digit PIN',
                  errorText: _pinError,
                  obscureText: true,
                  onChanged: (_) {
                    if (_pinError != null) {
                      setState(() => _pinError = null);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm PIN',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                PinCodeField(
                  controller: _confirmPinController,
                  enabled: !isLoading,
                  hintText: 'Re-enter PIN',
                  errorText: _confirmPinError,
                  obscureText: true,
                  onChanged: (_) {
                    if (_confirmPinError != null) {
                      setState(() => _confirmPinError = null);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Use a memorable 4-digit PIN for quick unlock.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                if (_biometricSupported)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _enableBiometric,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() => _enableBiometric = value);
                          },
                    title: const Text('Enable fingerprint unlock'),
                    subtitle: const Text(
                      'Use biometric unlock for faster access.',
                    ),
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    activeThumbColor: AppColors.primary,
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Finish setup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
