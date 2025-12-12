package io.github.aloussase.booksdownloader.data.source

import android.net.Uri
import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.domain.source.BookSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.jsoup.Jsoup
import org.jsoup.nodes.Element
import org.jsoup.nodes.TextNode
import java.net.URLEncoder
import javax.inject.Inject

class LibgenSource @Inject constructor() : BookSource {

    private val acceptableBookFormats = listOf("pdf", "epub", "azw3", "mobi")
    private val baseUrl = "https://libgen.rs"

    override suspend fun search(query: String): List<Book> = withContext(Dispatchers.IO) {
        val searchUrl = createSearchUrl(query)
        val books = mutableListOf<Book>()

        try {
            android.util.Log.d("LibgenSource", "Searching: $searchUrl")
            val doc = Jsoup.connect(searchUrl).get()
            val rows = doc.select("table.c > tbody > tr:not(:first-child)")
            android.util.Log.d("LibgenSource", "Found ${rows.size} rows")

            for (row in rows) {
                parseRow(row)?.let { 
                    books.add(it)
                    android.util.Log.d("LibgenSource", "Added book: ${it.title}")
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("LibgenSource", "Error searching", e)
            e.printStackTrace()
        }

        android.util.Log.d("LibgenSource", "Returning ${books.size} books")
        books
    }

    private fun parseRow(row: Element): Book? {
        try {
            val columns = row.select("td")
            if (columns.size < 9) return null

            val id = columns[0].text().toLongOrNull() ?: 0L
            
            val authors = columns[1].select("a").map { it.text() }
            
            val titleElement = columns[2].selectFirst("a[id]") ?: columns[2].selectFirst("a")
            val title = titleElement?.text() ?: return null
            
            // Libgen RS structure might differ slightly, but usually:
            // 0: ID, 1: Author, 2: Title, 3: Publisher, 4: Year, 5: Pages, 6: Language, 7: Size, 8: Extension
            
            val extension = columns[8].text().lowercase()
            if (extension !in acceptableBookFormats) return null

            val size = columns[7].text()

            // Mirror 1 is usually in column 9 (index 9, so 10th column)
            val mirrorsPageUrl = columns[9].selectFirst("a")?.attr("href") ?: return null
            
            // We need to resolve the download URL from the mirror page
            // For now, we'll store the mirror page as the details URL and resolve download later or lazily
            // But the current app expects a direct download URL or at least a page to scrape it from.
            // The original code scraped the mirror page immediately. Let's try to do that to maintain compatibility for now,
            // but ideally we should defer this.
            
            // For the sake of speed in search, we might want to skip scraping the download link immediately
            // BUT the current Book model requires a downloadUrl. 
            // Let's put the mirror page as the downloadUrl for now, and handle the actual extraction in the "Download" step or "Details" step.
            // Wait, the original code did: Jsoup.connect(mirrorsPageUrl).get() inside the loop. That's slow.
            // I will set the downloadUrl to the mirror page for now.
            
            val fullMirrorUrl = if (mirrorsPageUrl.startsWith("http")) mirrorsPageUrl else "$baseUrl/$mirrorsPageUrl"

            return Book(
                id = id,
                authors = authors,
                title = title,
                extension = extension,
                downloadUrl = Uri.parse(fullMirrorUrl),
                imageUrl = "", // We often get image from details page
                size = size,
                source = "Libgen",
                detailsUrl = fullMirrorUrl
            )
        } catch (e: Exception) {
            return null
        }
    }

    private fun createSearchUrl(query: String): String {
        return buildString {
            append("$baseUrl/search.php?req=")
            append(URLEncoder.encode(query, "UTF-8"))
            append("&res=100")
            append("&column=def")
            append("&sort=year")
            append("&sortmode=DESC")
        }
    }
}
