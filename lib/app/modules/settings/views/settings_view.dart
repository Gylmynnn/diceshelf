import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/strings.dart';
import '../../../core/services/localization_service.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(l10n.tr('settings'))),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<SettingsController>(
        builder: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: l10n.tr('theme'),
              theme: theme,
              child: Column(
                children: [
                  _buildThemeOption(
                    label: l10n.tr('darkMode'),
                    mode: AppThemeMode.dark,
                    icon: Iconsax.moon,
                    theme: theme,
                  ),
                  _buildThemeOption(
                    label: l10n.tr('lightMode'),
                    mode: AppThemeMode.light,
                    icon: Iconsax.sun_1,
                    theme: theme,
                  ),
                  _buildThemeOption(
                    label: l10n.tr('sepiaMode'),
                    mode: AppThemeMode.sepia,
                    icon: Iconsax.blend,
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: l10n.tr('language'),
              theme: theme,
              child: Column(
                children: AppLanguage.values.map((lang) {
                  return _buildLanguageOption(lang, theme);
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: l10n.tr('about'),
              theme: theme,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.book,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${l10n.tr('version')} ${AppStrings.appVersion}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildThemeOption({
    required String label,
    required AppThemeMode mode,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = controller.currentTheme == mode;

    return GestureDetector(
      onTap: () => controller.setTheme(mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle5, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(AppLanguage language, ThemeData theme) {
    final isSelected = controller.currentLanguageCode == language.code;

    return GestureDetector(
      onTap: () => controller.setLanguage(language),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.global,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle5, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
