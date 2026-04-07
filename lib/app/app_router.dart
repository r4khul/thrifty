import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/accounts/presentation/accounts_page.dart';
import '../features/accounts/presentation/add_edit_account_page.dart';
import '../features/analytics/presentation/financial_overview_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/presentation/onboarding_setup_page.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/profile/presentation/profile_edit_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/transactions/presentation/add_edit_transaction_page.dart';
import '../features/transactions/presentation/transaction_details_page.dart';
import '../features/transactions/presentation/transaction_templates_page.dart';
import '../features/transactions/presentation/transactions_page.dart';

part 'app_router.g.dart';

/// App Router Provider: Integrated with Authentication State.
/// Responsibility:
/// - Rebuilds the router whenever the [authControllerProvider] state evolves.
/// - Handles deterministic redirection (Guard) for protected routes.
/// - Preserves deep-link intentions during authentication transitions.
@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  final isNewUserAsync = ref.watch(isNewUserProvider);

  return GoRouter(
    initialLocation: '/',
    // Refresh the router when auth or new user status changes
    refreshListenable: Listenable.merge([
      authState.asData != null
          ? ValueNotifier(authState.value)
          : ValueNotifier(0),
    ]),
    redirect: (context, state) {
      if (authState.isLoading || isNewUserAsync.isLoading) {
        return state.matchedLocation == '/' ? null : '/';
      }

      final session = authState.value;
      final location = state.matchedLocation;
      final isLoggingIn = location == '/login';
      final isOnboarding =
          location == '/onboarding' || location == '/onboarding/setup';
      final isNewUser = isNewUserAsync.value ?? true;

      // 1. New user must complete onboarding and setup.
      if (isNewUser) {
        if (location == '/') return '/onboarding';
        if (!isOnboarding) return '/onboarding';
        return null;
      }

      // 2. Returning users must unlock before entering app routes.
      if (session == null) {
        if (!isLoggingIn) return '/login';
        return null;
      }

      // 3. Authenticated redirection.
      if (isLoggingIn) {
        return '/home';
      }

      if (isOnboarding) {
        return '/home';
      }

      // 4. Exit splash after state resolves.
      if (location == '/') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const FinancialOverviewPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/onboarding/setup',
        builder: (context, state) => const OnboardingSetupPage(),
      ),
      GoRoute(
        path: '/add-tx',
        builder: (context, state) => const AddEditTransactionPage(),
      ),
      GoRoute(
        path: '/edit-tx/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditTransactionPage(transactionId: id);
        },
      ),
      GoRoute(
        path: '/tx/:id',
        builder: (context, state) =>
            TransactionDetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsPage(),
      ),
      GoRoute(
        path: '/add-account',
        builder: (context, state) => const AddEditAccountPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TransactionTemplatesPage(),
      ),
    ],
  );
}
