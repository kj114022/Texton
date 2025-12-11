# Quick Start: Begin Modular Development

## Current Status ✅

Core utilities and documentation created:
- `core/base/` - BaseFragment, BaseViewModel
- `core/models/` - Result, DataState
- `core/utils/` - FileUtils, PermissionUtils
- `core/di/` - CoreModule with Hilt setup

---

## Immediate Next Steps (This Week)

### Step 1: Verify Core Build

```bash
cd /Users/tourist/code/Pantheon_apk
./gradlew build
```

This will compile the new core utilities.

### Step 2: Review Current Downloader Code

Understand the structure:
```bash
find app/src/main/java -type f -name "*.kt" | grep -E "(ui|viewmodels|repositories)" | head -10
```

### Step 3: Plan Phase 1 Refactoring

Create directory for downloader feature:
```bash
mkdir -p app/src/main/java/io/github/aloussase/booksdownloader/feature/downloader/{presentation/{ui,viewmodel},domain/{repository,usecase,model},data/{repository,datasource},di}
```

---

## Decision Points

### Question 1: Refactor Now or Add Reader First?

**Option A: Refactor First (Recommended)**
- Move existing downloader into feature package
- Update all imports
- Solidify architecture
- Then build reader on clean foundation
- **Timeline**: 1-2 weeks
- **Risk**: Low
- **Benefit**: Cleaner future development

**Option B: Build Reader Alongside**
- Keep downloader as-is
- Build reader in parallel
- Integrate both later
- **Timeline**: 3-4 weeks
- **Risk**: Higher merge complexity
- **Benefit**: Faster feature delivery

**Recommendation**: Choose Option A for better long-term maintainability.

---

## Week 1 Plan: Core Foundation

### Monday-Tuesday: Code Review & Planning
- [ ] Review existing downloader code
- [ ] Identify which classes move where
- [ ] Document all imports that need updating
- [ ] Create migration checklist

### Wednesday-Thursday: Move & Update
- [ ] Create feature/downloader structure
- [ ] Move UI fragments
- [ ] Move ViewModels
- [ ] Move Repositories

### Friday: Testing & Integration
- [ ] Update all imports
- [ ] Build and test
- [ ] Fix any compilation errors
- [ ] Commit clean refactoring

---

## Week 2 Plan: Reader Foundation

### Monday-Tuesday: Domain Layer
- [ ] Create reader domain models (BookFormat, BookPage, etc.)
- [ ] Create repository interface (IBookReaderRepository)
- [ ] Create parser interface (BookParser)
- [ ] Write unit tests for models

### Wednesday-Thursday: Data Layer
- [ ] Create RepositoryImpl
- [ ] Setup Room database
- [ ] Create DAOs
- [ ] Implement local data source

### Friday: Integration
- [ ] Create DI module
- [ ] Write integration tests
- [ ] Resolve any issues
- [ ] Prepare for UI implementation

---

## Files to Create This Week

### Phase 0 (Downloader Refactoring)

Move existing files to:
```
feature/downloader/
├── presentation/ui/
│   ├── BookSearchFragment.kt          (from ui/fragments)
│   ├── BookDetailsFragment.kt         (from ui/fragments)
│   ├── ConvertFragment.kt             (from ui/fragments)
│   └── adapters/
│       └── BooksAdapter.kt
├── presentation/viewmodel/
│   ├── BookSearchViewModel.kt         (from viewmodels)
│   ├── BookDownloadsViewModel.kt      (from viewmodels)
│   └── ConvertViewModel.kt            (from viewmodels)
├── domain/
│   ├── repository/
│   │   └── IBookDownloadRepository.kt
│   ├── usecase/
│   │   ├── SearchBooksUseCase.kt
│   │   ├── DownloadBookUseCase.kt
│   │   └── ConvertBookUseCase.kt
│   └── model/
│       └── (copy Book.kt, DownloadResult.kt)
├── data/
│   ├── repository/
│   │   └── BookDownloadRepositoryImpl.kt (refactored from BookDownloadsRepositoryImpl)
│   ├── datasource/
│   │   └── (move source files)
│   └── model/
│       └── (entities)
└── di/
    └── DownloaderModule.kt
```

---

## Testing Each Phase

### Build Command
```bash
./gradlew clean build
```

### Run Tests
```bash
./gradlew test
```

### Install on Emulator
```bash
./gradlew installDebug
adb shell am start -n io.github.aloussase.booksdownloader/.ui.MainActivity
```

---

## Debugging Tips

### View Dependency Tree
```bash
./gradlew dependencies --configuration debugRuntimeClasspath
```

### Check Kotlin Compilation
```bash
./gradlew assembleDebug --info 2>&1 | grep -i kotlin
```

### Clean Build Issues
```bash
rm -rf app/build
./gradlew clean
./gradlew build
```

---

## Common Migration Issues & Solutions

### Issue 1: Import Errors After Moving Files

**Problem**: Can't find imports after moving to new package

**Solution**:
```bash
# Find and replace old package name
find app/src -name "*.kt" -type f -exec sed -i '' \
  's/io\.github\.aloussase\.booksdownloader\.ui\./io.github.aloussase.booksdownloader.feature.downloader.presentation.ui./g' {} \;
```

