import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/localization_service.dart';
import '../controllers/collections_controller.dart';

/// Dialog for creating or editing a collection
class CollectionFormDialog extends StatelessWidget {
  final String title;
  final VoidCallback onSave;

  const CollectionFormDialog({
    super.key,
    required this.title,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollectionsController>();
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: l10n.tr('collectionName'),
                  prefixIcon: const Icon(Iconsax.folder_2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.tr('collectionDescription'),
                  prefixIcon: const Icon(Iconsax.document_text),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Color picker
              Text(l10n.tr('selectColor'), style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: CollectionsController.availableColors.map((color) {
                    final isSelected = controller.selectedColor.value == color;
                    return GestureDetector(
                      onTap: () => controller.selectedColor.value = color,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Iconsax.tick_circle5,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Icon picker
              Text(l10n.tr('selectIcon'), style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CollectionsController.availableIcons.map((
                    iconName,
                  ) {
                    final isSelected =
                        controller.selectedIconName.value == iconName;
                    return GestureDetector(
                      onTap: () => controller.selectedIconName.value = iconName,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? controller.selectedColor.value.withValues(
                                  alpha: 0.2,
                                )
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: controller.selectedColor.value,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          size: 22,
                          color: isSelected
                              ? controller.selectedColor.value
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.tr('cancel')),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Iconsax.tick_circle, size: 20),
                    label: Text(l10n.tr('save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Iconsax.folder_2;
      case 'book':
        return Iconsax.book;
      case 'document':
        return Iconsax.document;
      case 'archive':
        return Iconsax.archive;
      case 'briefcase':
        return Iconsax.briefcase;
      case 'category':
        return Iconsax.category;
      case 'clipboard':
        return Iconsax.clipboard;
      case 'note':
        return Iconsax.note;
      case 'bookmark':
        return Iconsax.bookmark;
      case 'star':
        return Iconsax.star;
      case 'heart':
        return Iconsax.heart;
      case 'flag':
        return Iconsax.flag;
      case 'tag':
        return Iconsax.tag;
      case 'layer':
        return Iconsax.layer;
      case 'box':
        return Iconsax.box;
      default:
        return Iconsax.folder_2;
    }
  }
}
