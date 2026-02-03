part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LIBRARY = _Paths.LIBRARY;
  static const PDF_VIEWER = _Paths.PDF_VIEWER;
  static const SETTINGS = _Paths.SETTINGS;
  static const HIGHLIGHTS = _Paths.HIGHLIGHTS;
  static const COLLECTIONS = _Paths.COLLECTIONS;
  static const COLLECTION_DETAIL = _Paths.COLLECTION_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LIBRARY = '/library';
  static const PDF_VIEWER = '/pdf-viewer';
  static const SETTINGS = '/settings';
  static const HIGHLIGHTS = '/highlights';
  static const COLLECTIONS = '/collections';
  static const COLLECTION_DETAIL = '/collection/:id';
}
