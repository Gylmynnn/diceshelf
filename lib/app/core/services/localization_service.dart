import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/strings.dart';
import 'storage_service.dart';

/// Service to manage app localization
class LocalizationService extends GetxService {
  final Rx<Locale> _locale = const Locale('en').obs;
  final RxMap<String, dynamic> _translations = <String, dynamic>{}.obs;

  Locale get locale => _locale.value;

  /// Get translated string by key
  String tr(String key) {
    return _translations[key]?.toString() ?? key;
  }

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final storage = Get.find<StorageService>();
    final savedLang = storage.get<String>(AppStrings.languageKey) ?? 'en';
    await setLanguage(AppLanguage.fromCode(savedLang));
  }

  Future<void> setLanguage(AppLanguage language) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/l10n/${language.code}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations.assignAll(jsonMap);
      _locale.value = Locale(language.code);

      final storage = Get.find<StorageService>();
      await storage.put(AppStrings.languageKey, language.code);

      Get.updateLocale(Locale(language.code));
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }
}
