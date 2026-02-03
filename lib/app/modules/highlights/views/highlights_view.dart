import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/localization_service.dart';
import '../../../data/models/highlight.dart';
import '../../library/widgets/empty_state.dart';
import '../controllers/highlights_controller.dart';

class HighlightsView extends GetView<HighlightsController> {
  const HighlightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();

    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(l10n.tr('highlights')))),
      body: Obx(() {
        if (controller.highlights.isEmpty) {
          return EmptyState(
            icon: Icons.highlight_rounded,
            title: l10n.tr('noHighlights'),
            description: l10n.tr('noHighlightsDescription'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.highlights.length,
          itemBuilder: (context, index) {
            final highlight = controller.highlights[index];
            return _buildHighlightCard(highlight, l10n);
          },
        );
      }),
    );
  }

  Widget _buildHighlightCard(Highlight highlight, LocalizationService l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.openDocument(highlight),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: highlight.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getDocumentTitle(highlight.documentId),
                          style: const TextStyle(
                            fontSize: 12,
                            color: EverblushColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.tr('page')} ${highlight.pageIndex + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: EverblushColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: EverblushColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteDialog(highlight, l10n),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: highlight.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  highlight.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: EverblushColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (highlight.note != null && highlight.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.note_rounded,
                      size: 14,
                      color: EverblushColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        highlight.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EverblushColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Highlight highlight, LocalizationService l10n) {
    Get.dialog(
      AlertDialog(
        title: Text(l10n.tr('deleteHighlight')),
        content: Text(
          highlight.text.length > 50
              ? '${highlight.text.substring(0, 50)}...'
              : highlight.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              controller.deleteHighlight(highlight);
              Get.back();
            },
            child: Text(
              l10n.tr('delete'),
              style: const TextStyle(color: EverblushColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
