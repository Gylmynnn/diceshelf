import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/localization_service.dart';
import '../controllers/pdf_viewer_controller.dart';

class AnnotationToolbar extends StatelessWidget {
  final PdfViewerController controller;

  const AnnotationToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.highlight_rounded,
            label: l10n.tr('highlight'),
            mode: AnnotationMode.highlight,
            color: EverblushColors.yellow,
            theme: theme,
          ),
          _buildToolButton(
            icon: Icons.edit_rounded,
            label: l10n.tr('pen'),
            mode: AnnotationMode.drawing,
            color: EverblushColors.cyan,
            theme: theme,
          ),
          _buildToolButton(
            icon: Icons.auto_fix_high_rounded,
            label: l10n.tr('eraser'),
            mode: AnnotationMode.eraser,
            color: EverblushColors.red,
            theme: theme,
          ),
          _buildColorPicker(theme),
          _buildClearButton(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required AnnotationMode mode,
    required Color color,
    required ThemeData theme,
  }) {
    return Obx(() {
      final isActive = controller.annotationMode.value == mode;
      return GestureDetector(
        onTap: () => controller.setAnnotationMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? color
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildColorPicker(ThemeData theme) {
    return Obx(() {
      final mode = controller.annotationMode.value;
      if (mode == AnnotationMode.none || mode == AnnotationMode.eraser) {
        return const SizedBox(width: 40);
      }

      return GestureDetector(
        onTap: () => _showColorPicker(theme),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: mode == AnnotationMode.highlight
                      ? controller.selectedHighlightColor.value
                      : controller.selectedDrawingColor.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildClearButton(LocalizationService l10n, ThemeData theme) {
    return Obx(() {
      final mode = controller.annotationMode.value;
      if (mode != AnnotationMode.drawing && mode != AnnotationMode.eraser) {
        return const SizedBox(width: 40);
      }

      return GestureDetector(
        onTap: () => _showClearConfirmation(l10n, theme),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: EverblushColors.red,
            size: 24,
          ),
        ),
      );
    });
  }

  void _showClearConfirmation(LocalizationService l10n, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.tr('clearDrawings'),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          l10n.tr('clearDrawingsConfirm'),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10n.tr('cancel'),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.clearDrawings(controller.currentPage.value - 1);
              Get.back();
            },
            child: Text(
              l10n.tr('clear'),
              style: const TextStyle(color: EverblushColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(ThemeData theme) {
    final mode = controller.annotationMode.value;
    final colors = mode == AnnotationMode.highlight
        ? EverblushColors.highlightColors
        : [
            EverblushColors.cyan,
            EverblushColors.green,
            EverblushColors.yellow,
            EverblushColors.orange,
            EverblushColors.red,
            EverblushColors.purple,
            EverblushColors.textPrimary,
          ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Get.find<LocalizationService>().tr('colors'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    if (mode == AnnotationMode.highlight) {
                      controller.setHighlightColor(color);
                    } else {
                      controller.setDrawingColor(color);
                    }
                    Get.back();
                  },
                  child: Obx(() {
                    final isSelected = mode == AnnotationMode.highlight
                        ? controller.selectedHighlightColor.value == color
                        : controller.selectedDrawingColor.value == color;
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: theme.scaffoldBackgroundColor,
                              size: 24,
                            )
                          : null,
                    );
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Stroke width slider for drawing mode
            if (mode == AnnotationMode.drawing) ...[
              Text(
                Get.find<LocalizationService>().tr('strokeWidth'),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Slider(
                  value: controller.strokeWidth.value,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  activeColor: controller.selectedDrawingColor.value,
                  inactiveColor: theme.scaffoldBackgroundColor,
                  label: controller.strokeWidth.value.round().toString(),
                  onChanged: (value) {
                    controller.strokeWidth.value = value;
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
