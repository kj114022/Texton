package io.github.aloussase.booksdownloader.ui.feed

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import dagger.hilt.android.AndroidEntryPoint
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.data.feed.FeedPost
import io.github.aloussase.booksdownloader.data.feed.FileAttachment
import io.github.aloussase.booksdownloader.data.feed.FileType
import io.github.aloussase.booksdownloader.databinding.FragmentFeedBinding
import io.github.aloussase.booksdownloader.viewmodels.FeedViewModel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.util.UUID
import kotlin.random.Random

@AndroidEntryPoint
class FeedFragment : Fragment(R.layout.fragment_feed) {

    private val viewModel by viewModels<FeedViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val binding = FragmentFeedBinding.bind(view)
        val adapter = FeedAdapter()

        binding.rvFeed.adapter = adapter

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.feed.collectLatest { posts ->
                adapter.submitList(posts)
            }
        }

        binding.fabAddPost.setOnClickListener {
            // Simulate adding a post (VC Demo Mode)
            val newPost = FeedPost(
                id = UUID.randomUUID().toString(),
                authorName = "You",
                authorHandle = "@investor_demo",
                content = "Just uploading my pitch deck. Check the growth stats! #seriesA #growth",
                timestamp = System.currentTimeMillis(),
                attachment = FileAttachment("Pitch_Deck_v3.pdf", "12 MB", FileType.PDF),
                likeCount = 0, replyCount = 0, repostCount = 0
            )
            viewModel.addPost(newPost)
            binding.rvFeed.smoothScrollToPosition(0)
            Toast.makeText(context, "Posted!", Toast.LENGTH_SHORT).show()
        }
    }
}
