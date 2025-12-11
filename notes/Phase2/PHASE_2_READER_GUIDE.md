# Phase 2: eBook Reader Module Implementation Guide

## Overview

The eBook Reader module will handle reading various book formats (EPUB, PDF, MOBI, AZW3, TXT, HTML) from cache or downloaded files. It will integrate seamlessly with the Book Downloader module.

---

## Architecture

```
feature/reader/
├── presentation/
│   ├── ui/
│   │   ├── ReaderFragment.kt
│   │   ├── ReaderController.kt          # Handles UI rendering
│   │   ├── dialogs/
│   │   │   ├── BookmarkDialog.kt
│   │   │   ├── SettingsDialog.kt
│   │   │   └── SearchDialog.kt
│   │   └── adapters/
│   │       └── ChaptersAdapter.kt
│   └── viewmodel/
│       └── ReaderViewModel.kt
├── domain/
│   ├── model/
│   │   ├── BookPage.kt
│   │   ├── BookMetadata.kt
│   │   ├── ReadingProgress.kt
│   │   ├── Bookmark.kt
│   │   └── BookFormat.kt
│   ├── repository/
│   │   └── IBookReaderRepository.kt
│   └── usecase/
│       ├── LoadBookUseCase.kt
│       ├── UpdateProgressUseCase.kt
│       ├── AddBookmarkUseCase.kt
│       └── SearchInBookUseCase.kt
├── data/
│   ├── repository/
│   │   └── BookReaderRepositoryImpl.kt
│   ├── datasource/
│   │   ├── local/
│   │   │   ├── BookReaderLocalDataSource.kt
│   │   │   ├── ReadingProgressDao.kt
│   │   │   └── BookmarkDao.kt
│   │   └── remote/
│   │       └── BookReaderRemoteDataSource.kt
│   ├── model/
│   │   ├── BookPageEntity.kt
│   │   └── ReadingProgressEntity.kt
│   └── db/
│       ├── BookReaderDatabase.kt
│       └── dao/
│           ├── ReadingProgressDao.kt
│           └── BookmarkDao.kt
├── parser/
│   ├── BookParser.kt                   # Interface for parsers
│   ├── EpubParser.kt
│   ├── PdfParser.kt
│   ├── MobiParser.kt
│   ├── TextParser.kt
│   └── HtmlParser.kt
└── di/
    └── ReaderModule.kt
```

---

## Domain Models

### BookFormat.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.model

enum class BookFormat(val extension: String, val mimeType: String) {
    EPUB("epub", "application/epub+zip"),
    PDF("pdf", "application/pdf"),
    MOBI("mobi", "application/x-mobipocket-ebook"),
    AZW3("azw3", "application/vnd.amazon.ebook"),
    TXT("txt", "text/plain"),
    HTML("html", "text/html");

    companion object {
        fun fromExtension(ext: String): BookFormat? {
            return values().find { it.extension.equals(ext, ignoreCase = true) }
        }
    }
}
```

### BookPage.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.model

data class BookPage(
    val pageNumber: Int,
    val content: String,
    val title: String? = null,
    val chapterTitle: String? = null,
    val metadata: Map<String, String> = emptyMap()
)
```

### BookMetadata.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.model

data class BookMetadata(
    val title: String,
    val author: String? = null,
    val cover: String? = null,
    val format: BookFormat,
    val totalPages: Int,
    val language: String? = null,
    val publishDate: String? = null,
    val publisher: String? = null,
    val chapters: List<Chapter> = emptyList()
)

data class Chapter(
    val index: Int,
    val title: String,
    val startPage: Int,
    val endPage: Int
)
```

### ReadingProgress.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.model

data class ReadingProgress(
    val bookId: String,
    val currentPage: Int,
    val totalPages: Int,
    val readPercentage: Float,
    val lastReadTime: Long,
    val timeSpentMinutes: Int = 0
)
```

### Bookmark.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.model

data class Bookmark(
    val id: String,
    val bookId: String,
    val page: Int,
    val content: String,
    val note: String? = null,
    val timestamp: Long,
    val highlighted: Boolean = false
)
```

---

## Parser Interface

### BookParser.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.data.parser

import io.github.aloussase.booksdownloader.feature.reader.domain.model.BookMetadata
import io.github.aloussase.booksdownloader.feature.reader.domain.model.BookPage
import io.github.aloussase.booksdownloader.core.models.Result
import java.io.File

interface BookParser {
    suspend fun parse(file: File): Result<BookData>
    fun canHandle(format: String): Boolean
}

data class BookData(
    val metadata: BookMetadata,
    val pages: List<BookPage>
)
```

