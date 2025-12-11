package io.github.aloussase.booksdownloader.core.di

import android.content.Context
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import java.io.File
import javax.inject.Named
import javax.inject.Singleton

/**
 * Core dependency injection module
 * Provides common dependencies for all features
 */
@Module
@InstallIn(SingletonComponent::class)
object CoreModule {

    @Provides
    @Singleton
    @Named("cache_dir")
    fun provideCacheDir(@ApplicationContext context: Context): File {
        val cacheDir = File(context.cacheDir, "pantheon_cache")
        if (!cacheDir.exists()) {
            cacheDir.mkdirs()
        }
        return cacheDir
    }

    @Provides
    @Singleton
    @Named("documents_dir")
    fun provideDocumentsDir(@ApplicationContext context: Context): File {
        val docsDir = File(context.getExternalFilesDir(null), "documents")
        if (!docsDir.exists()) {
            docsDir.mkdirs()
        }
        return docsDir
    }
}
