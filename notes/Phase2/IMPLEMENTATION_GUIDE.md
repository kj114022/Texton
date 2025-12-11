# Step-by-Step Implementation Guide

## Phase 0: Refactoring Current Code into Modular Structure

### Goal
Move existing book downloader code into `feature/downloader` package and create `core` utilities.

### Step 0.1: Create Core Package Structure

Run this to create the core package directories:

```bash
mkdir -p app/src/main/java/io/github/aloussase/booksdownloader/core/{base,di,utils,models,constants}
mkdir -p app/src/main/java/io/github/aloussase/booksdownloader/feature/downloader/{presentation,domain,data}
```

### Step 0.2: Create Feature Package for Downloader

```bash
mkdir -p app/src/main/java/io/github/aloussase/booksdownloader/feature/downloader/{presentation/{ui,viewmodel},domain/{repository,usecase,model},data/{repository,datasource,model}}
```

### Step 0.3: Files to Move/Create

#### Core Package Files

1. **core/base/BaseFragment.kt** - Base fragment class
2. **core/base/BaseViewModel.kt** - Base viewmodel class
3. **core/di/CoreModule.kt** - Core DI module
4. **core/utils/FileUtils.kt** - File operations
5. **core/utils/PermissionUtils.kt** - Permission handling
6. **core/models/Result.kt** - Sealed class for results
7. **core/models/DataState.kt** - UI state management

#### Move Existing Files

- Move `ui/fragments/*` → `feature/downloader/presentation/ui/fragments/`
- Move `viewmodels/*` → `feature/downloader/presentation/viewmodel/`
- Move `repositories/*` → `feature/downloader/data/repository/`
- Move `data/source/*` → `feature/downloader/data/datasource/`
- Move `domain/*` → `feature/downloader/domain/`
- Create `feature/downloader/data/di/DownloaderModule.kt`

### Step 0.4: Update Package Names

All imports will change from:
```kotlin
io.github.aloussase.booksdownloader.ui.fragments
```

To:
```kotlin
io.github.aloussase.booksdownloader.feature.downloader.presentation.ui.fragments
```

---

## Phase 1: Create Shared Core Utilities

### Files to Create

#### 1. core/models/Result.kt
```kotlin
package io.github.aloussase.booksdownloader.core.models

sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val exception: Exception, val data: T? = null) : Result<T>()
    class Loading<T> : Result<T>()
}
```

#### 2. core/models/DataState.kt
```kotlin
package io.github.aloussase.booksdownloader.core.models

sealed class DataState<T> {
    data class Success<T>(val data: T) : DataState<T>()
    data class Error<T>(val message: String) : DataState<T>()
    class Loading<T> : DataState<T>()
}
```

#### 3. core/base/BaseFragment.kt
```kotlin
package io.github.aloussase.booksdownloader.core.base

import androidx.fragment.app.Fragment

abstract class BaseFragment : Fragment() {
    // Common fragment functionality
}
```

#### 4. core/base/BaseViewModel.kt
```kotlin
package io.github.aloussase.booksdownloader.core.base

import androidx.lifecycle.ViewModel

abstract class BaseViewModel : ViewModel() {
    // Common viewmodel functionality
}
```

---

## Phase 2: Create Feature Structure Template

### Directory Structure for Each Feature

```
feature/[feature-name]/
├── presentation/
│   ├── ui/
│   │   ├── fragments/
│   │   ├── adapters/
│   │   └── dialogs/
│   └── viewmodel/
│       └── [Feature]ViewModel.kt
├── domain/
│   ├── model/
│   ├── repository/
│   │   └── I[Feature]Repository.kt
│   └── usecase/
│       └── [Feature]UseCase.kt
├── data/
│   ├── repository/
│   │   └── [Feature]RepositoryImpl.kt
│   ├── datasource/
│   │   ├── local/
│   │   └── remote/
│   ├── model/
│   └── db/
│       └── [Feature]Dao.kt
└── di/
    └── [Feature]Module.kt
```

### Template Files

#### feature/[name]/domain/repository/I[Feature]Repository.kt
```kotlin
package io.github.aloussase.booksdownloader.feature.[name].domain.repository

interface I[Feature]Repository {
    // Define contract for feature
}
```

