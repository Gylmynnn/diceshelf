import 'package:get/get.dart';

import '../../../core/constants/strings.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/theme_service.dart';

class SettingsController extends GetxController {
  final _themeService = Get.find<ThemeService>();
  final _localizationService = Get.find<LocalizationService>();

  AppThemeMode get currentTheme => _themeService.themeMode;
  String get currentLanguageCode => _localizationService.locale.languageCode;

  void setTheme(AppThemeMode mode) {
    _themeService.setTheme(mode);
    update();
  }

  void setLanguage(AppLanguage language) {
    _localizationService.setLanguage(language);
    update();
  }
}
