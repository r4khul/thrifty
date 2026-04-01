# Architecture Documentation

## Overview

Thrifty is built on a layered, feature-driven architecture that emphasizes separation of concerns, testability, and maintainability. The application follows Clean Architecture principles adapted for Flutter, with a strong focus on offline-first capabilities and eventual consistency with remote data sources.

## Core Architectural Principles

### 1. Offline-First Design

The application is designed to function fully without network connectivity. All data operations prioritize local persistence using SQLite through the Drift ORM. Network synchronization is treated as an enhancement rather than a requirement.

**Key Implementation:**
- Local database is the single source of truth
- All mutations happen locally first
- Background sync reconciles local and remote state
- Optimistic UI updates with rollback capabilities

### 2. Feature-Driven Structure

Each feature is a self-contained module with clear boundaries:

```
features/[feature_name]/
  ├── data/           # Data layer
  │   ├── [feature]_repository_impl.dart
  │   ├── [feature]_remote_data_source.dart
  │   └── [feature]_repository_provider.dart
  ├── domain/         # Business logic layer
  │   ├── [feature]_entity.dart
  │   └── [feature]_repository.dart (interface)
  └── presentation/   # UI layer
      ├── [feature]_page.dart
      ├── providers/
      └── widgets/
```

This structure ensures:
- Clear dependency flow (UI → Domain → Data)
- Easy testing and mocking
- Minimal coupling between features
- Independent feature development

### 3. State Management with Riverpod

The application uses Riverpod 3.x with code generation for type-safe, compile-time dependency injection.

**Provider Types Used:**
- `@riverpod` for auto-dispose providers (UI-bound state)
- `@Riverpod(keepAlive: true)` for app-wide singletons
- `StreamProvider` for reactive database queries
- `FutureProvider` for async initialization

**State Flow:**
```
User Interaction → Controller Provider → Repository → Data Source → Database/API
                                              ↓
                                         State Update
                                              ↓
                                          UI Rebuild
```

## Data Layer Architecture

### Database Schema

The app uses three primary tables:

#### Transactions Table
```dart
class Transactions extends Table {
  TextColumn get id => text()();              // UUID
  RealColumn get amount => real()();          // Signed amount
  TextColumn get categoryId => text()();      // Foreign key
  IntColumn get timestamp => integer()();     // Epoch millis
  TextColumn get note => text().nullable()(); // Optional note
  BoolColumn get editedLocally => boolean();  // Sync flag
  IntColumn get createdAt => integer()();     // Metadata
  IntColumn get updatedAt => integer()();     // Metadata
}
```

#### Categories Table
```dart
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get editedLocally => boolean();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}
```

#### Attachments Table
```dart
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get createdAt => integer()();
}
```

### Repository Pattern

Each feature implements a repository interface in the domain layer, with concrete implementation in the data layer.

**Repository Responsibilities:**
1. Abstract data source details from business logic
2. Coordinate between local (DAO) and remote data sources
3. Handle error mapping and recovery
4. Manage sync state and conflict resolution
5. Expose reactive streams for UI consumption

**Example Flow (Transaction Creation):**
```dart
// 1. User submits form
await ref.read(transactionControllerProvider.notifier).create(entity);

// 2. Controller delegates to repository
await repository.upsert(transaction);

// 3. Repository persists locally
await dao.upsert(row.copyWith(editedLocally: true));

// 4. Background sync picks up changes
await syncController.syncAll();

// 5. Repository pushes to remote
await remoteDataSource.push(entity);

// 6. Clears local edit flag on success
await dao.clearEditedLocally(id);
```

## Synchronization Strategy

### Sync States

The application tracks synchronization through the `SyncStatus` enum:
- `idle` - No active sync operation
- `syncing` - Sync in progress
- `failed` - Last sync attempt failed

### Sync Flow

Background sync is triggered on:
1. Application startup (via `SyncController`)
2. User pull-to-refresh gesture
3. After local mutations (transactions, categories)

**Two-Phase Sync Process:**

**Phase 1: Push (Local → Remote)**
```dart
// 1. Query locally modified records
final editedRecords = await dao.getEditedLocally();

// 2. Push each to remote
for (final record in editedRecords) {
  await remoteDataSource.push(toEntity(record));
  await dao.clearEditedLocally(record.id);
}
```

