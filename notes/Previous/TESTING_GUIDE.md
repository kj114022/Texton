# Alexandria App - Testing Guide

## ✅ App is Running on Emulator!

The Alexandria app has been successfully installed and launched on the emulator **Medium_Phone_API_36.1**.

---

## 🧪 How to Test the New Features

### 1. **Test Multi-Source Search**
1. Open the app (should already be open)
2. Tap the **search icon** (magnifying glass) in the toolbar
3. Search for a book, for example: `"The Way of Kings"`
4. **Expected Result**: 
   - You should see results from multiple sources
   - Each book card will have a **colored chip** showing the source (Libgen, Anna's Archive, etc.)
   - The UI uses **Material 3 cards** with elevation and rounded corners

### 2. **Test Source Identification**
- **Look for the chips** on each book card
- Different sources should be clearly labeled:
  - "Libgen" 
  - "Anna's Archive"
  - "OceanOfPdf"
  - "Libgen (Legacy)" (if using the old service)

### 3. **Test Book Details Screen**
1. **Tap on any book card** (not the download button)
2. **Expected Result**:
   - You should navigate to a beautiful detail screen
   - See a large cover image with parallax scrolling
   - Book title, author, and source chip should be visible
   - Download button at the bottom

### 4. **Test Download Functionality**
1. Either from the search list or details screen
2. **Tap the Download button**
3. Grant storage permissions if requested
4. **Expected Result**: Download should start with a notification

### 5. **Test Filters**
1. After searching, tap the **filter icon** in the toolbar
2. **Toggle format filters** (PDF, EPUB, MOBI, AZW3)
3. **Expected Result**: Book list should update based on selected formats

---

## 📱 Emulator Commands (For Reference)

### View App Logs:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk && \
$ANDROID_HOME/platform-tools/adb logcat | grep -i alexandria
```

### Restart the App:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk && \
$ANDROID_HOME/platform-tools/adb shell am force-stop io.github.aloussase.booksdownloader && \
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.ui.MainActivity
```

### Take Screenshot:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk && \
$ANDROID_HOME/platform-tools/adb exec-out screencap -p > screenshot.png
```

---

## ⚠️ Known Considerations

1. **Internet Connection**: The emulator needs internet access to scrape book sources
2. **Source Availability**: Some sources (Libgen, Anna's Archive, OceanOfPdf) may be blocked in certain regions
3. **Scraping Robustness**: Web scraping can fail if the HTML structure of these sites changes
4. **Anti-Bot Protection**: Some sites may have anti-bot measures

---

## 🎯 What to Look For

### ✅ **Success Indicators:**
- App launches without crashes
- Search works and returns results
- Each book shows its source
- Clicking a book opens the details screen
- UI looks modern with cards and Material 3 design

### ❌ **Potential Issues:**
- **No results**: Sources might be down or blocked
- **Empty source chips**: Network issue or scraping failure
- **Crash on click**: Check logcat for errors

---

## 📊 Current Build Info
- **APK Location**: `app/build/outputs/apk/debug/app-debug.apk`
- **Package**: `io.github.aloussase.booksdownloader`
- **Emulator**: Medium_Phone_API_36.1 (emulator-5554)
- **Status**: ✅ Installed and Running

Enjoy testing the modernized Alexandria app! 📚
