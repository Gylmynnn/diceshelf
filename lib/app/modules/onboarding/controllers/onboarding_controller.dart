import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';

class OnboardingController extends GetxController {
  static const String _onboardingKey = 'hasSeenOnboarding';

  final pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      icon: 'book',
      titleKey: 'onboardingTitle1',
      descriptionKey: 'onboardingDesc1',
    ),
    OnboardingPage(
      icon: 'edit',
      titleKey: 'onboardingTitle2',
      descriptionKey: 'onboardingDesc2',
    ),
    OnboardingPage(
      icon: 'folder',
      titleKey: 'onboardingTitle3',
      descriptionKey: 'onboardingDesc3',
    ),
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() async {
    final storageService = Get.find<StorageService>();
    await storageService.put(_onboardingKey, true);
    Get.offAllNamed('/library');
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }
}

class OnboardingPage {
  final String icon;
  final String titleKey;
  final String descriptionKey;

  OnboardingPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });
}
