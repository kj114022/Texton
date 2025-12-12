package io.github.aloussase.booksdownloader.ui.fragments

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import dagger.hilt.android.AndroidEntryPoint
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.databinding.FragmentBookDetailsBinding
import io.github.aloussase.booksdownloader.GlideApp
import io.github.aloussase.booksdownloader.data.cover

@AndroidEntryPoint
class BookDetailsFragment : BaseApplicationFragment(R.layout.fragment_book_details) {

    private val args: BookDetailsFragmentArgs by navArgs()
    private lateinit var binding: FragmentBookDetailsBinding

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding = FragmentBookDetailsBinding.bind(view)

        val book = args.book

        binding.apply {
            tvTitle.text = book.title
            tvAuthor.text = book.authors.joinToString(", ")
            chipSource.text = book.source
            tvFormat.text = "Format: ${book.extension.uppercase()}"
            tvSize.text = "Size: ${book.size.ifEmpty { "Unknown" }}"
            
            GlideApp.with(this@BookDetailsFragment)
                .load(book.cover())
                .placeholder(R.drawable.cover)
                .error(R.drawable.cover)
                .into(ivBookCover)

            val filename = "${book.title}.${book.extension}"
            val file = java.io.File(
                android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DOWNLOADS),
                filename
            )

            if (file.exists()) {
                btnDownload.text = "Open"
                btnDownload.setOnClickListener {
                    openBook(file, book.extension)
                }
            } else {
                btnDownload.text = "Download"
                btnDownload.setOnClickListener {
                    setBookForDownload(book)
                    downloadBook()
                }
            }
        }
    }

    private fun openBook(file: java.io.File, extension: String) {
        try {
            val uri = androidx.core.content.FileProvider.getUriForFile(
                requireContext(),
                "${requireContext().packageName}.provider",
                file
            )
            val mimeType = when (extension.lowercase()) {
                "pdf" -> "application/pdf"
                "epub" -> "application/epub+zip"
                "mobi" -> "application/x-mobipocket-ebook"
                "azw3" -> "application/vnd.amazon.ebook" // fallback
                else -> "*/*"
            }
            
            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
            // Should show snackbar here ideally
        }
    }
}
