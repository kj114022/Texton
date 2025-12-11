# Alexandria - Search Test & Debug Instructions

## ✅ Build & Installation Complete!

The app has been successfully rebuilt with:
- Java 17 support
- Added logging for debugging
- Updated search logic

## 🧪 How to Test Search Now

### Step 1: Perform a Search

In the emulator:
1. Open the Alexandria app (should already be open)
2. Tap the **search icon** (magnifying glass) in the top toolbar
3. Type: **"Harry Potter"**
4. Press **Enter** or tap search

### Step 2: Monitor the Logs

Open a new terminal and run:

```bash
cd /Users/tourist/code/alexandria-app
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb logcat | grep -E "BookSearchViewModel|LibgenSource|AnnasArchive|OceanOfPdf|BookSearchRepository"
```

This will show you in real-time:
- When the search starts
- Which sources are being queried
- How many results each source returns
- Any errors that occur

### Step 3: What to Look For

**Expected Log Output:**
```
BookSearchViewModel: onSearch called with query: Harry Potter
BookSearchViewModel: Starting repository search
LibgenSource: Searching: https://libgen.rs/search.php?req=Harry+Potter...
LibgenSource: Found X rows
LibgenSource: Added book: Harry Potter and the...
LibgenSource: Returning Y books
BookSearchViewModel: Got Z results
```

**If you see errors**, they will appear like:
```
LibgenSource: Error searching
```

## 🔍  Common Issues & Solutions

### Issue 1: No Logs Appear
**Problem**: Search isn't being triggered
**Solution**: Make sure you're pressing Enter after typing the search query

### Issue 2: "Found 0 rows"
**Problem**: The HTML structure of Libgen has changed
**Solution**: We'll need to update the scraper selectors

### Issue 3: Network errors
**Problem**: The emulator can't reach the book sources
**Solution**: 
```bash
# Test connectivity
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb shell ping -c 3 libgen.rs
```

### Issue 4: Results show but no books in UI
**Problem**: Filtering issue or ViewModel not updating UI
**Check**: Look for "updateFilteredBooks" in logs

## 📊 Quick Debug Commands

### Clear logs and restart monitoring:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb logcat -c
$ANDROID_HOME/platform-tools/adb logcat | grep -E "BookSearch|Libgen|Anna|Ocean"
```

### Check if app is running:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb shell ps | grep booksdownloader
```

### Restart the app:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb shell am force-stop io.github.aloussase.booksdownloader
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.ui.MainActivity
```

## 🎯 Next Steps

1. **Test the search** as described above
2. **Share the log output** if you encounter issues
3. If it works, try different search queries:
   - "The Lord of the Rings"
   - "1984"
   - "Programming"

Let me know what you see!
