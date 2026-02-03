/// App-wide string constants
class AppStrings {
  AppStrings._();

  static const String appName = 'Diceshelf';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String viewModeKey = 'library_view_mode';
  static const String recentFilesKey = 'recent_files';
  static const String favoritesKey = 'favorites';
  static const String documentsBoxKey = 'documents';
  static const String annotationsBoxKey = 'annotations';
  static const String bookmarksBoxKey = 'bookmarks';
  static const String collectionsBoxKey = 'collections';
  static const String settingsBoxKey = 'settings';
}

/// Supported languages
enum AppLanguage {
  english('en', 'English'),
  indonesian('id', 'Bahasa Indonesia');

  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Theme modes available in the app
enum AppThemeMode { dark, sepia, light }

/// Library view modes
enum LibraryViewMode {
  list('list'),
  grid('grid'),
  staggered('staggered');

  final String value;

  const LibraryViewMode(this.value);

  static LibraryViewMode fromValue(String value) {
    return LibraryViewMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => LibraryViewMode.list,
    );
  }

  /// Get next view mode (for cycling)
  LibraryViewMode get next {
    final currentIndex = LibraryViewMode.values.indexOf(this);
    final nextIndex = (currentIndex + 1) % LibraryViewMode.values.length;
    return LibraryViewMode.values[nextIndex];
  }

  /// Get icon for this view mode
  String get iconName {
    switch (this) {
      case LibraryViewMode.list:
        return 'view_list';
      case LibraryViewMode.grid:
        return 'grid_view';
      case LibraryViewMode.staggered:
        return 'dashboard';
    }
  }
}
