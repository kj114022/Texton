package io.github.aloussase.booksdownloader.adapters

import android.content.Context
import android.content.res.Resources
import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.res.ResourcesCompat
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import io.github.aloussase.booksdownloader.GlideApp
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.data.Book
import io.github.aloussase.booksdownloader.data.BookFormat
import io.github.aloussase.booksdownloader.data.cover
import io.github.aloussase.booksdownloader.data.parse

class BooksAdapter : RecyclerView.Adapter<BooksAdapter.BooksViewHolder>() {

    inner class BooksViewHolder(itemView: View) : ViewHolder(itemView)


    private val diffCallback = object : DiffUtil.ItemCallback<Book>() {
        override fun areItemsTheSame(oldItem: Book, newItem: Book): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Book, newItem: Book): Boolean {
            return oldItem.hashCode() == newItem.hashCode()
        }
    }

    private val differ = AsyncListDiffer(this, diffCallback)

    var books: List<Book>
        get() = differ.currentList
        set(value) = differ.submitList(value)

    private lateinit var onItemDownloadListener: OnDownloadItemListener
    private var onItemClickListener: ((Book) -> Unit)? = null

    fun setOnItemDownloadListener(listener: OnDownloadItemListener) {
        onItemDownloadListener = listener
    }

    fun setOnItemClickListener(listener: (Book) -> Unit) {
        onItemClickListener = listener
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BooksViewHolder {
        return BooksViewHolder(
            LayoutInflater.from(parent.context).inflate(
                R.layout.books_list_item,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int {
        return books.size
    }

    override fun onBindViewHolder(holder: BooksViewHolder, position: Int) {
        val book = books[position]
        holder.itemView.apply {
            // Whole row clicks to download
            setOnClickListener { onItemDownloadListener(book) }

            val tvTitle = findViewById<TextView>(R.id.tvTitle)
            val sizeStr = if (book.size.isNotEmpty()) " (${book.size})" else ""
            val extStr = if (book.extension.isNotEmpty()) " [${book.extension.uppercase()}]" else ""
            tvTitle.text = "${book.title}$extStr$sizeStr"
        }
    }
}

typealias OnDownloadItemListener = (Book) -> Unit

private fun Book.getDrawable(resources: Resources, context: Context): Drawable {
    val id = when (BookFormat.parse(extension)) {
        BookFormat.PDF -> R.drawable.pdf_download_button
        BookFormat.EPUB -> R.drawable.epub_download_button
        BookFormat.AZW3 -> R.drawable.azw3_download_button
        BookFormat.MOBI -> R.drawable.mobi_download_button
    }
    return ResourcesCompat.getDrawable(
        resources,
        id,
        context.theme
    )!!
}