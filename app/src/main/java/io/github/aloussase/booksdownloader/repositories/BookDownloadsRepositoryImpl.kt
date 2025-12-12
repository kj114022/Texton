package io.github.aloussase.booksdownloader.repositories

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.util.Log
import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.domain.repository.BookDownloadsRepository
import javax.inject.Inject

class BookDownloadsRepositoryImpl @Inject constructor(
    val context: Context
) : BookDownloadsRepository {

    companion object {
        const val TAG = "BookDownloadsRepository"
    }

    private val downloadManager by lazy {
        context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
    }

    override suspend fun download(book: Book, toUri: Uri) {
        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
            try {
                var downloadUrl = book.downloadUrl.toString()
                Log.d(TAG, "Resolving URL for ${book.source}: $downloadUrl")

                if (book.source == "Libgen" || downloadUrl.contains("library.lol")) {
                    downloadUrl = resolveLibgenUrl(downloadUrl) ?: downloadUrl
                } else if (book.source == "Anna's Archive" || downloadUrl.contains("annas-archive")) {
                    downloadUrl = resolveAnnasArchiveUrl(downloadUrl) ?: downloadUrl
                }

                Log.d(TAG, "Resolved URL: $downloadUrl")

                val fileName = toUri.lastPathSegment ?: "${book.title}.${book.extension}"
                val request = DownloadManager.Request(Uri.parse(downloadUrl)).apply {
                    setTitle(book.title)
                    setDescription("Downloading ${book.title}")
                    setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    setDestinationInExternalPublicDir(android.os.Environment.DIRECTORY_DOWNLOADS, fileName)
                    setAllowedOverMetered(true)
                    setAllowedOverRoaming(true)
                }

                Log.d(TAG, "Enqueueing download for: ${book.title}")
                downloadManager.enqueue(request)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to download book: ${e.message}", e)
            }
        }
    }

    private fun resolveLibgenUrl(url: String): String? {
        try {
            val doc = org.jsoup.Jsoup.connect(url)
                .userAgent("Mozilla/5.0")
                .timeout(15000)
                .get()
            // Usually the link with text "GET" or the first link in the #download div
            val link = doc.select("#download a").first()
            return link?.attr("href")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to resolve Libgen URL", e)
            return null
        }
    }

    private fun resolveAnnasArchiveUrl(url: String): String? {
        try {
            val doc = org.jsoup.Jsoup.connect(url)
                .userAgent("Mozilla/5.0")
                .timeout(15000)
                .get()
            
            // Anna's Archive has multiple mirrors.
            // Priority 1: library.lol (Libgen) - standard, usually works
            // Priority 2: "Slow Partner" links
            
            // Look for any link containing library.lol
            val libgenLink = doc.select("a[href*='library.lol']").first()?.attr("href")
            if (libgenLink != null) {
                // If we found a Libgen link, typically we need to scrape THAT page too.
                // Let's recursively resolve it as a Libgen URL.
                return resolveLibgenUrl(libgenLink)
            }

            // Fallback: Try to find "Slow Partner" links
            val partnerLink = doc.select("a:contains(Slow Partner Server)").first()?.attr("href")
            return partnerLink
        } catch (e: Exception) {
            Log.e(TAG, "Failed to resolve Anna's Archive URL", e)
            return null
        }
    }
}