---

## Repository Interface

### IBookReaderRepository.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.repository

import io.github.aloussase.booksdownloader.core.models.Result
import io.github.aloussase.booksdownloader.feature.reader.domain.model.*

interface IBookReaderRepository {

    // Book loading and parsing
    suspend fun loadBook(filePath: String): Result<BookMetadata>
    suspend fun getPage(bookId: String, pageNumber: Int): Result<BookPage>
    suspend fun getPages(bookId: String, startPage: Int, endPage: Int): Result<List<BookPage>>

    // Reading progress
    suspend fun getReadingProgress(bookId: String): Result<ReadingProgress>
    suspend fun updateReadingProgress(progress: ReadingProgress): Result<Unit>

    // Bookmarks
    suspend fun addBookmark(bookmark: Bookmark): Result<Unit>
    suspend fun removeBookmark(bookmarkId: String): Result<Unit>
    suspend fun getBookmarks(bookId: String): Result<List<Bookmark>>

    // Search
    suspend fun searchInBook(bookId: String, query: String): Result<List<SearchResult>>

    // Settings
    suspend fun saveReaderSettings(settings: ReaderSettings): Result<Unit>
    suspend fun getReaderSettings(): Result<ReaderSettings>
}

data class SearchResult(
    val page: Int,
    val context: String,
    val highlightStart: Int,
    val highlightEnd: Int
)

data class ReaderSettings(
    val fontSize: Float = 16f,
    val lineHeight: Float = 1.5f,
    val fontFamily: String = "Serif",
    val isDarkMode: Boolean = false,
    val justifyText: Boolean = true,
    val continueReading: Boolean = true
)
```

---

## UseCase Examples

### LoadBookUseCase.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.usecase

import io.github.aloussase.booksdownloader.core.models.Result
import io.github.aloussase.booksdownloader.feature.reader.domain.model.BookMetadata
import io.github.aloussase.booksdownloader.feature.reader.domain.repository.IBookReaderRepository

class LoadBookUseCase(
    private val repository: IBookReaderRepository
) {
    suspend operator fun invoke(filePath: String): Result<BookMetadata> {
        return repository.loadBook(filePath)
    }
}
```

### UpdateProgressUseCase.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.domain.usecase

import io.github.aloussase.booksdownloader.core.models.Result
import io.github.aloussase.booksdownloader.feature.reader.domain.model.ReadingProgress
import io.github.aloussase.booksdownloader.feature.reader.domain.repository.IBookReaderRepository

class UpdateProgressUseCase(
    private val repository: IBookReaderRepository
) {
    suspend operator fun invoke(progress: ReadingProgress): Result<Unit> {
        return repository.updateReadingProgress(progress)
    }
}
```

---

## ViewModel

### ReaderViewModel.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.presentation.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.aloussase.booksdownloader.core.base.BaseViewModel
import io.github.aloussase.booksdownloader.core.models.DataState
import io.github.aloussase.booksdownloader.feature.reader.domain.model.BookMetadata
import io.github.aloussase.booksdownloader.feature.reader.domain.model.BookPage
import io.github.aloussase.booksdownloader.feature.reader.domain.model.ReadingProgress
import io.github.aloussase.booksdownloader.feature.reader.domain.usecase.LoadBookUseCase
import io.github.aloussase.booksdownloader.feature.reader.domain.usecase.UpdateProgressUseCase
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ReaderViewModel @Inject constructor(
    private val loadBookUseCase: LoadBookUseCase,
    private val updateProgressUseCase: UpdateProgressUseCase
) : BaseViewModel() {

    private val _bookMetadata = MutableLiveData<DataState<BookMetadata>>()
    val bookMetadata: LiveData<DataState<BookMetadata>> = _bookMetadata

    private val _currentPage = MutableLiveData<DataState<BookPage>>()
    val currentPage: LiveData<DataState<BookPage>> = _currentPage

    private val _readingProgress = MutableLiveData<ReadingProgress>()
    val readingProgress: LiveData<ReadingProgress> = _readingProgress

    fun loadBook(filePath: String) {
        viewModelScope.launch {
            _bookMetadata.value = DataState.Loading()
            val result = loadBookUseCase(filePath)
            _bookMetadata.value = when {
                result.isSuccess() -> DataState.Success(result.getDataOrNull()!!)
                else -> DataState.Error(result.getExceptionOrNull()?.message ?: "Unknown error")
            }
        }
    }

    fun updateProgress(progress: ReadingProgress) {
        viewModelScope.launch {
            _readingProgress.value = progress
            updateProgressUseCase(progress)
        }
    }
}
```

