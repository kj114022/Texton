# Texton

A modern eBook downloader and converter app with a sleek Twitter/X-inspired UI, built with Flutter.

## Features

- **Search Books** - Search millions of books across Anna's Archive and Library Genesis
- **Multiple Formats** - Support for PDF, EPUB, MOBI, and AZW3
- **Format Filtering** - Filter search results by book format
- **Download Manager** - Track downloads with progress indicators
- **Format Conversion** - Convert between eBook formats
- **Library Management** - Manage your downloaded books
- **Dark Mode** - Beautiful Twitter/X-inspired dark theme
- **NSFW Filtering** - Optional content filtering

## Screenshots

The app features a modern, minimal design inspired by Twitter/X with:
- Pure black background
- Signature blue accent color (#1D9BF0)
- Cupertino (iOS-style) widgets
- Smooth animations and transitions

## Getting Started

### Prerequisites

- Flutter 3.10+ installed
- Android SDK for Android builds
- Xcode for iOS builds (macOS only)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kj114022/Texton.git
   cd Texton
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Build

Build for Android:
```bash
flutter build apk
```

Build for iOS:
```bash
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── theme/
│   │   └── app_theme.dart    # Colors and theme configuration
│   └── constants/
│       └── app_constants.dart # App-wide constants
├── data/
│   ├── models/               # Data models (Book, BookFormat, etc.)
│   └── sources/              # Book search sources (Anna's Archive, Libgen)
├── providers/                # Riverpod state management
├── router/
│   └── app_router.dart       # go_router navigation
├── screens/
│   ├── home/                 # Search and book list
│   ├── details/              # Book details view
│   ├── convert/              # Format converter
│   ├── downloads/            # Library/downloads manager
│   └── settings/             # App settings
└── widgets/                  # Shared widgets
```

## Technology Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **go_router** - Navigation and routing
- **Dio** - HTTP client for API calls
- **Cupertino Widgets** - iOS-style UI components
- **flutter_animate** - Smooth animations

## Design System

### Colors

| Color | Hex | Usage |
|-------|-----|-------|
| X Blue | `#1D9BF0` | Primary accent, links, buttons |
| Background | `#000000` | Main background |
| Surface | `#16181C` | Cards, nav bars |
| Text Primary | `#E7E9EA` | Main text |
| Text Secondary | `#71767B` | Muted text |
| Divider | `#2F3336` | Borders, separators |

### Typography

- System fonts (SF Pro on iOS, Roboto on Android)
- Large titles for navigation
- Clean, readable body text

## License

This project is available under multiple permissive licenses for maximum flexibility:

- **MIT License** (primary)
- **Apache 2.0**
- **BSD 3-Clause**
- **ISC License**

See the [LICENSE](./LICENSE) file for full details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## Acknowledgments

- Book data from Anna's Archive and Library Genesis
- UI inspiration from Twitter/X
- Built with Flutter and the amazing Dart ecosystem
