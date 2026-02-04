import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/localization_service.dart';
import '../../../data/models/pdf_document.dart';

class DocumentCard extends StatelessWidget {
  final PdfDocument document;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback? onMoveToCollection;
  final String? collectionName;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
    this.onMoveToCollection,
    this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = Get.find<LocalizationService>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMoveToCollection != null
            ? () {
                HapticFeedback.mediumImpact();
                onMoveToCollection!();
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail or PDF Icon
              _buildThumbnail(colorScheme),
              const SizedBox(width: 16),
              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.document,
                          size: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          document.formattedFileSize,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (document.pageCount > 0) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            '${document.pageCount} pages',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(document.lastOpenedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        // Show collection badge if in collection
                        if (document.collectionId != null &&
                            collectionName != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.folder_2,
                                    size: 10,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      collectionName!,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 9,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions menu
              PopupMenuButton<String>(
                icon: Icon(
                  Iconsax.more,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'favorite':
                      onFavorite();
                      break;
                    case 'collection':
                      onMoveToCollection?.call();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          document.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                          size: 20,
                          color: document.isFavorite ? Colors.pinkAccent : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          document.isFavorite
                              ? l10n.tr('removeFromFavorites')
                              : l10n.tr('addToFavorites'),
                        ),
                      ],
                    ),
                  ),
                  if (onMoveToCollection != null)
                    PopupMenuItem(
                      value: 'collection',
                      child: Row(
                        children: [
                          Icon(Iconsax.folder_add, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            document.collectionId != null
                                ? l10n.tr('moveToCollection')
                                : l10n.tr('addToCollection'),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, size: 20, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text(
                          l10n.tr('delete'),
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    const double width = 56;
    const double height = 72;

    if (document.thumbnailPath != null) {
      final file = File(document.thumbnailPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover,
          cacheWidth: 112, // 2x for high DPI
          cacheHeight: 144,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(colorScheme, width, height);
          },
        ),
      );
    }

    return _buildPlaceholder(colorScheme, width, height);
  }

  Widget _buildPlaceholder(
    ColorScheme colorScheme,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Iconsax.document_text,
        color: colorScheme.primary.withValues(alpha: 0.7),
        size: 28,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
