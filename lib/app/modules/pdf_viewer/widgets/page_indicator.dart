import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/localization_service.dart';
import '../controllers/pdf_viewer_controller.dart';

class PageIndicator extends StatelessWidget {
  final PdfViewerController controller;

  const PageIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Obx(
      () => GestureDetector(
        onTap: () => _showGoToPageDialog(context, l10n, theme),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${l10n.tr('page')} ${controller.currentPage.value} ${l10n.tr('of')} ${controller.totalPages.value}',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showGoToPageDialog(
    BuildContext context,
    LocalizationService l10n,
    ThemeData theme,
  ) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.tr('goToPage'),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: l10n.tr('enterPageNumber'),
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.tr('cancel'),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(textController.text);
              if (page != null &&
                  page >= 1 &&
                  page <= controller.totalPages.value) {
                controller.goToPage(page - 1);
                Navigator.pop(context);
              } else {
                Get.snackbar(
                  'Error',
                  l10n.tr('invalidPageNumber'),
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text(
              l10n.tr('done'),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }
}
