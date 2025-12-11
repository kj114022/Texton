# Modular Architecture Plan for Pantheon App

## Overview
This document outlines the plan to extend Pantheon from a simple book downloader into a modular, multi-feature platform with clear separation of concerns.

## Current State
- **Base Module**: `io.github.aloussase.booksdownloader` (Book Downloader)
- **Architecture**: MVVM with Hilt DI
- **Structure**: UI (Fragments) → ViewModels → Repositories → Data Sources

## Vision: Modular Feature Expansion

### Phase 1: ✅ Book Downloader (Current)
- Search for eBooks
- Download from multiple sources
- Format conversion (EPUB, PDF, MOBI, AZW3)

### Phase 2: 📖 eBook Reader Module
- **Purpose**: Read downloaded books in all supported formats
- **Key Features**:
  - Load files directly from cache
  - Multi-format support (EPUB, PDF, MOBI, AZW3, TXT, HTML)
  - Reading progress tracking
  - Bookmarks and highlights
  - Text settings (font size, color theme, line height)
- **Package**: `feature.reader`
- **Dependencies**: Downloader module
- **New Dependencies**: EPUB reader lib (XUEPUB or similar), PDF reader

### Phase 3: 💾 Local Sync Module
- **Purpose**: Sync files with user-selected folder
- **Key Features**:
  - Watch folder for new books
  - Auto-import from selected directory
  - Bidirectional sync
  - Conflict resolution
- **Package**: `feature.sync`
- **Dependencies**: Downloader, Reader modules
- **New Dependencies**: File observer libs, RxJava for reactive sync

### Phase 4: 📝 Notes Module
- **Purpose**: Take notes while reading
- **Key Features**:
  - Create/edit/delete notes
  - Link notes to books/passages
  - Search notes
  - Export notes
- **Package**: `feature.notes`
- **Dependencies**: Reader module
- **Database**: SQLite/Room for note storage

### Phase 5: 📅 Calendar Module
- **Purpose**: Schedule reading sessions, book club events
- **Key Features**:
  - Calendar view
  - Event scheduling
  - Reminders
  - Reading goals
- **Package**: `feature.calendar`
- **Dependencies**: Room database
- **New Dependencies**: Calendar libs, Notification framework

### Phase 6: 📧 Email Module
- **Purpose**: Send books, notes, reading lists via email
- **Key Features**:
  - Email configuration
  - Send books as attachments
  - Share reading lists
  - Export to email
- **Package**: `feature.email`
- **Dependencies**: All other modules
- **New Dependencies**: Email libs, SMTP integration

## Modular Architecture Pattern

```
app/
├── src/
│   └── main/
│       └── java/io/github/aloussase/booksdownloader/
│           ├── core/                    # Shared utilities, base classes
│           ├── feature/
│           │   ├── downloader/          # Book downloader feature (Phase 1)
│           │   ├── reader/              # eBook reader feature (Phase 2)
│           │   ├── sync/                # Local sync feature (Phase 3)
│           │   ├── notes/               # Notes feature (Phase 4)
│           │   ├── calendar/            # Calendar feature (Phase 5)
│           │   └── email/               # Email feature (Phase 6)
│           └── ui/
│               ├── navigation/          # Centralized navigation
│               └── MainActivity.kt       # Main entry point
```

## Key Principles

### 1. **Feature Isolation**
- Each feature has its own package
- Each feature is independently testable
- Features communicate through defined interfaces

### 2. **Clean Architecture**
```
feature/[name]/
├── presentation/          # UI Layer (Fragments, ViewModels)
├── domain/                # Business Logic (UseCases, Repositories)
│   ├── model/
│   ├── repository/        # Interfaces
│   └── usecase/
└── data/                  # Data Layer (Implementations, DB, Network)
    ├── model/
    ├── repository/        # Implementations
    ├── datasource/        # Local/Remote
    └── db/
```

### 3. **Dependency Flow**
```
UI Layer (Fragments, ViewModels)
        ↓
Domain Layer (UseCases, Interfaces)
        ↓
Data Layer (Repositories, DataSources)
        ↓
External Libraries & Database
```

### 4. **Hilt Dependency Injection**
- Each feature has its own module for DI
- Core utilities in shared `core` package
- Feature modules injected into main app

## Implementation Strategy

### Step 1: Refactor Current Codebase (Downloader)
- Move existing code into `feature/downloader` package
- Create `core` package with shared utilities
- Establish base classes and interfaces

### Step 2: Create Feature Template
- Build scaffolding for new features
- Define standard interfaces and base classes
- Create example with Reader module

### Step 3: Implement Features Incrementally
- One feature at a time
- Each feature fully tested before next
- Clear communication between features

### Step 4: Shared Utilities (Core Package)
```
core/
├── base/
│   ├── BaseFragment.kt
│   ├── BaseViewModel.kt
│   └── BaseRepository.kt
├── di/
│   └── CoreModule.kt
├── utils/
│   ├── FileUtils.kt
│   ├── NotificationUtils.kt
│   └── PermissionUtils.kt
├── models/
│   ├── Result.kt
│   └── DataState.kt
└── constants/
    └── Constants.kt
```

## Navigation Pattern

Use Android Navigation Component with deep linking:

```kotlin
// Feature navigation setup
interface FeatureNavigator {
    fun navigateToDownloader()
    fun navigateToReader(bookId: String)
    fun navigateToNotes(bookId: String?)
    fun navigateToCalendar()
    fun navigateToEmail()
}
```

## Database Strategy

Use Room database with:
- Separate DAOs for each feature
- Shared database with feature-specific tables
- Migrations handled through version management

## Testing Strategy

- Unit tests for UseCase/Repository layer
- Integration tests for Database
- UI tests for critical user flows
- Feature-level testing before integration

## Build Optimization

- Modular build setup for faster builds
- Feature flags for gradual rollout
- ProGuard rules per feature

## Next Steps

1. **Rename current package** if needed for consistency
2. **Refactor existing code** into downloader feature
3. **Create core module** with shared utilities
4. **Start Phase 2** with reader implementation
5. **Document each feature's API** for easy integration

---

This architecture allows for:
✅ Independent development of features
✅ Easy testing and maintenance
✅ Clear dependency management
✅ Future scaling
✅ Easy feature toggling/removal
✅ Reusable patterns across features
