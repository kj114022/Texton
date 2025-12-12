package io.github.aloussase.booksdownloader.ui.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import androidx.appcompat.widget.SearchView
import androidx.core.view.isVisible
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import dagger.hilt.android.AndroidEntryPoint
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.adapters.BooksAdapter
import io.github.aloussase.booksdownloader.data.BookFormat
import io.github.aloussase.booksdownloader.databinding.FragmentHomeBinding
import io.github.aloussase.booksdownloader.viewmodels.BookSearchViewModel

@AndroidEntryPoint
class BookSearchFragment : BaseApplicationFragment(R.layout.fragment_home) {
    val TAG = "BookSearchFragment"

    private val booksAdapter = BooksAdapter()

    private val bookSearchViewModel by activityViewModels<BookSearchViewModel>()

    private lateinit var binding: FragmentHomeBinding
    private var searchView: SearchView? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        super.onCreateView(inflater, container, savedInstanceState)

        binding = FragmentHomeBinding.inflate(layoutInflater, container, false)

        setupRecyclerView()
        setupBookSearchObserver()
        setupFormatFilters()
        setupTrendingChips()

        booksAdapter.setOnItemDownloadListener { book ->
            setBookForDownload(book)
            downloadBook()
        }

        booksAdapter.setOnItemClickListener { book ->
            val action = BookSearchFragmentDirections.actionNavSearchToNavDetails(book)
            androidx.navigation.fragment.NavHostFragment.findNavController(this).navigate(action)
        }

        bookSearchViewModel.filteredBooks.observe(viewLifecycleOwner) {
            android.util.Log.d("BookSearchFragment", "Filtered books updated: ${it.size} books")
            booksAdapter.books = it
        }

        bookSearchViewModel.appliedFormatFilters.observe(viewLifecycleOwner) {
            binding.filterPdf.isChecked = it.contains(BookFormat.PDF)
            binding.filterEpub.isChecked = it.contains(BookFormat.EPUB)
            binding.filterAzw3.isChecked = it.contains(BookFormat.AZW3)
            binding.filterMobi.isChecked = it.contains(BookFormat.MOBI)
        }

        bookSearchViewModel.state.observe(viewLifecycleOwner) { state ->
            android.util.Log.d("BookSearchFragment", "State changed: $state")
        }

        return binding.root
    }

    private fun setupTrendingChips() {
        for (i in 0 until binding.chipGroupTrending.childCount) {
            val chip = binding.chipGroupTrending.getChildAt(i) as com.google.android.material.chip.Chip
            chip.setOnClickListener {
                val query = chip.tag.toString()
                // Update search view text if available
                searchView?.setQuery(query, false)
                searchView?.clearFocus()
                
                // Trigger search
                bookSearchViewModel.onEvent(BookSearchViewModel.Event.OnSearch(query))
            }
        }
    }

    override fun onResume() {
        super.onResume()
        askForNotificationPermissions()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setHasOptionsMenu(true)
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        super.onCreateOptionsMenu(menu, inflater)
        // Ensure filters are hidden if no books/initial state
        val filterItem = menu.findItem(R.id.action_filter)
        val booksEmpty = bookSearchViewModel.books.value?.isEmpty() ?: true
        filterItem?.isVisible = !booksEmpty

        // Capture SearchView
        val searchItem = menu.findItem(R.id.action_search)
        searchView = searchItem?.actionView as? SearchView
        
        searchView?.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                query?.let {
                    bookSearchViewModel.onEvent(BookSearchViewModel.Event.OnSearch(it))
                    searchView?.clearFocus()
                }
                return true
            }

            override fun onQueryTextChange(newText: String?): Boolean {
                return false
            }
        })
    }
    
    // Note: onPrepareOptionsMenu is deprecated but still useful for updates
    override fun onPrepareOptionsMenu(menu: Menu) {
        super.onPrepareOptionsMenu(menu)
        val booksEmpty = bookSearchViewModel.books.value?.isEmpty() ?: true
        menu.findItem(R.id.action_filter)?.isVisible = !booksEmpty
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_filter -> {
                binding.filters.isVisible = !binding.filters.isVisible
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupFormatFilters() {
        binding.filterPdf.setOnClickListener(createFilterClickListener(BookFormat.PDF))
        binding.filterEpub.setOnClickListener(createFilterClickListener(BookFormat.EPUB))
        binding.filterAzw3.setOnClickListener(createFilterClickListener(BookFormat.AZW3))
        binding.filterMobi.setOnClickListener(createFilterClickListener(BookFormat.MOBI))
    }

    private fun createFilterClickListener(format: BookFormat) = { view: View ->
        if ((view as CheckBox).isChecked) {
            bookSearchViewModel.onEvent(BookSearchViewModel.Event.OnApplyFilter(format))
        } else {
            bookSearchViewModel.onEvent(BookSearchViewModel.Event.OnRemoveFilter(format))
        }
    }

    private fun setupRecyclerView() {
            binding.rvBooks.apply {
            adapter = booksAdapter
            layoutManager = LinearLayoutManager(requireContext())
        }
    }

    private fun setupBookSearchObserver() {
        bookSearchViewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                is BookSearchViewModel.State.Idle -> {
                    binding.rvBooks.visibility = View.GONE
                    binding.llLoading.visibility = View.GONE
                    binding.tvGreeting.visibility = View.VISIBLE
                    binding.tvTrendingLabel.visibility = View.VISIBLE
                    binding.chipGroupTrending.visibility = View.VISIBLE
                    binding.tvError.visibility = View.GONE
                }

                is BookSearchViewModel.State.Loading -> {
                    binding.rvBooks.visibility = View.GONE
                    binding.llLoading.visibility = View.VISIBLE
                    binding.tvGreeting.visibility = View.GONE
                    binding.tvTrendingLabel.visibility = View.GONE
                    binding.chipGroupTrending.visibility = View.GONE
                    binding.tvError.visibility = View.GONE
                }

                is BookSearchViewModel.State.Loaded -> {
                    requireActivity().invalidateOptionsMenu()

                    binding.rvBooks.visibility = View.VISIBLE
                    binding.llLoading.visibility = View.GONE
                    binding.tvGreeting.visibility = View.GONE
                    binding.tvTrendingLabel.visibility = View.GONE
                    binding.chipGroupTrending.visibility = View.GONE
                    binding.tvError.visibility = View.GONE
                }

                is BookSearchViewModel.State.Error -> {
                    // Keep trending visible on error? Probably not.
                    binding.rvBooks.visibility = View.GONE
                    binding.tvGreeting.visibility = View.GONE
                    binding.tvTrendingLabel.visibility = View.GONE
                    binding.chipGroupTrending.visibility = View.GONE
                    binding.llLoading.visibility = View.GONE
                    binding.tvError.visibility = View.VISIBLE
                    binding.tvError.text = getString(R.string.error_fetching_books) 
                }
            }
        }
    }
}