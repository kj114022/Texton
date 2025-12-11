package io.github.aloussase.booksdownloader.viewmodels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.data.BookFormat
import io.github.aloussase.booksdownloader.domain.use_case.FilterBooksUseCase
import javax.inject.Inject
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

@HiltViewModel
class BookSearchViewModel @Inject constructor(
    val filterBooks: FilterBooksUseCase,
    val bookSearchRepository: io.github.aloussase.booksdownloader.domain.repository.BookSearchRepository
) : ViewModel() {

    init {
        // Simulate trending/popular books by searching for a broad term initially
        onSearch("bestsellers")
    }

    sealed class Event {
        data class OnApplyFilter(val format: BookFormat) : Event()
        data class OnRemoveFilter(val format: BookFormat) : Event()
        data class OnSearch(val query: String) : Event()
    }

    sealed class State {
        object Idle : State()
        object Loading : State()
        data class Error(val message: String) : State()
        data class Loaded(val books: List<Book>) : State()
    }

    private val _state = MutableLiveData<State>(State.Idle)
    val state: LiveData<State> get() = _state

    private val _appliedFormatFilters = MutableLiveData<Set<BookFormat>>(
        setOf(
            BookFormat.PDF,
            BookFormat.EPUB,
            BookFormat.AZW3,
            BookFormat.MOBI
        )
    )
    val appliedFormatFilters: LiveData<Set<BookFormat>> get() = _appliedFormatFilters

    private val _books = MutableLiveData<List<Book>>()
    val books: LiveData<List<Book>> get() = _books

    private val _filteredBooks = MutableLiveData<List<Book>>()
    val filteredBooks: LiveData<List<Book>> get() = _filteredBooks

    fun onEvent(evt: Event) {
        when (evt) {
            is Event.OnApplyFilter -> onApplyFilter(evt.format)
            is Event.OnRemoveFilter -> onRemoveFilter(evt.format)
            is Event.OnSearch -> onSearch(evt.query)
        }
    }

    private fun onSearch(query: String) {
        android.util.Log.d("BookSearchViewModel", "onSearch called with query: $query")
        _state.value = State.Loading
        viewModelScope.launch {
            try {
                android.util.Log.d("BookSearchViewModel", "Starting repository search")
                val results = bookSearchRepository.search(query)
                android.util.Log.d("BookSearchViewModel", "Got ${results.size} results")
                _books.value = results
                updateFilteredBooks()
                _state.value = State.Loaded(results)
            } catch (e: Exception) {
                android.util.Log.e("BookSearchViewModel", "Error during search", e)
                _state.value = State.Error(e.message ?: "Unknown error")
            }
        }
    }

    private fun onApplyFilter(format: BookFormat) {
        _appliedFormatFilters.value = _appliedFormatFilters.value?.plus(format)
        updateFilteredBooks()
    }

    private fun onRemoveFilter(format: BookFormat) {
        _appliedFormatFilters.value = _appliedFormatFilters.value?.minus(format)
        updateFilteredBooks()
    }

    private fun updateFilteredBooks() {
        _books.value?.let { books ->
            _appliedFormatFilters.value?.let { filters ->
                _filteredBooks.value = filterBooks.execute(books, filters)
            }
        }
    }
}