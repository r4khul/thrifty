# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0+3] - 2026-06-19

### Fixed
- Release APK builds no longer fail with "non-constant invocations of IconData" error.
  Account icons were constructed at runtime via `IconData(codePoint, fontFamily: 'MaterialIcons')`,
  which prevented Flutter's icon font tree-shaker from analyzing the build. All five call-sites
  (add/edit transaction page, transaction template page, and transactions list page) now route
  through the new `AccountAssets.getIcon()` lookup, which references only static `Icons.*` constants.

### Added
- `AccountAssets` utility class (`lib/features/accounts/presentation/account_assets.dart`) —
  a curated map of account-related `IconData` constants (wallet, bank, savings, credit card,
  payments, trending up, etc.) with a safe fallback to `Icons.account_balance_wallet_rounded`
  for any unrecognised codepoint stored in the database.

---

## [1.1.0+2] - 2026-05-01

### Added
- **Accounts management** — create, edit, and delete financial accounts (savings, checking, cash,
  investment, credit card) each with a custom colour and balance tracking.
- **Transaction templates** — save commonly-used transactions as templates and replay them with
  one tap to speed up daily logging.
- **File attachments** — attach receipt images or documents directly to a transaction.
- **Tamil localisation** — full UI translation for Tamil (`ta`) alongside the existing English.
- **Currency selector** — choose a preferred display currency in Settings.
- **Privacy mode** — toggle to hide all monetary values on-screen.

### Changed
- Analytics page now breaks down spending by account in addition to category.
- Background sync now pushes accounts alongside transactions and categories.

### Fixed
- Daily notification reminder time was not persisted across app restarts.
- Negative balance was displayed without the minus sign on some locales.

---

## [1.0.0] - 2026-03-15

### Added
- **Offline-first transaction tracking** using a local SQLite database (Drift ORM) with full
  CRUD support.
- **Category management** — create and customise categories with icons and colours.
- **Background sync** — configurable remote endpoint; transactions and categories are pushed
  and pulled automatically.
- **PIN authentication** — secure app entry with a local PIN and biometric fallback.
- **Analytics dashboard** — spending overview with a donut chart and category breakdown.
- **Daily reminder notifications** — configurable push notification to prompt transaction logging.
- **User profile** — display name and avatar customisation.
- **Theme support** — light, dark, and system-adaptive themes.
- **Bilingual support** — English with the localisation infrastructure ready for additional
  languages.
