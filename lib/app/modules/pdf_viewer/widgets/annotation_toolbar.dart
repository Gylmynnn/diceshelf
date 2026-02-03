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
          ),
          _buildToolButton(
            icon: Icons.edit_rounded,
            label: l10n.tr('pen'),
            mode: AnnotationMode.drawing,
            color: EverblushColors.cyan,
          ),
          _buildToolButton(
            icon: Icons.auto_fix_high_rounded,
            label: l10n.tr('eraser'),
            mode: AnnotationMode.eraser,
            color: EverblushColors.textSecondary,
          ),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required AnnotationMode mode,
    required Color color,
  }) {
    return Obx(() {
      final isActive = controller.annotationMode.value == mode;
      return GestureDetector(
        onTap: () => controller.setAnnotationMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: isActive ? color : EverblushColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? color : EverblushColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildColorPicker() {
    return Obx(() {
      final mode = controller.annotationMode.value;
      if (mode == AnnotationMode.none || mode == AnnotationMode.eraser) {
        return const SizedBox(width: 48);
      }

      return GestureDetector(
        onTap: () => _showColorPicker(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: EverblushColors.surface,
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
                    color: EverblushColors.textPrimary,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: EverblushColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showColorPicker() {
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
          ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: EverblushColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Get.find<LocalizationService>().tr('colors'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: EverblushColors.textPrimary,
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
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: EverblushColors.textPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
