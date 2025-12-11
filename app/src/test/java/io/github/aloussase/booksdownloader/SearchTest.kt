package io.github.aloussase.booksdownloader

import android.util.Log
import io.github.aloussase.booksdownloader.data.source.LibgenSource
import kotlinx.coroutines.runBlocking
import org.junit.Test

class SearchTest {
    
    @org.junit.Ignore("Requires network access")
    @Test
    fun testLibgenSearch() = runBlocking {
        io.mockk.mockkStatic(Log::class)
        io.mockk.every { Log.d(any(), any()) } returns 0
        io.mockk.every { Log.e(any(), any(), any()) } returns 0
        io.mockk.every { Log.e(any(), any()) } returns 0

        val libgen = LibgenSource()
        val results = libgen.search("Harry Potter")
        // Log calls are now mocked and won't crash
        results.forEach {
            // Log.d("SearchTest", "Book: ${it.title} from ${it.source}")
        }
        assert(results.isNotEmpty()) { "Expected some results but got none" }
    }
}
