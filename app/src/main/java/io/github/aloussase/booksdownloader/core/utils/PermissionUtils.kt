package io.github.aloussase.booksdownloader.core.utils

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment

object PermissionUtils {

    /**
     * Check if a permission is granted
     */
    fun hasPermission(context: Context, permission: String): Boolean {
        return ContextCompat.checkSelfPermission(context, permission) ==
            PackageManager.PERMISSION_GRANTED
    }

    /**
     * Check if multiple permissions are granted
     */
    fun hasPermissions(context: Context, permissions: Array<String>): Boolean {
        return permissions.all { hasPermission(context, it) }
    }

    /**
     * Request permissions from fragment
     */
    fun requestPermissions(
        fragment: Fragment,
        permissions: Array<String>,
        requestCode: Int
    ) {
        fragment.requestPermissions(permissions, requestCode)
    }

    /**
     * Check if should show permission rationale
     */
    fun shouldShowRationale(fragment: Fragment, permission: String): Boolean {
        return fragment.shouldShowRequestPermissionRationale(permission)
    }
}
