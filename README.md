# Diceshelf

A beautiful PDF reader app built with Flutter. Features smooth reading experience, annotations, bookmarks, and library management.

## Features

- **PDF Reading** - Smooth scroll and zoom with pdfrx
- **Themes** - Dark, Light, and Sepia modes (Everblush color palette)
- **Annotations** - Highlight text, add notes, and draw on pages
- **Bookmarks** - Save and quickly jump to important pages
- **Library Management** - Recent files, favorites, and collections
- **Multi-language** - English and Indonesian support
- **View Modes** - List, Grid, and Staggered layouts

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.4
- Dart SDK

### Installation

```bash
# Clone the repository
git clone https://github.com/Gylmynnn/diceshelf.git
cd diceshelf

# Get dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Generate App Icons

Place your icon images in `assets/icons/`:
- `app_icon.png` (1024x1024)
- `app_icon_foreground.png` (1024x1024 with padding for Android adaptive icon)

Then run:
```bash
flutter pub run flutter_launcher_icons
```

## Project Structure

```
lib/
├── main.dart
└── app/
    ├── core/
    │   ├── abstracts/      # Base classes
    │   ├── constants/      # Colors, strings
    │   ├── services/       # Storage, PDF, theme, localization
    │   └── themes/         # App themes
    ├── data/
    │   └── models/         # Hive models
    ├── modules/
    │   ├── splash/         # Splash screen
    │   ├── onboarding/     # Introduction screens
    │   ├── library/        # PDF library
    │   ├── pdf_viewer/     # PDF reader
    │   ├── collections/    # Folder organization
    │   ├── highlights/     # View all highlights
    │   └── settings/       # App settings
    └── routes/             # GetX routing
```

## Tech Stack

- **State Management** - GetX
- **PDF Rendering** - pdfrx
- **Local Storage** - Hive
- **Icons** - Iconsax
- **Fonts** - Inter (Google Fonts)

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## License

MIT License
