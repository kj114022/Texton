package io.github.aloussase.booksdownloader.data.source

import android.net.Uri
import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.domain.source.BookSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.jsoup.Jsoup
import java.net.URLEncoder
import javax.inject.Inject

class AnnasArchiveSource @Inject constructor() : BookSource {

    private val baseUrl = "https://annas-archive.org"

    override suspend fun search(query: String): List<Book> = withContext(Dispatchers.IO) {
        val searchUrl = "$baseUrl/search?q=${URLEncoder.encode(query, "UTF-8")}"
        val books = mutableListOf<Book>()

        try {
            android.util.Log.d("AnnasArchive", "Searching: $searchUrl")
            val doc = Jsoup.connect(searchUrl)
                .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                .timeout(15000)
                .get()
            
            // Anna's Archive uses links with /md5/ in the href
            val bookLinks = doc.select("a[href^='/md5/']")
            android.util.Log.d("AnnasArchive", "Found ${bookLinks.size} potential books")
            
            for (link in bookLinks.take(100)) {  // Limit to first 100
                try {
                    val href = link.attr("href")
                    val fullUrl = "$baseUrl$href"
                    
                    // Get the title from the link text or nearby elements
                    val title = link.text().trim()
                    if (title.isBlank() || title.length < 3) continue
                    
                    // Extract MD5 from href
                    val md5 = href.substringAfter("/md5/").substringBefore("/")
                    if (md5.isBlank()) continue
                    
                    // Try to find metadata near the link
                    val parent = link.parent() ?: continue
                    val metaText = parent.text().lowercase()
                    
                    // Detect format
                    val format = when {
                        metaText.contains("pdf") -> "pdf"
                        metaText.contains("epub") -> "epub"
                        metaText.contains("mobi") -> "mobi"
                        metaText.contains("azw3") -> "azw3"
                        else -> "pdf"  // Default to PDF
                    }
                    
                    // Extract size if available
                    val sizeRegex = Regex("""(\d+(?:\.\d+)?)\s*(MB|KB|GB)""", RegexOption.IGNORE_CASE)
                    val sizeMatch = sizeRegex.find(metaText)
                    val size = sizeMatch?.value ?: ""
                    
                    val book = Book(
                        id = md5.hashCode().toLong(),
                        authors = listOf("Unknown"),  // Can be enhanced
                        title = title,
                        extension = format,
                        downloadUrl = Uri.parse(fullUrl),
                        imageUrl = "",
                        size = size,
                        source = "Anna's Archive",
                        detailsUrl = fullUrl
                    )
                    
                    books.add(book)
                    android.util.Log.d("AnnasArchive", "Added: $title")
                } catch (e: Exception) {
                    // Skip this book if parsing fails
                    continue
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("AnnasArchive", "Error searching", e)
        }

        android.util.Log.d("AnnasArchive", "Returning ${books.size} books")
        books
    }
}
