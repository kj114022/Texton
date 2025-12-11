package io.github.aloussase.booksdownloader.core.models

/**
 * Sealed class representing the result of an operation
 * Can be Success, Error, or Loading
 */
sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val exception: Exception, val data: T? = null) : Result<T>()
    class Loading<T> : Result<T>()

    fun isSuccess(): Boolean = this is Success
    fun isError(): Boolean = this is Error
    fun isLoading(): Boolean = this is Loading

    fun getDataOrNull(): T? = when (this) {
        is Success -> data
        is Error -> data
        is Loading -> null
    }

    fun getExceptionOrNull(): Exception? = when (this) {
        is Error -> exception
        else -> null
    }
}