**Phase 2: Pull (Remote → Local)**
```dart
// 1. Fetch all remote records
final remoteRecords = await remoteDataSource.fetchAll();

// 2. Merge with local using last-write-wins
for (final remote in remoteRecords) {
  final local = await dao.getById(remote.id);
  
  if (local == null) {
    // Insert new remote record
    await dao.upsert(toRow(remote).copyWith(editedLocally: false));
  } else if (!local.editedLocally) {
    // Update if remote is newer
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      await dao.upsert(toRow(remote).copyWith(editedLocally: false));
    }
  } else {
    // Preserve local edits unless remote is strictly newer
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      await dao.upsert(toRow(remote).copyWith(editedLocally: false));
    }
  }
}
```

### Conflict Resolution

The application uses **last-write-wins** strategy based on `updatedAt` timestamps:

1. Local edits are preserved during sync if they are newer
2. Remote changes override local if remote timestamp is later
3. `editedLocally` flag prevents accidental overwrites
4. No merge conflicts; atomic record-level updates

### Error Handling

Sync errors are handled gracefully:
- Network failures return empty arrays (silent fallback)
- Parse errors skip individual records, continue processing
- Sync failures don't block app functionality
- UI shows sync status indicator for transparency

## Authentication and Session Management

### Session Storage

User sessions are stored securely using `flutter_secure_storage`:
- Email and PIN are hashed before storage
- `rememberMe` flag controls session persistence
- Sessions survive app restarts if enabled

### Auth Flow

```
App Launch → AuthController.build()
                  ↓
         AuthRepository.getSession()
                  ↓
         Secure Storage Retrieval
                  ↓
    ┌─────────────┴─────────────┐
    ↓                           ↓
Session Found            Session Not Found
    ↓                           ↓
Navigate to Home          Navigate to Login
```

### Route Guards

The `app_router.dart` implements authentication-aware navigation:
- Unauthenticated users redirected to `/login`
- Authenticated users bypass login screen
- Deep links preserved during auth transitions
- Splash screen shown during session validation

## UI Layer Architecture

### State Management Patterns

**1. Page-Level Controllers**
```dart
@riverpod
class TransactionController extends _$TransactionController {
  @override
  FutureOr<void> build() async {}
  
  Future<void> create(TransactionEntity entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).upsert(entity);
    });
  }
}
```

**2. Reactive Data Streams**
```dart
@riverpod
Stream<List<TransactionEntity>> transactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
}
```

**3. Derived State**
```dart
@riverpod
double totalIncome(Ref ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  return transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
}
```

### Widget Composition

The app follows a component-based UI structure:
- Pages are composed of feature-specific widgets
- Shared widgets live in `core/widgets/`
- Each widget has a single, focused responsibility
- Business logic stays in providers, widgets remain pure

## Performance Optimizations

### 1. Database Indexing
```dart
@TableIndex(name: 'tx_filter_idx', columns: {#timestamp, #categoryId})
class Transactions extends Table { }
```

### 2. Lazy Loading
- Transactions loaded incrementally via pagination
- Analytics computed on-demand per date range
- Attachments loaded only when viewing transaction details

### 3. Provider Auto-Dispose
- Page-scoped providers automatically disposed when navigating away
- Prevents memory leaks in long-running app sessions
- `keepAlive: true` only for truly global state

### 4. Efficient Rebuilds
- Riverpod's fine-grained reactivity minimizes widget rebuilds
- Immutable entities prevent accidental mutations
- Freezed generates efficient equality checks

## Notification System

The app uses `flutter_local_notifications` for scheduled reminders.

### Scheduling Logic

Daily reminders are scheduled 14 days in advance at 8:00 PM:
```dart
scheduleDailyReminder({
  required TimeOfDay time,
  required Set<DateTime> datesToSkip,
  required String title,
  required String body,
  int daysAhead = 14,
})
```

### Cancellation Strategy

Notifications are cancelled when:
1. User logs a transaction for that day (automatic)
2. User disables notifications in settings
3. App is uninstalled

### Unique ID Generation
```dart
int _getNotificationIdForDate(DateTime date) {
  final jan1 = DateTime(date.year);
  final dayOfYear = date.difference(jan1).inDays;
  return 1000 + ((date.year % 10) * 400) + dayOfYear;
}
```

This ensures stable IDs that can be targeted for cancellation.

## Localization Architecture

The app supports English and Tamil using Flutter's built-in l10n system.

### ARB Files
- `app_en.arb` - English translations
- `app_ta.arb` - Tamil translations

### Dynamic Language Switching
```dart
@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString('locale') ?? 'en';
    return Locale(code);
  }
  
  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('locale', locale.languageCode);
    state = locale;
  }
}
```