#### feature/[name]/data/repository/[Feature]RepositoryImpl.kt
```kotlin
package io.github.aloussase.booksdownloader.feature.[name].data.repository

import io.github.aloussase.booksdownloader.feature.[name].domain.repository.I[Feature]Repository

class [Feature]RepositoryImpl : I[Feature]Repository {
    // Implement contract
}
```

#### feature/[name]/domain/usecase/[Feature]UseCase.kt
```kotlin
package io.github.aloussase.booksdownloader.feature.[name].domain.usecase

import io.github.aloussase.booksdownloader.core.base.BaseViewModel
import io.github.aloussase.booksdownloader.feature.[name].domain.repository.I[Feature]Repository

class [Feature]UseCase(
    private val repository: I[Feature]Repository
) {
    // Business logic implementation
}
```

#### feature/[name]/presentation/viewmodel/[Feature]ViewModel.kt
```kotlin
package io.github.aloussase.booksdownloader.feature.[name].presentation.viewmodel

import io.github.aloussase.booksdownloader.core.base.BaseViewModel
import io.github.aloussase.booksdownloader.feature.[name].domain.usecase.[Feature]UseCase

class [Feature]ViewModel(
    private val useCase: [Feature]UseCase
) : BaseViewModel() {
    // UI state and logic
}
```

#### feature/[name]/di/[Feature]Module.kt
```kotlin
package io.github.aloussase.booksdownloader.feature.[name].di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import io.github.aloussase.booksdownloader.feature.[name].data.repository.[Feature]RepositoryImpl
import io.github.aloussase.booksdownloader.feature.[name].domain.repository.I[Feature]Repository
import io.github.aloussase.booksdownloader.feature.[name].domain.usecase.[Feature]UseCase

@Module
@InstallIn(SingletonComponent::class)
object [Feature]Module {

    @Provides
    fun provide[Feature]Repository(): I[Feature]Repository {
        return [Feature]RepositoryImpl()
    }

    @Provides
    fun provide[Feature]UseCase(
        repository: I[Feature]Repository
    ): [Feature]UseCase {
        return [Feature]UseCase(repository)
    }
}
```

---

## Phase 3: Update Main App

### Update AndroidManifest.xml
Add feature activities/fragments as needed

### Update MainActivity.kt
```kotlin
package io.github.aloussase.booksdownloader

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.github.aloussase.booksdownloader.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        // Navigation setup
    }
}
```

### Update App.kt
```kotlin
package io.github.aloussase.booksdownloader

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class App : Application()
```

### Update build.gradle.kts
Add feature-specific dependencies as modules grow:

```gradle
// Downloader feature
implementation(project(":feature-downloader"))

// Reader feature (when ready)
// implementation(project(":feature-reader"))
```

---

## Navigation Pattern

### Setup Navigation Graph

Create `res/navigation/nav_graph.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/nav_graph"
    app:startDestination="@id/downloaderFragment">

    <!-- Downloader Feature -->
    <fragment
        android:id="@id/downloaderFragment"
        android:name="io.github.aloussase.booksdownloader.feature.downloader.presentation.ui.fragments.BookSearchFragment"
        android:label="Downloads" />

    <!-- Reader Feature (Phase 2) -->
    <!-- <fragment
        android:id="@id/readerFragment"
        android:name="io.github.aloussase.booksdownloader.feature.reader.presentation.ui.ReaderFragment"
        android:label="Reader" /> -->

</navigation>
```

---

## Build Configuration

### settings.gradle.kts
```gradle
// When creating modular features
include(":app")
include(":feature-downloader")
// include(":feature-reader")
// include(":feature-notes")
```

### Feature Module build.gradle.kts Template
```gradle
plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    kotlin("kapt")
    id("com.google.dagger.hilt.android")
}

android {
    compileSdk = 34
    defaultConfig {
        minSdk = 19
    }
}

dependencies {
    implementation(project(":app"))
    // Feature-specific dependencies
}
```

---

## Execution Order

1. **Create core utilities** (Day 1)
2. **Move existing downloader code** (Day 2-3)
3. **Update all package imports** (Day 3)
4. **Test build and runtime** (Day 4)
5. **Start Phase 2 (Reader)** (Day 5+)

---

## Common Commands

```bash
# Build
./gradlew build

# Run
./gradlew installDebug

# Test
./gradlew test

# Check imports
grep -r "import io.github.aloussase.booksdownloader" app/src/main/java
```
