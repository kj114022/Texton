# 🏛️ Texton Update Summary

## ✅ Renaming Complete
The application has been fully renamed from **Alexandria** to **Texton**.

### Changes Applied:
- **App Name**: displayed as "Texton" on the device.
- **Themes**: Updated to `Theme.Texton`.
- **Codebase**:
  - Renamed `AlexandriaApi` → `TextonApi`
  - Renamed `AlexandriaResult` → `TextonResult`
  - Updated `AppModule` and Repositories to use new classes.
- **Configuration**:
  - `settings.gradle.kts`: Root project is now "Texton".
  - `README.md`: Updated all text and links.
  - `fastlane`: Updated store listing title and description.
- **URLs**:
  - API Base URL: `https://pantheon.up.railway.app`
  - GitHub: `https://github.com/aloussase/pantheon-app`

## 🌐 Network & Search Status

### Network Access
- **Permissions**: `INTERNET` permission is active.
- **Cleartext Traffic**: Enabled (`usesCleartextTraffic="true"`), ensuring access to HTTP sites if needed.
- **Source URLs**: Updated to the latest working domains:
  - Libgen: `https://libgen.li`
  - Anna's Archive: `https://annas-archive.org`
  - OceanOfPdf: `https://oceanofpdf.com`

### Search Fix
- **Critical Fix Included**: The issue where the Search Screen and Main Activity were using different ViewModel instances has been resolved. They now share the same instance, ensuring search results are properly displayed.

## 🚀 How to Test

1. **Launch the App**: It should appear as "Texton" with the new name.
2. **Search**: Tap the search icon and enter a query (e.g., "Harry Potter").
3. **Verify**: Books should appear from the configured sources.

The app has been rebuilt and installed on the emulator.
