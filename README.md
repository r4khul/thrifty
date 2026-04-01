<p align="center">
  <img src="assets/icons/app_icon_without_bg.png" alt="Thrifty Logo" width="150"/>
</p>

# Thrifty

![Flutter CI](https://github.com/r4khul/thrifty/actions/workflows/flutter-ci.yml/badge.svg)
![Coverage](https://img.shields.io/badge/Coverage-80.5%25-brightgreen)
![Downloads](https://img.shields.io/github/downloads/r4khul/thrifty/latest/total?logo=android&logoColor=white&label=Downloads&color=3DDC84&style=flat)
![GitHub stars](https://img.shields.io/github/stars/r4khul/thrifty?logo=github&style=flat-square)

> 📊 **Test Coverage**: 69 tests passing • [View detailed coverage report](docs/TEST_COVERAGE.md)

A comprehensive finance management application built with Flutter. This application provides offline-first financial transaction tracking with background synchronization capabilities, bilingual support (English and Tamil), and a modern, responsive user interface.

## Project Overview

Thrifty is a comprehensive financial tracking application designed to help users manage their expenses and income efficiently. The app solves the problem of fragmented financial data by providing a unified platform that works offline and syncs when connectivity is available.

### Key Features

- **Offline-first architecture** with local SQLite database using Drift ORM
- **Background sync** with configurable remote server endpoints
- **Bilingual support** for English and Tamil with full localization
- **Financial analytics** with visual charts and category breakdowns
- **Secure authentication** with PIN-based login
- **Daily notification reminders** for transaction logging
- **File attachments** for transaction receipts
- **Category management** with custom icons and colors
- **Profile customization** and settings management

## App Screenshots

<div align="center">
  <img src="docs/images/s1.jpg" width="180" />
  <img src="docs/images/s2.jpg" width="180" />
  <img src="docs/images/s3.jpg" width="180" />
  <img src="docs/images/s4.jpg" width="180" />
  <br/>
  <img src="docs/images/s5.jpg" width="180" />
  <img src="docs/images/s6.jpg" width="180" />
  <img src="docs/images/s7.jpg" width="180" />
  <img src="docs/images/s8.jpg" width="180" />
  <br/>
  <img src="docs/images/s9.jpg" width="180" />
  <img src="docs/images/s10.jpg" width="180" />
  <img src="docs/images/s11.jpg" width="180" />
  <img src="docs/images/s12.jpg" width="180" />
</div>

## Codebase Structure

The project follows a feature-driven architecture with Clean Architecture principles:

```
lib/
├── app/                    # Application-level configuration (routing)
├── core/                   # Shared infrastructure
│   ├── database/          # Drift database, DAOs, and tables
│   ├── providers/         # Global Riverpod providers
│   ├── theme/             # App theming and styling
│   ├── util/              # Utilities (notifications, formatting)
│   └── widgets/           # Reusable UI components
├── features/              # Feature modules
│   ├── analytics/         # Financial overview and charts
│   ├── auth/              # Authentication and session management
│   ├── categories/        # Category CRUD operations
│   ├── profile/           # User profile management
│   ├── settings/          # App settings and configuration
│   └── transactions/      # Transaction management (core feature)
└── l10n/                  # Localization files (ARB)
```

### Feature Module Structure

Each feature follows a layered architecture:

- **data/** - Repository implementations, data sources (local and remote)
- **domain/** - Entities, repository interfaces, and business logic
- **presentation/** - UI pages, widgets, and state providers

For a deeper dive into architectural decisions and data flow, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Prerequisites

- Flutter SDK 3.10.8 or higher
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter extensions
- Git for version control
- A mock server tool (Mockoon, Postman Mock Server, or similar) for background sync testing

## Setup and Installation

### 1. Clone the Repository

```bash
git clone https://github.com/r4khul/thrifty.git
cd thrifty
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

The project uses code generation for Riverpod, Drift, Freezed, and JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the Application

For Android:

```bash
flutter run
```

For iOS:

```bash
flutter run -d ios
```

For debug mode with hot reload:

```bash
flutter run --debug
```

### 5. Build for Production

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

iOS:

```bash
flutter build ios --release
```

## Background Sync and Mock Server

### Why a Mock Server?

Background sync depends on a remote API server. During local development, a mock server provides:

- **Predictable responses** for testing sync logic
- **Offline-safe development** without requiring a live backend
- **Controlled test scenarios** for edge cases and error handling
- **Fast iteration** without deploying backend changes

### Mock Server Setup

The app expects the following REST endpoints. The application is built with robust parsing that handles various response formats, making it easy to work with different mock server configurations.

#### 1. Fetch Transactions

```
GET /transactions
Response: Array of transaction objects
```

**Full format (recommended):**

```json
[
  {
    "id": "tx_001",
    "amount": -50.0,
    "category": "food",
    "ts": "2026-02-09T10:30:00.000Z",
    "note": "Lunch at restaurant"
  },
  {
    "id": "tx_002",
    "amount": 2000.0,
    "category": "salary",
    "ts": "2026-02-01T00:00:00.000Z",
    "note": "Monthly salary"
  }
]
```

**Simplified format (also supported):**

```json
[
  {
    "id": "t1",
    "amount": -199.0,
    "category": "Food",
    "ts": "2025-09-10T19:10:00Z",
    "note": "Idli"
  },
  {
    "id": "t2",
    "amount": 5000.0,
    "category": "Salary",
    "ts": "2025-09-01T09:00:00Z"
  }
]
```

The app gracefully handles:

- Missing optional fields (note, etc.)
- Null values in responses
- Empty arrays
- Malformed individual records (skipped silently)
- Network failures (returns empty list)

#### 2. Push Transaction

```
POST /transactions
Body: Transaction object (same structure as GET response)
Response: 200 OK or 201 Created
```

#### 3. Fetch Categories

```
GET /categories
Response: Array of category objects
```

**Full format (recommended):**

```json
[
  {
    "id": "food",
    "name": "Food & Dining",
    "icon": "restaurant",
    "color": 4294198070,
    "updatedAt": "2026-02-01T00:00:00.000Z"
  },
  {
    "id": "salary",
    "name": "Salary",
    "icon": "payments",
    "color": 4283215696,
    "updatedAt": "2026-02-01T00:00:00.000Z"
  }
]
```

**Simplified format (also supported):**

```json
["Food", "Travel", "Bills", "Shopping", "Salary", "Other"]
```

The app automatically adapts to simple string arrays by creating default category objects with generated IDs, icons, and colors.

#### 4. Push Category

```
POST /categories
Body: Category object (same structure as GET response)
Response: 200 OK or 201 Created
```

**Robustness Features:**

- Validates required fields before parsing
- Skips individual malformed records without failing entire sync
- Handles null responses gracefully
- Continues sync even if individual pushes fail
- No crashes from unexpected API responses

### Running the Mock Server

**Option 1: Using Mockoon**

1. Download and install [Mockoon](https://mockoon.com/)
2. Create a new environment
3. Set base URL to `http://localhost:3000` (or any available port)
4. Add the four routes mentioned above with sample responses
5. Start the mock server

**Option 2: Using ngrok (for device testing)**

1. Start your local mock server (e.g., on port 3000)
2. Install [ngrok](https://ngrok.com/)
3. Run: `ngrok http 3000`
4. Copy the HTTPS URL provided (e.g., `https://xxx.ngrok-free.dev`)
5. Use this URL in the app settings

**Option 3: Using JSON Server**

```bash
npm install -g json-server
# Create a db.json file with transactions and categories arrays
json-server --watch db.json --port 3000
```

## App Configuration

### Changing the Backend URL

1. Launch the application
2. Navigate to **Settings** from the main menu
3. Tap on **Backend Configuration**
4. Enter your mock server URL:
   - Local development: `http://10.0.2.2:3000` (Android emulator)
   - Local development: `http://localhost:3000` (iOS simulator)
   - ngrok tunnel: `https://your-subdomain.ngrok-free.dev`
   - Custom server: Your production API URL
5. Tap **Save**

The app will immediately use the new URL for all sync operations. Pull down on the transactions page to trigger a manual sync and verify the connection.

### Other Settings

- **Theme**: Switch between light, dark, or system-based themes
- **Language**: Toggle between English and Tamil
- **Daily Reminders**: Configure notification time (default: 8:00 PM)
- **Currency**: Select your preferred currency display

## Development Workflow

### Code Generation

When modifying providers, entities, or database schemas, regenerate code:

```bash
# Watch mode for continuous generation during development
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting and Analysis

```bash
# Run static analysis
flutter analyze

# Check for linting issues
flutter pub run custom_lint
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - Detailed system design, state management, and data flow patterns

## Project Roadmap

### Current Version (v1.0.0)

- Core transaction management
- Category system
- Local-first architecture with sync
- Authentication and user profiles
- Analytics dashboard

### Future Enhancements

- **SMS Transaction Parser** - Automatic transaction detection from banking SMS messages with AI-powered parsing
- Budget tracking and alerts
- Recurring transaction support
- Advanced filtering and search
- Export to CSV/PDF
- Cloud backup integration
- Multi-user support with role-based access
- Voice input for quick transaction logging
- Receipt OCR for attachment processing

## Troubleshooting

### Sync Not Working

1. Verify the backend URL in Settings is correct
2. Check that the mock server is running and accessible
3. Review app logs for network errors: `flutter logs`
4. Test the API endpoints directly using curl or Postman

### Build Errors

1. Clean the build cache: `flutter clean`
2. Delete generated files: `rm -rf .dart_tool/`
3. Reinstall dependencies: `flutter pub get`
4. Regenerate code: `flutter pub run build_runner build --delete-conflicting-outputs`

### Database Issues

The app uses schema version 3. If you encounter database errors after updates:

- Uninstall and reinstall the app (development only)
- Production migrations are handled automatically in `database.dart`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please open an issue on the GitHub repository.
