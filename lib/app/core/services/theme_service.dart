import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/strings.dart';
import '../themes/app_theme.dart';
import 'storage_service.dart';

/// Service to manage app theme (dark/sepia modes)
class ThemeService extends GetxController {
  final Rx<AppThemeMode> _themeMode = AppThemeMode.dark.obs;

  AppThemeMode get themeMode => _themeMode.value;
  ThemeData get theme => AppTheme.getTheme(_themeMode.value);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final storage = Get.find<StorageService>();
    final savedTheme = storage.get<String>(AppStrings.themeKey);
    if (savedTheme != null) {
      _themeMode.value = AppThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => AppThemeMode.dark,
      );
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode.value = mode;
    final storage = Get.find<StorageService>();
    await storage.put(AppStrings.themeKey, mode.name);
    Get.changeTheme(AppTheme.getTheme(mode));
  }

  void toggleTheme() {
    if (_themeMode.value == AppThemeMode.dark) {
      setTheme(AppThemeMode.sepia);
    } else {
      setTheme(AppThemeMode.dark);
    }
  }
}
