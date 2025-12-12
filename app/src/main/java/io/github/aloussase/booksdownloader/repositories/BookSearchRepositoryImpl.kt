package io.github.aloussase.booksdownloader.repositories

import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.data.source.AnnasArchiveSource
import io.github.aloussase.booksdownloader.data.source.LibgenSource
import io.github.aloussase.booksdownloader.data.source.WebSearchSource
import io.github.aloussase.booksdownloader.domain.repository.BookSearchRepository
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import javax.inject.Inject

class BookSearchRepositoryImpl @Inject constructor(
    private val libgenSource: LibgenSource,
    private val annasArchiveSource: AnnasArchiveSource,
    private val webSearchSource: WebSearchSource
) : BookSearchRepository {

    override suspend fun search(query: String): List<Book> = coroutineScope {
        val deferreds = listOf(
            async { libgenSource.search(query) },
            async { annasArchiveSource.search(query) },
            async { webSearchSource.search(query) }
        )

        deferreds.awaitAll().flatten()
    }
}
