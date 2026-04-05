import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinCodeField extends StatelessWidget {
  const PinCodeField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.length = 4,
    this.errorText,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.obscureText = false,
    this.obscuringCharacter = '●',
  });

  final TextEditingController controller;
  final bool enabled;
  final int length;
  final String? errorText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool obscureText;
  final String obscuringCharacter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color:
            theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pinput(
          controller: controller,
          length: length,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          obscureText: obscureText,
          obscuringCharacter: obscuringCharacter,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          errorPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: theme.colorScheme.error, width: 2),
            ),
          ),
          forceErrorState: hasError,
          cursor: Container(
            width: 2,
            height: 24,
            color: theme.colorScheme.primary,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
