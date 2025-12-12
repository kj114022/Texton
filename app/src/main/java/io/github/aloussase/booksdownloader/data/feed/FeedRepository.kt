package io.github.aloussase.booksdownloader.data.feed

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

interface FeedRepository {
    fun getFeed(): Flow<List<FeedPost>>
    suspend fun addPost(post: FeedPost)
}

@Singleton
class FeedRepositoryImpl @Inject constructor() : FeedRepository {

    private val _feed = MutableStateFlow<List<FeedPost>>(emptyList())
    
    init {
        // Mock Initial Data - VC Comparison Ready
        _feed.value = listOf(
            FeedPost(
                "1", "Sarah Engineering", "@sarah_code", 
                "🚀 Just dropped the new performant text rendering engine. Switched from canvas to native views. 60fps stable.", 
                System.currentTimeMillis() - 1000 * 60 * 15,
                FileAttachment("TextonEngine_v2.zip", "45 MB", FileType.ZIP),
                842, 120, 56
            ),
            FeedPost(
                "2", "David Design", "@dave_ui", 
                "The new glassmorphism UI kit is ready. PDF specs attached for the frontend team. #ui #design", 
                System.currentTimeMillis() - 1000 * 60 * 60,
                FileAttachment("UI_Specs_2025.pdf", "8.2 MB", FileType.PDF),
                256, 45, 12
            ),
            FeedPost(
                "3", "Open Source Bot", "@os_bot", 
                "New release of Linux Kernel 6.12 is out. Tarball available.", 
                System.currentTimeMillis() - 1000 * 60 * 120,
                FileAttachment("linux-6.12.tar.gz", "134 MB", FileType.CODE),
                1200, 300, 450
            ),
            FeedPost(
                "4", "Alex Finance", "@alex_fin", 
                "Quarterly projections look insane. We constitute 40% of the market share now. Report inside.", 
                System.currentTimeMillis() - 1000 * 60 * 240,
                FileAttachment("Q4_Report.pdf", "2.1 MB", FileType.PDF),
                89, 12, 5
            ),
            FeedPost(
                "5", "Dr. Emily", "@emily_research", 
                "My latest paper on quantum caching algorithms. It's a game changer for distributed systems.", 
                System.currentTimeMillis() - 1000 * 60 * 300,
                FileAttachment("Quantum_Caching.pdf", "1.5 MB", FileType.PDF),
                567, 89, 123
            ),
             FeedPost(
                "6", "Anon Leaker", "@leak_sys", 
                "Found this configuration file on a public bucket. Passwords are plaintext! 😱", 
                System.currentTimeMillis() - 1000 * 60 * 400,
                FileAttachment("config.env", "2 KB", FileType.TXT),
                22, 5, 1
            )
        )
    }

    override fun getFeed(): Flow<List<FeedPost>> = _feed.asStateFlow()

    override suspend fun addPost(post: FeedPost) {
        val currentList = _feed.value.toMutableList()
        currentList.add(0, post)
        _feed.value = currentList
    }
}
