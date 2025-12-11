package io.github.aloussase.booksdownloader.core.models

/**
 * Sealed class representing UI data state
 * Used for LiveData and StateFlow in ViewModels
 */
sealed class DataState<T> {
    data class Success<T>(val data: T) : DataState<T>()
    data class Error<T>(val message: String) : DataState<T>()
    class Loading<T> : DataState<T>()

    fun isSuccess(): Boolean = this is Success
    fun isError(): Boolean = this is Error
    fun isLoading(): Boolean = this is Loading

    fun getDataOrNull(): T? = when (this) {
        is Success -> data
        else -> null
    }

    fun getErrorOrNull(): String? = when (this) {
        is Error -> message
        else -> null
    }
}
