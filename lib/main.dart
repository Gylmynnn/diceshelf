import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/core/constants/strings.dart';
import 'app/core/services/localization_service.dart';
import 'app/core/services/pdf_service.dart';
import 'app/core/services/storage_service.dart';
import 'app/core/services/theme_service.dart';
import 'app/core/services/thumbnail_queue_service.dart';
import 'app/core/themes/app_theme.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await _initServices();

  runApp(const DiceshelfApp());
}

Future<void> _initServices() async {
  // Storage service (must be first)
  final StorageService storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);

  // PDF service
  final PdfService pdfService = PdfService();
  await pdfService.init();
  Get.put<PdfService>(pdfService, permanent: true);

  // Theme service
  Get.put<ThemeService>(ThemeService(), permanent: true);

  // Thumbnail queue service (for priority-based thumbnail generation)
  Get.put<ThumbnailQueueService>(ThumbnailQueueService(), permanent: true);

  // Localization service
  final LocalizationService localizationService = LocalizationService();
  Get.put<LocalizationService>(localizationService, permanent: true);
}

class DiceshelfApp extends StatelessWidget {
  const DiceshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      init: Get.find<ThemeService>(),
      builder: (ThemeService themeService) {
        return GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(themeService.themeMode),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
