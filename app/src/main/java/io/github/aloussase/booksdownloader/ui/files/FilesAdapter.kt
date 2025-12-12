package io.github.aloussase.booksdownloader.ui.files

import android.text.format.Formatter
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import io.github.aloussase.booksdownloader.databinding.ItemFileBinding
import java.io.File
import java.util.Date

class FilesAdapter(
    private var files: List<File> = emptyList(),
    private val onFileClick: (File) -> Unit
) : RecyclerView.Adapter<FilesAdapter.FileViewHolder>() {

    class FileViewHolder(val binding: ItemFileBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): FileViewHolder {
        val binding = ItemFileBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return FileViewHolder(binding)
    }

    override fun onBindViewHolder(holder: FileViewHolder, position: Int) {
        val file = files[position]
        holder.binding.tvFileName.text = file.name
        
        val size = Formatter.formatFileSize(holder.itemView.context, file.length())
        // val date = Date(file.lastModified()).toString() // Simple date, maybe format better later
        holder.binding.tvFileSize.text = size

        holder.itemView.setOnClickListener { onFileClick(file) }
    }

    override fun getItemCount() = files.size

    fun updateFiles(newFiles: List<File>) {
        files = newFiles
        notifyDataSetChanged()
    }
}
