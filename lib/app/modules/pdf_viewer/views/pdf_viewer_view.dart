import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart' as pdf;

import '../../../core/constants/colors.dart';
import '../../../core/services/localization_service.dart';
import '../controllers/pdf_viewer_controller.dart';
import '../widgets/annotation_toolbar.dart';
import '../widgets/drawing_overlay.dart';
import '../widgets/page_indicator.dart';
import '../widgets/search_bar.dart';

class PdfViewerView extends GetView<PdfViewerController> {
  const PdfViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // PDF Viewer
            _buildPdfViewer(theme),
            // Drawing overlay - only show when in drawing/eraser mode
            Obx(() {
              if (controller.annotationMode.value == AnnotationMode.drawing ||
                  controller.annotationMode.value == AnnotationMode.eraser) {
                return DrawingOverlay(controller: controller);
              }
              return const SizedBox.shrink();
            }),

            // Page navigation buttons - positioned on sides, not blocking center
            // Combined Obx to reduce subscriptions
            Obx(() {
              final showToolbar = controller.showToolbar.value;
              final currentPage = controller.currentPage.value;
              if (!showToolbar) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                top: 100,
                bottom: 100,
                child: GestureDetector(
                  onTap: controller.previousPage,
                  child: Container(
                    width: 44,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: currentPage > 1
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: theme.colorScheme.onSurface,
                              size: 28,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            }),
            Obx(() {
              final showToolbar = controller.showToolbar.value;
              final currentPage = controller.currentPage.value;
              final totalPages = controller.totalPages.value;
              if (!showToolbar) return const SizedBox.shrink();
              return Positioned(
                right: 0,
                top: 100,
                bottom: 100,
                child: GestureDetector(
                  onTap: controller.nextPage,
                  child: Container(
                    width: 44,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: currentPage < totalPages
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: theme.colorScheme.onSurface,
                              size: 28,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            }),

            // Top app bar
            Obx(
              () => AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: controller.showToolbar.value ? 0 : -100,
                left: 0,
                right: 0,
                child: _buildAppBar(l10n, theme),
              ),
            ),

            // Bottom toolbar
            Obx(
              () => AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: controller.showToolbar.value ? 0 : -120,
                left: 0,
                right: 0,
                child: _buildBottomBar(l10n, theme),
              ),
            ),

            // Page indicator - hide when toolbar is hidden
            Obx(() {
              if (!controller.showToolbar.value) return const SizedBox.shrink();
              return Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: Center(child: PageIndicator(controller: controller)),
              );
            }),

            // Search bar
            Obx(
              () => controller.isSearching.value
                  ? PdfSearchBar(controller: controller)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(ThemeData theme) {
    return Obx(() {
      final isHighlightMode =
          controller.annotationMode.value == AnnotationMode.highlight;
      final isZoomLocked = controller.isZoomLocked.value;
      final isDrawingOrEraser =
          controller.annotationMode.value == AnnotationMode.drawing ||
          controller.annotationMode.value == AnnotationMode.eraser;

      return GestureDetector(
        // Disable tap interception in highlight mode so text selection works on mobile,
        // and in drawing/eraser mode so drawing gestures are not interfered with
        onTap: isHighlightMode || isDrawingOrEraser
            ? null
            : controller.toggleToolbar,
        child: pdf.PdfViewer.file(
          controller.pdfFile.path,
          controller: controller.pdfViewerController,
          params: pdf.PdfViewerParams(
            enableTextSelection: isHighlightMode,
            panEnabled: true,
            // Lock horizontal scroll when zoom is locked, allowing only vertical scrolling
            panAxis: isZoomLocked ? PanAxis.vertical : PanAxis.free,
            // Prevent zoom changes when zoom is locked
            scaleEnabled: !isZoomLocked,
            pageDropShadow: BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            onPageChanged: (page) => controller.onPageChanged(page ?? 1),
            loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            },
            onViewerReady: (document, viewerController) {
              controller.onViewerReady(document, viewerController);
            },
            // Handle text selection for highlighting
            onTextSelectionChange: isHighlightMode
                ? (selections) {
                    if (selections.isNotEmpty) {
                      // Show highlight button
                      _showHighlightDialog(selections.first);
                    }
                  }
                : null,
            pagePaintCallbacks: [
              // Paint search results - always add callback, check inside
              (canvas, pageRect, page) {
                controller.textSearcher?.pageTextMatchPaintCallback(
                  canvas,
                  pageRect,
                  page,
                );
              },
              // Paint highlights - using O(1) cache lookup
              (canvas, pageRect, page) {
                final pageHighlights = controller.getHighlightsForPage(
                  page.pageNumber - 1,
                );

                for (final highlight in pageHighlights) {
                  final paint = Paint()
                    ..color = highlight.color
                    ..style = PaintingStyle.fill;

                  for (final rect in highlight.rects) {
                    // Scale rect from normalized (0-1) to page coordinates
                    final scaledRect = Rect.fromLTRB(
                      pageRect.left + rect.left * pageRect.width,
                      pageRect.top + rect.top * pageRect.height,
                      pageRect.left + rect.right * pageRect.width,
                      pageRect.top + rect.bottom * pageRect.height,
                    );
                    canvas.drawRect(scaledRect, paint);
                  }
                }
              },
              // Paint drawings
              (canvas, pageRect, page) {
                final drawing = controller.getDrawingForPage(
                  page.pageNumber - 1,
                );
                if (drawing == null) return;

                for (final stroke in drawing.strokes) {
                  if (stroke.isEraser) continue;

                  final paint = Paint()
                    ..color = stroke.color
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = stroke.strokeWidth
                    ..strokeCap = StrokeCap.round
                    ..strokeJoin = StrokeJoin.round;

                  final points = stroke.points;
                  if (points.isEmpty) continue;

                  if (points.length == 1) {
                    // Draw a single point as a circle
                    final p = Offset(
                      pageRect.left + points.first.dx * pageRect.width,
                      pageRect.top + points.first.dy * pageRect.height,
                    );
                    canvas.drawCircle(
                      p,
                      stroke.strokeWidth / 2,
                      paint..style = PaintingStyle.fill,
                    );
                  } else {
                    // Draw path
                    final path = Path();
                    final firstPoint = Offset(
                      pageRect.left + points.first.dx * pageRect.width,
                      pageRect.top + points.first.dy * pageRect.height,
                    );
                    path.moveTo(firstPoint.dx, firstPoint.dy);

                    for (var i = 1; i < points.length - 1; i++) {
                      final p0 = Offset(
                        pageRect.left + points[i].dx * pageRect.width,
                        pageRect.top + points[i].dy * pageRect.height,
                      );
                      final p1 = Offset(
                        pageRect.left + points[i + 1].dx * pageRect.width,
                        pageRect.top + points[i + 1].dy * pageRect.height,
                      );
                      final midPoint = Offset(
                        (p0.dx + p1.dx) / 2,
                        (p0.dy + p1.dy) / 2,
                      );
                      path.quadraticBezierTo(
                        p0.dx,
                        p0.dy,
                        midPoint.dx,
                        midPoint.dy,
                      );
                    }

                    if (points.length > 1) {
                      final lastPoint = Offset(
                        pageRect.left + points.last.dx * pageRect.width,
                        pageRect.top + points.last.dy * pageRect.height,
                      );
                      path.lineTo(lastPoint.dx, lastPoint.dy);
                    }

                    canvas.drawPath(path, paint);
                  }
                }
              },
            ],
          ),
        ),
      );
    });
  }

  void _showHighlightDialog(pdf.PdfTextRanges textRanges) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.tr('addHighlight'),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${textRanges.text}"',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tr('selectColor'),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EverblushColors.highlightColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    controller.setHighlightColor(color);
                  },
                  child: Obx(
                    () => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              controller.selectedHighlightColor.value == color
                              ? theme.colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
              controller.addHighlightFromSelection(textRanges);
              Get.back();
            },
            child: Text(
              l10n.tr('add'),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(LocalizationService l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Get.back(),
              color: theme.colorScheme.onSurface,
            ),
            Expanded(
              child: Text(
                controller.document.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            // Zoom lock button
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isZoomLocked.value
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: controller.isZoomLocked.value
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                onPressed: controller.toggleZoomLock,
                tooltip: l10n.tr('lockZoom'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => controller.isSearching.value = true,
              color: theme.colorScheme.onSurface,
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isFavorite.value
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: controller.isFavorite.value
                      ? EverblushColors.red
                      : theme.colorScheme.onSurface,
                ),
                onPressed: controller.toggleFavorite,
                tooltip: l10n.tr('favorite'),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(LocalizationService l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AnnotationToolbar(controller: controller),
    );
  }
}
