import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/pdf_document.dart';

/// Grid card widget for displaying PDF document in grid/staggered view
class DocumentGridCard extends StatelessWidget {
  final PdfDocument document;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;
  final String? collectionName;

  /// Whether to use staggered (variable height) layout
  final bool isStaggered;

  const DocumentGridCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
    this.onLongPress,
    this.collectionName,
    this.isStaggered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // For staggered view, use Column with intrinsic height
    // For grid view, use fixed aspect ratio
    if (isStaggered) {
      return _buildStaggeredCard(theme, colorScheme);
    } else {
      return _buildGridCard(theme, colorScheme);
    }
  }

  /// Grid card dengan aspect ratio tetap untuk tampilan seragam
  Widget _buildGridCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area - takes most space with proper ratio
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnailContent(colorScheme, null),
                  // Favorite badge overlay
                  if (document.isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.heart5,
                          size: 14,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ),
                  // Collection badge overlay
                  if (document.collectionId != null && collectionName != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
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
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 60),
                              child: Text(
                                collectionName!,
                                style: theme.textTheme.labelSmall?.copyWith(
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
              ),
            ),
            // Document info - compact but readable
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    document.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // File info row with actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _buildSubtitle(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Compact action buttons
                      _buildCompactActions(colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Staggered card dengan height variabel
  Widget _buildStaggeredCard(ThemeData theme, ColorScheme colorScheme) {
    final double thumbnailHeight = _calculateStaggeredHeight();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail area with favorite badge
            Stack(
              children: [
                _buildThumbnailContent(colorScheme, thumbnailHeight),
                if (document.isFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.heart5,
                        size: 14,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ),
                // Collection badge overlay
                if (document.collectionId != null && collectionName != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 60),
                            child: Text(
                              collectionName!,
                              style: theme.textTheme.labelSmall?.copyWith(
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
            ),
            // Document info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    document.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // File size and page count
                  Text(
                    _buildSubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Text(
                        _formatDate(document.lastOpenedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: document.isFavorite
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            color: document.isFavorite
                                ? Colors.pinkAccent
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                            onTap: onFavorite,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Iconsax.trash,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(ColorScheme colorScheme, double? height) {
    if (document.thumbnailPath != null) {
      final file = File(document.thumbnailPath!);
      return Container(
        height: height,
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
        child: FutureBuilder<bool>(
          future: file.exists(),
          builder: (context, snapshot) {
            // Show shimmer while loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerPlaceholder(colorScheme, height);
            }
            if (snapshot.data == true) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return _buildShimmerPlaceholder(colorScheme, height);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(colorScheme, height);
                },
              );
            }
            return _buildPlaceholder(colorScheme, height);
          },
        ),
      );
    }

    return _buildPlaceholder(colorScheme, height);
  }

  Widget _buildShimmerPlaceholder(ColorScheme colorScheme, double? height) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: Container(
        height: height,
        color: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme, double? height) {
    return Container(
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
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Iconsax.document_text,
            size: height != null ? 40 : 32,
            color: colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActions(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onFavorite,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              document.isFavorite ? Iconsax.heart5 : Iconsax.heart,
              size: 16,
              color: document.isFavorite
                  ? Colors.pinkAccent
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Iconsax.trash,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[document.formattedFileSize];
    if (document.pageCount > 0) {
      parts.add('${document.pageCount} pages');
    }
    return parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Calculate variable height for staggered grid
  double _calculateStaggeredHeight() {
    final hash = document.id.hashCode;
    final heights = [140.0, 160.0, 180.0, 200.0];
    return heights[hash.abs() % heights.length];
  }
}
