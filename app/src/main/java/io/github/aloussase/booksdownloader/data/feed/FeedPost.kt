package io.github.aloussase.booksdownloader.data.feed

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class FeedPost(
    val id: String,
    val authorName: String,
    val authorHandle: String,
    val content: String,
    val timestamp: Long,
    val attachment: FileAttachment? = null,
    val likeCount: Int = 0,
    val replyCount: Int = 0,
    val repostCount: Int = 0
) : Parcelable

@Parcelize
data class FileAttachment(
    val fileName: String,
    val fileSize: String,
    val fileType: FileType
) : Parcelable

enum class FileType {
    PDF, IMAGE, CODE, ZIP, TXT, OTHER
}
