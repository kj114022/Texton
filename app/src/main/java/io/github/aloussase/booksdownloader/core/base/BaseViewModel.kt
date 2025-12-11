package io.github.aloussase.booksdownloader.core.base

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlin.coroutines.CoroutineContext

/**
 * Base ViewModel class with coroutine support
 * Provides common functionality for all ViewModels
 */
abstract class BaseViewModel : ViewModel(), CoroutineScope {

    private val _job = Job()
    override val coroutineContext: CoroutineContext
        get() = _job + Dispatchers.Main

    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    private val _errorMessage = MutableLiveData<String>()
    val errorMessage: LiveData<String> = _errorMessage

    protected fun setLoading(isLoading: Boolean) {
        _isLoading.value = isLoading
    }

    protected fun setError(message: String) {
        _errorMessage.value = message
    }

    override fun onCleared() {
        super.onCleared()
        _job.cancel()
    }
}
