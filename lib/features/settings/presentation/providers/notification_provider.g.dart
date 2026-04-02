// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationController)
final notificationControllerProvider = NotificationControllerProvider._();

final class NotificationControllerProvider
    extends $NotifierProvider<NotificationController, NotificationSettings> {
  NotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationControllerHash();

  @$internal
  @override
  NotificationController create() => NotificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettings>(value),
    );
  }
}

String _$notificationControllerHash() =>
    r'a2170d91649dec5772050ec02f4a1dcc41adf4f5';

abstract class _$NotificationController
    extends $Notifier<NotificationSettings> {
  NotificationSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NotificationSettings, NotificationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationSettings, NotificationSettings>,
              NotificationSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
