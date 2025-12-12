package io.github.aloussase.booksdownloader.ui.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.Menu
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import io.github.aloussase.booksdownloader.R
import io.github.aloussase.booksdownloader.databinding.FragmentMoreBinding

class MoreFragment : BaseApplicationFragment(R.layout.fragment_more) {
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val binding = FragmentMoreBinding.inflate(inflater, container, false)
        val prefs = requireContext().getSharedPreferences("app_settings", android.content.Context.MODE_PRIVATE)

        // Convert Navigation
        binding.cardConvert.setOnClickListener {
            findNavController().navigate(R.id.action_global_navConvert)
        }

        // About Navigation
        binding.tvAbout.setOnClickListener {
            findNavController().navigate(R.id.action_global_aboutFragment)
        }

        // NSFW Settings
        binding.switchNsfw.isChecked = prefs.getBoolean("nsfw_enabled", false)
        binding.switchNsfw.setOnCheckedChangeListener { _, isChecked ->
            prefs.edit().putBoolean("nsfw_enabled", isChecked).apply()
        }

        // Theme Settings
        binding.switchTheme.isChecked = prefs.getBoolean("dark_mode", false)
        binding.switchTheme.setOnCheckedChangeListener { _, isChecked ->
            prefs.edit().putBoolean("dark_mode", isChecked).apply()
            
            val mode = if (isChecked) {
                androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_YES
            } else {
                androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_NO
            }
            androidx.appcompat.app.AppCompatDelegate.setDefaultNightMode(mode)
        }

        return binding.root
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setHasOptionsMenu(false) // No menu in More
    }
}