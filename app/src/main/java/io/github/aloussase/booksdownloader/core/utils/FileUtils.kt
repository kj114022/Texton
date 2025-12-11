package io.github.aloussase.booksdownloader.core.utils

import android.content.Context
import java.io.File
import java.text.DecimalFormat

object FileUtils {

    /**
     * Get cache directory for the app
     */
    fun getCacheDir(context: Context): File {
        val cacheDir = File(context.cacheDir, "pantheon_cache")
        if (!cacheDir.exists()) {
            cacheDir.mkdirs()
        }
        return cacheDir
    }

    /**
     * Get documents directory for the app
     */
    fun getDocumentsDir(context: Context): File {
        val docsDir = File(context.getExternalFilesDir(null), "documents")
        if (!docsDir.exists()) {
            docsDir.mkdirs()
        }
        return docsDir
    }

    /**
     * Format file size for display
     */
    fun formatFileSize(size: Long): String {
        if (size <= 0) return "0 B"
        val units = arrayOf("B", "KB", "MB", "GB")
        val digitGroups = (Math.log10(size.toDouble()) / Math.log10(1024.0)).toInt()
        return DecimalFormat("#,##0.#").format(
            size / Math.pow(1024.0, digitGroups.toDouble())
        ) + " " + units[digitGroups]
    }

    /**
     * Get file extension
     */
    fun getFileExtension(filename: String): String {
        return filename.substringAfterLast(".", "")
    }

    /**
     * Check if file exists
     */
    fun fileExists(path: String): Boolean = File(path).exists()

    /**
     * Delete file
     */
    fun deleteFile(file: File): Boolean = file.delete()

    /**
     * Delete directory recursively
     */
    fun deleteDir(dir: File): Boolean {
        if (dir.isDirectory) {
            val children = dir.listFiles()
            if (children != null) {
                for (child in children) {
                    deleteDir(child)
                }
            }
        }
        return dir.delete()
    }
}
