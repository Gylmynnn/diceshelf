import 'package:get/get.dart';

import '../modules/collections/bindings/collections_binding.dart';
import '../modules/collections/views/collection_detail_view.dart';
import '../modules/collections/views/collections_view.dart';
import '../modules/highlights/bindings/highlights_binding.dart';
import '../modules/highlights/views/highlights_view.dart';
import '../modules/library/bindings/library_binding.dart';
import '../modules/library/views/library_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/pdf_viewer/bindings/pdf_viewer_binding.dart';
import '../modules/pdf_viewer/views/pdf_viewer_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LIBRARY,
      page: () => const LibraryView(),
      binding: LibraryBinding(),
    ),
    GetPage(
      name: _Paths.PDF_VIEWER,
      page: () => const PdfViewerView(),
      binding: PdfViewerBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.HIGHLIGHTS,
      page: () => const HighlightsView(),
      binding: HighlightsBinding(),
    ),
    GetPage(
      name: _Paths.COLLECTIONS,
      page: () => const CollectionsView(),
      binding: CollectionsBinding(),
    ),
    GetPage(
      name: _Paths.COLLECTION_DETAIL,
      page: () => const CollectionDetailView(),
      binding: CollectionsBinding(),
    ),
  ];
}
