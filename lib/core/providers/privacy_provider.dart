import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for privacy mode across the application.
class PrivacyModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final privacyModeProvider = NotifierProvider<PrivacyModeNotifier, bool>(
  PrivacyModeNotifier.new,
);
