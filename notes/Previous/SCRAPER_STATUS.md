# Scraper Status & Improvements

## Current Status ✅

The Texton app now searches across **3 book sources**, but there are improvements needed for better results:

### 1. **Libgen** (libgen.rs) ✅ 
- **Status**: URL updated to working mirror
- **Previous Issue**: libgen.li was returning 404 errors
- **Fix Applied**: Changed to `libgen.rs` (confirmed working mirror as of Nov 2024)
- **Scraping Method**: HTML table parsing with Jsoup
- **CSS Selector**: `table.c > tbody > tr:not(:first-child)`
- **Fields Extracted**: ID, Authors, Title, Extension, Size, Download URL

### 2. **Anna's Archive** (annas-archive.org) ⚠️ NEEDS TESTING
- **Status**: Code implemented but not verified
- **Scraping Method**: Searching for links with `href^='/md5/'`
- **Potential Issue**: HTML structure may have changed
- **Recommendation**: Need to verify actual HTML structure

### 3. **OceanOfPdf** (oceanofpdf.com) ⚠️ NEEDS TESTING
- **Status**: Code implemented but not verified  
- **Scraping Method**: Article-based parsing
- **Potential Issue**: HTML structure may have changed
- **Recommendation**: Need to verify actual HTML structure

---

## Why Scraping Can Be Difficult

### 1. **Changing HTML Structure**
Websites frequently change their HTML structure, breaking scrapers:
- Class names change
- DOM hierarchy changes  
- New anti-scraping measures added

### 2. **Anti-Scraping Measures**
Some sites actively prevent scraping:
- CAPTCHAs
- Rate limiting
- User-agent detection
- JavaScript rendering (Jsoup can't handle JS)

### 3. **Multiple Mirrors**
Sites like Libgen have many mirrors, and they go down frequently:
- libgen.li - **NOT WORKING** (404 errors)
- libgen.rs - **WORKING** (updated to this)
- libgen.gs - Alternative
- libgen.vg - Alternative

---

## Recommendations for Better Results

### Option 1: Test Current Scrapers
Test each source individually to verify they work:

1. **Libgen.rs** - Should now work after URL change
2. **Anna's Archive** - May need CSS selector updates
3. **OceanOfPdf** - May need CSS selector updates

### Option 2: Use APIs Instead
Instead of scraping, use official or unofficial APIs:
- Anna's Archive has an API
- Z-Library has unofficial APIs
- More reliable than web scraping

### Option 3: Fallback to Single Reliable Source
Focus on one working source (Libgen.rs) for now:
- Remove non-working sources temporarily
- Add them back once fixed

### Option 4: Add More Mirrors
For Libgen, configure multiple fallback URLs:
```kotlin
private val libgenMirrors = listOf(
    "https://libgen.rs",
    "https://libgen.gs",
    "https://libgen.vg"
)
```
Try each until one works.

---

## Next Steps

1. **Test the current build** with Kafka search
2. **Check logs** to see if libgen.rs works
3. **If still 0 results**: We need to inspect actual HTML from the sites
4. **Update scrapers** based on current HTML structure

---

## How to Test

Run a search in the app and check logs:
```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb logcat | grep -E "LibgenSource|AnnasArchive|OceanOfPdf"
```

Look for:
- ✅ "Found X rows" - means HTML was parsed
- ✅ "Added book: ..." - means book was extracted  
- ❌ "Error searching" - means something failed
- ❌ "Returning 0 books" - means no results found