### Issue 2: Hilt DI Module Conflicts

**Problem**: Multiple modules providing same dependency

**Solution**:
```kotlin
// In new DownloaderModule.kt, qualify with @Named or @Qualifier
@Module
@InstallIn(SingletonComponent::class)
object DownloaderModule {
    @Provides
    @Named("downloader")
    fun provideRepository(): IBookDownloadRepository {
        return BookDownloadRepositoryImpl()
    }
}
```

### Issue 3: Navigation Errors

**Problem**: Fragment not found after package move

**Solution**: Update AndroidManifest.xml and nav_graph.xml with new package names:
```xml
<!-- Before -->
android:name="io.github.aloussase.booksdownloader.ui.fragments.BookSearchFragment"

<!-- After -->
android:name="io.github.aloussase.booksdownloader.feature.downloader.presentation.ui.BookSearchFragment"
```

---

## Code Style Guidelines

### Package Organization
```kotlin
package io.github.aloussase.booksdownloader.feature.reader.presentation.viewmodel

// Imports organized: Android → Androidx → Third-party → Project
import android.content.Context
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.aloussase.booksdownloader.core.base.BaseViewModel

@HiltViewModel
class ReaderViewModel @Inject constructor(
    // ...
)
```

### Naming Conventions
```kotlin
// Classes
class BookReaderFragmentViewModel { }
interface IBookRepository { }

// Functions
fun getBookMetadata() { }
private fun parseEpubFile() { }

// Variables
private val bookMetadata: LiveData<Book>
private val _bookMetadata = MutableLiveData<Book>()

// Constants
companion object {
    private const val TAG = "ReaderViewModel"
    private const val DEFAULT_FONT_SIZE = 16f
}
```

---

## Documentation Standards

### KDoc Comments
```kotlin
/**
 * Loads a book from the given file path and returns its metadata.
 *
 * @param filePath the absolute path to the book file
 * @return Result containing BookMetadata or an exception
 */
suspend fun loadBook(filePath: String): Result<BookMetadata>
```

### Inline Comments
```kotlin
// Only for complex logic
if (currentPage > totalPages) {
    // Reading progress beyond total pages indicates cached data corruption
    // Reset to last valid page
    currentPage = totalPages
}
```

---

## Git Workflow

### Create Feature Branch
```bash
git checkout -b feature/modularize-downloader
```

### Commit Strategy
```bash
# Create small, logical commits
git add core/
git commit -m "feat: add core base classes and utilities"

git add feature/downloader/
git commit -m "refactor: move downloader to feature module"

git add app/build.gradle.kts
git commit -m "build: update dependencies for downloader feature"
```

### Push and Create PR
```bash
git push origin feature/modularize-downloader
# Create PR on GitHub with detailed description
```

---

## Performance Checklist

Before completing each phase:

- [ ] Build time < 60 seconds
- [ ] APK size increase < 100KB
- [ ] No memory leaks in ViewModels
- [ ] Database queries < 200ms
- [ ] No unused imports or code
- [ ] ProGuard rules updated

---

## Deliverables for Each Phase

### Phase 0 (Downloader Refactoring)
- [ ] Feature module structure created
- [ ] All code moved and imports updated
- [ ] Build succeeds without warnings
- [ ] App launches and basic features work
- [ ] Unit tests updated and passing
- [ ] Code review completed

### Phase 1 (Reader Foundation)
- [ ] Domain models created
- [ ] Repository interface defined
- [ ] Parser interface created
- [ ] Unit tests for models > 80% coverage
- [ ] Code review completed
- [ ] Documentation updated

---

## Support Resources

### Local Resources
- `MODULAR_ARCHITECTURE.md` - Architecture overview
- `IMPLEMENTATION_GUIDE.md` - Detailed refactoring steps
- `PHASE_2_READER_GUIDE.md` - Reader module details
- `FULL_DEVELOPMENT_ROADMAP.md` - Complete roadmap

### Online Resources
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Android MVVM](https://developer.android.com/jetpack/guide)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)
- [Hilt DI](https://dagger.dev/hilt/)

---

## Next Checkpoint

**Target Date**: End of Week 2

**Checklist**:
- [ ] Core utilities compiling
- [ ] Downloader refactored to feature module
- [ ] All imports updated
- [ ] App builds and runs
- [ ] Reader domain layer ready
- [ ] Branch created for Phase 1

**Go/No-Go Decision**:
- If all items checked: ✅ Proceed to Phase 1
- If any blocker: 🔄 Resolve and recheck

---

## Getting Help

When stuck:

1. **Check**: Review relevant documentation files
2. **Search**: Use grep to find similar implementations
3. **Test**: Create a minimal test case
4. **Debug**: Use Android Studio debugger
5. **Ask**: Document issue and ask in comments

---

## Quick Commands Reference

```bash
# Build
./gradlew build

# Test
./gradlew test

# Install
./gradlew installDebug

# Clean
./gradlew clean

# Lint
./gradlew lint

# Check dependencies
./gradlew dependencies

# Format code
./gradlew formatKotlin

# Find file
find app/src -name "FileName.kt"

# Search text
grep -r "search_text" app/src/main/java
```

---

**Status**: Ready to Start
**Created**: November 25, 2025
**Next Review**: End of Week 1
