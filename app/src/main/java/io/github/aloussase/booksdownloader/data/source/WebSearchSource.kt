package io.github.aloussase.booksdownloader.data.source

import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.domain.source.BookSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.jsoup.Jsoup
import java.net.URLEncoder
import javax.inject.Inject
import kotlin.random.Random

class WebSearchSource @Inject constructor() : BookSource {

    // Simple user agent rotation to reduce blocking chance
    private val userAgents = listOf(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
    )

    override suspend fun search(query: String): List<Book> = withContext(Dispatchers.IO) {
        val books = mutableListOf<Book>()
        
        // We run these "sequentially" in this implementation block but could be parallel. 
        // Given we are inside a coroutine, let's just do them one by one to avoid triggering too many simultaneous requests if we were to parallelize aggressively.
        // Actually, let's parallelize them for speed.
        
        val ddgResults = searchDuckDuckGo(query)
        val googleResults = searchGoogle(query)
        val yandexResults = searchYandex(query)

        books.addAll(ddgResults)
        books.addAll(googleResults)
        books.addAll(yandexResults)

        books
    }

    private fun searchDuckDuckGo(query: String): List<Book> {
        val books = mutableListOf<Book>()
        try {
            // DuckDuckGo HTML version is easier to scrape
            val encodedQuery = URLEncoder.encode("$query filetype:pdf", "UTF-8")
            val url = "https://html.duckduckgo.com/html/?q=$encodedQuery"
            val doc = Jsoup.connect(url)
                .userAgent(userAgents.random())
                .timeout(10000)
                .get()

            // Select result links
            val links = doc.select(".result__a")
            for (link in links) {
                val title = link.text()
                val href = link.attr("href")
                
                // DDG redirect URLs
                val finalUrl = if (href.startsWith("//duckduckgo.com/l/")) {
                    // Try to parse out the 'uddg' param if possible, or just skip if complex.
                    // Actually Jsoup might follow redirects? No, this is an interstitial.
                    // Let's simplified assumption: assume href contains the target if we decode it, 
                    // or just look for the 'uddg=' parameter.
                    val uri = android.net.Uri.parse("https:$href")
                    uri.getQueryParameter("uddg") ?: href
                } else {
                    href
                }

                if (finalUrl.endsWith(".pdf", ignoreCase = true)) {
                    books.add(Book(
                        id = Random.nextLong(),
                        title = title,
                        authors = emptyList(), // Hard to scrape author from generic search result reliably
                        extension = "PDF",
                        size = "UNK", // Unknown
                        source = "DuckDuckGo",
                        downloadUrl = android.net.Uri.parse(finalUrl),
                        imageUrl = "",
                        detailsUrl = finalUrl
                    ))
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return books
    }

    private fun searchGoogle(query: String): List<Book> {
        val books = mutableListOf<Book>()
        try {
            val encodedQuery = URLEncoder.encode("$query filetype:pdf", "UTF-8")
            // Use Client parameter to sometimes get simpler HTML
            val url = "https://www.google.com/search?q=$encodedQuery&client=firefox-b-d"
            
            val doc = Jsoup.connect(url)
                .userAgent(userAgents.random())
                .timeout(10000)
                .get()

            // Standard Google results (often changable selectors, but h3 > parent > a is common)
            val links = doc.select("a[href]")
            for (link in links) {
                val href = link.attr("href")
                // Google usually has /url?q=...
                if (href.startsWith("/url?q=")) {
                    val targetUrl = href.substringAfter("/url?q=").substringBefore("&")
                    if (targetUrl.endsWith(".pdf", ignoreCase = true)) {
                        val title = link.select("h3").text().ifEmpty { 
                            link.text().ifEmpty { "PDF Document" } 
                        }
                        
                        books.add(Book(
                            id = Random.nextLong(),
                            title = title,
                            authors = emptyList(),
                            extension = "PDF",
                            size = "UNK",
                            source = "Google",
                            downloadUrl = android.net.Uri.parse(targetUrl),
                            imageUrl = "",
                            detailsUrl = targetUrl
                        ))
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return books
    }

    private fun searchYandex(query: String): List<Book> {
        // Yandex is notoriously hard to scrape without CAPTCHA. 
        // We will try a basic attempt.
        val books = mutableListOf<Book>()
        try {
            val encodedQuery = URLEncoder.encode("$query mime:pdf", "UTF-8")
            val url = "https://yandex.com/search/?text=$encodedQuery"
            
            val doc = Jsoup.connect(url)
                .userAgent(userAgents.random())
                .timeout(10000)
                .get()

            // Yandex selectors are obscure classes. We might just look for all A tags with .pdf hrefs.
            val links = doc.select("a[href]")
            for (link in links) {
                val href = link.attr("href")
                if (href.endsWith(".pdf", ignoreCase = true)) {
                    val title = link.text().ifEmpty { "PDF Document" }
                    books.add(Book(
                        id = Random.nextLong(),
                        title = title,
                        authors = emptyList(),
                        extension = "PDF",
                        size = "UNK",
                        source = "Yandex",
                        downloadUrl = android.net.Uri.parse(href),
                        imageUrl = "",
                        detailsUrl = href
                    ))
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return books
    }
}