Changing the locale instantly updates all UI text without app restart.

## Theme System

The app supports three theme modes: light, dark, and system.

### Theme Structure
```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    fontFamily: 'Chillax',
    // ... other configurations
  );
  
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Chillax',
    // ... other configurations
  );
}
```

### System Brightness Tracking
```dart
class _ThriftyAppState extends ConsumerState<ThriftyApp>
    with WidgetsBindingObserver {
  @override
  void didChangePlatformBrightness() {
    // Rebuild when system theme changes
    setState(() {});
  }
}
```

## Analytics Architecture

The analytics feature provides financial insights through various visualizations.

### Data Aggregation

Analytics are computed on-demand using reactive streams:
```dart
@riverpod
FinancialSummary summary(Ref ref, DateTime start, DateTime end) {
  final transactions = ref.watch(transactionsInRangeProvider(start, end));
  
  return FinancialSummary(
    totalIncome: transactions.where((t) => t.isIncome).sum,
    totalExpense: transactions.where((t) => t.isExpense).sum,
    netBalance: transactions.sum,
    transactionCount: transactions.length,
  );
}
```

### Chart Types

1. **Donut Chart** - Category-wise expense breakdown
2. **Bar Chart** - Income vs Expense comparison
3. **Flow Chart** - Daily transaction timeline
4. **Summary Cards** - Key financial metrics

All charts use `fl_chart` package with custom styling to match app theme.

## Testing Strategy

The architecture supports comprehensive testing:

### Unit Tests
- Domain entities (business logic)
- Repository interfaces (mocking)
- Utility functions

### Widget Tests
- Individual UI components
- User interaction flows
- State transitions

### Integration Tests
- End-to-end user journeys
- Database operations
- Sync workflows

### Mocking Strategy
```dart
class MockTransactionRepository extends Mock 
    implements TransactionRepository {}

void main() {
  late MockTransactionRepository repository;
  
  setUp(() {
    repository = MockTransactionRepository();
  });
  
  test('creates transaction successfully', () async {
    when(() => repository.upsert(any()))
        .thenAnswer((_) async => {});
    
    // Test implementation
  });
}
```

## Scalability Considerations

### Current Design Supports:

1. **Horizontal Feature Growth**
   - New features added as isolated modules
   - Minimal impact on existing functionality
   - Clear dependency management

2. **Data Volume**
   - Indexed database queries for performance
   - Pagination for large datasets
   - Efficient date-range filtering

3. **Multi-Tenancy**
   - Session-based user isolation
   - User-specific data partitioning
   - Ready for cloud backend integration

### Future Enhancements:

1. **Multi-Device Sync**
   - Implement WebSocket for real-time sync
   - Add device ID to sync metadata
   - Conflict resolution at field level

2. **Cloud Backup**
   - Export/import database snapshots
   - Encrypted cloud storage integration
   - Automatic periodic backups

3. **Advanced Analytics**
   - Budget forecasting with ML models
   - Anomaly detection in spending
   - Custom report generation

## Security Considerations

### Current Implementation:

1. **Local Data Encryption**
   - Secure storage for auth credentials
   - SQLite encryption (not yet implemented)

2. **Input Validation**
   - Entity-level validation
   - Repository-level constraints
   - UI-level form validation

3. **API Security**
   - HTTPS required for remote endpoints
   - No hardcoded secrets
   - Configurable base URLs

### Recommendations for Production:

1. Enable SQLCipher for database encryption
2. Implement certificate pinning for API calls
3. Add biometric authentication option
4. Implement data retention policies
5. Add audit logging for sensitive operations

## Maintainability

### Code Quality Tools

1. **Static Analysis**: `flutter analyze` with strict linting rules
2. **Custom Lint**: Riverpod-specific lints for best practices
3. **Code Generation**: Automated boilerplate reduction
4. **Documentation**: Inline comments for complex logic

### Dependency Management

All dependencies are version-pinned in `pubspec.yaml`:
- Regular updates for security patches
- Breaking change migration handled incrementally
- dev_dependencies isolated from production build

### Migration Strategy

Database schema changes handled through Drift migrations:
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // Version-specific migrations
      if (from < 3) {
        await m.createAll();
      }
    },
  );
}
```

## Conclusion

Thrifty's architecture balances pragmatism with best practices. The offline-first approach ensures reliability, feature modularity enables parallel development, and Riverpod provides type-safe state management. The system is designed for independent feature evolution while maintaining consistency through shared infrastructure in the core layer.
