// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App Router Provider: Integrated with Authentication State.
/// Responsibility:
/// - Rebuilds the router whenever the [authControllerProvider] state evolves.
/// - Handles deterministic redirection (Guard) for protected routes.
/// - Preserves deep-link intentions during authentication transitions.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// App Router Provider: Integrated with Authentication State.
/// Responsibility:
/// - Rebuilds the router whenever the [authControllerProvider] state evolves.
/// - Handles deterministic redirection (Guard) for protected routes.
/// - Preserves deep-link intentions during authentication transitions.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// App Router Provider: Integrated with Authentication State.
  /// Responsibility:
  /// - Rebuilds the router whenever the [authControllerProvider] state evolves.
  /// - Handles deterministic redirection (Guard) for protected routes.
  /// - Preserves deep-link intentions during authentication transitions.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'83836b6931295e0a709590fa3b1ccba4c65c30b1';
