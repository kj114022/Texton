package io.github.aloussase.booksdownloader.ui.feed

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.data.feed.FeedPost
import io.github.aloussase.booksdownloader.data.feed.FileType
import io.github.aloussase.booksdownloader.databinding.ItemFeedPostBinding
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class FeedAdapter : ListAdapter<FeedPost, FeedAdapter.FeedViewHolder>(DiffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): FeedViewHolder {
        return FeedViewHolder(
            ItemFeedPostBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        )
    }

    override fun onBindViewHolder(holder: FeedViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class FeedViewHolder(private val binding: ItemFeedPostBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(post: FeedPost) {
            binding.apply {
                tvAuthorName.text = post.authorName
                tvAuthorHandle.text = post.authorHandle
                tvContent.text = post.content
                tvTimestamp.text = getRelativeTime(post.timestamp)
                
                // Stats
                btnLike.text = post.likeCount.toString()
                btnReply.text = post.replyCount.toString()
                btnRepost.text = post.repostCount.toString()

                if (post.attachment != null) {
                    cardAttachment.isVisible = true
                    tvFileName.text = post.attachment.fileName
                    tvFileTypeSize.text = "${post.attachment.fileType} · ${post.attachment.fileSize}"
                    
                    val iconRes = when (post.attachment.fileType) {
                        FileType.PDF -> R.drawable.pdf_download_button
                        FileType.ZIP -> android.R.drawable.ic_menu_save // Placeholder for Zip
                        FileType.IMAGE -> android.R.drawable.ic_menu_gallery
                        FileType.CODE -> android.R.drawable.ic_menu_view
                        else -> android.R.drawable.ic_menu_help
                    }
                    // Ideally use distinct icons, but falling back to available resources
                    ivFileIcon.setImageResource(iconRes)
                    
                } else {
                    cardAttachment.isVisible = false
                }
            }
        }

        private fun getRelativeTime(timestamp: Long): String {
            val now = System.currentTimeMillis()
            val diff = now - timestamp
            return when {
                diff < 60 * 1000 -> "${diff / 1000}s"
                diff < 60 * 60 * 1000 -> "${diff / (60 * 1000)}m"
                diff < 24 * 60 * 60 * 1000 -> "${diff / (60 * 60 * 1000)}h"
                else -> SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(timestamp))
            }
        }
    }

    companion object DiffCallback : DiffUtil.ItemCallback<FeedPost>() {
        override fun areItemsTheSame(oldItem: FeedPost, newItem: FeedPost) = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: FeedPost, newItem: FeedPost) = oldItem == newItem
    }
}
