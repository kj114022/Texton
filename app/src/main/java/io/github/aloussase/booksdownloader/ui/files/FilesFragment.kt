package io.github.aloussase.booksdownloader.ui.files

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import io.github.aloussase.booksdownloader.databinding.FragmentFilesBinding
import java.io.File

class FilesFragment : Fragment() {

    private var _binding: FragmentFilesBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter: FilesAdapter

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            loadFiles()
        } else {
            Toast.makeText(context, "Permission needed to access files", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentFilesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = FilesAdapter { file ->
            openFile(file)
        }

        binding.rvFiles.layoutManager = LinearLayoutManager(context)
        binding.rvFiles.adapter = adapter

        checkPermissionAndLoadFiles()
    }

    private fun checkPermissionAndLoadFiles() {
         // for Android 10+ scoped storage we might list from MediaStore or just own directory
         // For now assuming we download to public Downloads, we might need READ_EXTERNAL_STORAGE on older androids
         // On Android 11+ managing external storage is harder. 
         // Let's stick to listing the Environment.DIRECTORY_DOWNLOADS if possible, or app specific if we saved there.
         // We saved to Environment.DIRECTORY_DOWNLOADS.
         
         if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.R) {
             if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                 loadFiles()
             } else {
                 requestPermissionLauncher.launch(Manifest.permission.READ_EXTERNAL_STORAGE)
             }
         } else {
             // Android 11+ we can read from Downloads usually without broad permission if we use Storage Access Framework or simple File API might work for "our" files.
             // We'll try loading directly.
             loadFiles()
         }
    }

    private fun loadFiles() {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (downloadsDir.exists()) {
            val files = downloadsDir.listFiles()?.filter { it.isFile }?.sortedByDescending { it.lastModified() } ?: emptyList()
            // Filter only likely book formats?
            val bookExtensions = listOf("pdf", "epub", "mobi", "azw3", "djvu", "fb2", "txt", "cbz", "cbr")
            val filteredFiles = files.filter { file ->
                 bookExtensions.any { ext -> file.name.lowercase().endsWith(ext) }
            }
            
            if (filteredFiles.isEmpty()) {
                binding.tvEmpty.visibility = View.VISIBLE
                binding.rvFiles.visibility = View.GONE
            } else {
                binding.tvEmpty.visibility = View.GONE
                binding.rvFiles.visibility = View.VISIBLE
                adapter.updateFiles(filteredFiles)
            }
        } else {
             binding.tvEmpty.visibility = View.VISIBLE
        }
    }

    private fun openFile(file: File) {
        try {
            val uri = FileProvider.getUriForFile(requireContext(), "io.github.aloussase.booksdownloader.fileprovider", file)
            val mimeType = getMimeType(file.path)
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Toast.makeText(context, "Cannot open file: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun getMimeType(url: String): String? {
        var type: String? = null
        val extension = MimeTypeMap.getFileExtensionFromUrl(url)
        if (extension != null) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
        }
        return type ?: "*/*"
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
