package io.github.aloussase.booksdownloader.remote

data class PantheonPayload(
    val id: String,
    val path: String,
)

data class PantheonResult(
    val status: String,
    val data: PantheonPayload
)
