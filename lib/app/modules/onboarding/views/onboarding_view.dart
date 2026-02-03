import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/localization_service.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Obx(
                    () => Text(
                      l10n.tr('skip'),
                      style: TextStyle(
                        color: EverblushColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _buildPage(page, l10n, theme);
                },
              ),
            ),
            // Page indicator and buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.pages.length,
                        (index) => _buildIndicator(
                          index == controller.currentPage.value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next/Get Started button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: controller.nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: EverblushColors.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.currentPage.value ==
                                  controller.pages.length - 1
                              ? l10n.tr('getStarted')
                              : l10n.tr('next'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    OnboardingPage page,
    LocalizationService l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  EverblushColors.cyan.withValues(alpha: 0.2),
                  EverblushColors.purple.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              _getIcon(page.icon),
              size: 64,
              color: EverblushColors.cyan,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Obx(
            () => Text(
              l10n.tr(page.titleKey),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: EverblushColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Obx(
            () => Text(
              l10n.tr(page.descriptionKey),
              style: TextStyle(
                fontSize: 16,
                color: EverblushColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? EverblushColors.cyan : EverblushColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'book':
        return Iconsax.book;
      case 'edit':
        return Iconsax.edit_2;
      case 'folder':
        return Iconsax.folder_2;
      default:
        return Iconsax.book;
    }
  }
}
