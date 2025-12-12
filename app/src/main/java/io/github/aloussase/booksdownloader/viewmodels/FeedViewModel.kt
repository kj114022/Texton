package io.github.aloussase.booksdownloader.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.aloussase.booksdownloader.data.feed.FeedPost
import io.github.aloussase.booksdownloader.data.feed.FeedRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FeedViewModel @Inject constructor(
    private val repository: FeedRepository
) : ViewModel() {

    val feed: StateFlow<List<FeedPost>> = repository.getFeed()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun addPost(post: FeedPost) {
        viewModelScope.launch {
            repository.addPost(post)
        }
    }
}