---

## DI Module

### ReaderModule.kt

```kotlin
package io.github.aloussase.booksdownloader.feature.reader.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import io.github.aloussase.booksdownloader.feature.reader.data.parser.BookParser
import io.github.aloussase.booksdownloader.feature.reader.data.parser.EpubParser
import io.github.aloussase.booksdownloader.feature.reader.data.repository.BookReaderRepositoryImpl
import io.github.aloussase.booksdownloader.feature.reader.domain.repository.IBookReaderRepository
import io.github.aloussase.booksdownloader.feature.reader.domain.usecase.LoadBookUseCase
import io.github.aloussase.booksdownloader.feature.reader.domain.usecase.UpdateProgressUseCase
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object ReaderModule {

    @Provides
    @Singleton
    fun provideBookReaderRepository(): IBookReaderRepository {
        return BookReaderRepositoryImpl()
    }

    @Provides
    fun provideLoadBookUseCase(
        repository: IBookReaderRepository
    ): LoadBookUseCase {
        return LoadBookUseCase(repository)
    }

    @Provides
    fun provideUpdateProgressUseCase(
        repository: IBookReaderRepository
    ): UpdateProgressUseCase {
        return UpdateProgressUseCase(repository)
    }

    @Provides
    @Singleton
    fun provideEpubParser(): BookParser {
        return EpubParser()
    }
}
```

---

## Dependencies to Add

Update `app/build.gradle.kts`:

```gradle
// EPUB Reader
implementation("nl.siegmann.epublib:epublib-core:3.1")

// PDF Reader
implementation("com.tom_roush:pdfbox-android:2.0.27.0")

// MOBI/AZW3 support
implementation("com.cospherestudio.mobi4j:mobi4j:1.1.0")

// Room Database
implementation("androidx.room:room-runtime:2.6.1")
kapt("androidx.room:room-compiler:2.6.1")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

// Better JSON parsing for metadata
implementation("com.google.code.gson:gson:2.10.1")
```

---

## Implementation Steps

### Step 1: Create directory structure

```bash
mkdir -p app/src/main/java/io/github/aloussase/booksdownloader/feature/reader/{presentation/{ui,viewmodel},domain/{repository,usecase,model},data/{repository,datasource,model,db,parser},di}
```

### Step 2: Create domain models (Week 1)
- BookFormat.kt
- BookPage.kt
- BookMetadata.kt
- ReadingProgress.kt
- Bookmark.kt

### Step 3: Create repository interface (Week 1)
- IBookReaderRepository.kt
- ReaderSettings model

### Step 4: Create parser interface (Week 1)
- BookParser.kt interface
- Parser factory

### Step 5: Create UI layer (Week 2)
- ReaderFragment.kt
- ReaderViewModel.kt
- Reader layouts

### Step 6: Create data layer (Week 2)
- BookReaderRepositoryImpl.kt
- BookReaderLocalDataSource.kt
- Room DAOs

### Step 7: Create parsers (Week 3)
- EpubParser.kt
- PdfParser.kt
- MobiParser.kt
- TextParser.kt

### Step 8: Integration & Testing (Week 4)
- Connect with Downloader module
- UI/Integration tests
- Performance optimization

---

## Testing Strategy

### Unit Tests
```kotlin
// ReaderViewModelTest.kt
class ReaderViewModelTest {
    // Test loadBook
    // Test updateProgress
    // Test error handling
}

// BookParserTest.kt
class BookParserTest {
    // Test EPUB parsing
    // Test PDF parsing
    // Test metadata extraction
}
```

### Integration Tests
```kotlin
// Reader + Downloader integration
// Database + Repository integration
// File I/O operations
```

---

## Performance Considerations

1. **Memory Management**
   - Load pages on-demand, not entire book
   - Cache current and adjacent pages only
   - Implement image scaling for PDFs

2. **Parsing Optimization**
   - Lazy-load metadata
   - Pre-cache chapter information
   - Use coroutines for background parsing

3. **Database**
   - Index frequently queried columns
   - Clean up old reading progress
   - Compress bookmark storage

---

## Next Features After Reader

Once reader is complete:
1. Add highlight/annotation support
2. Implement Text-to-Speech
3. Add dictionary/Wikipedia lookups
4. Implement sharing capabilities

Then proceed to Phase 3: Local Sync Module
