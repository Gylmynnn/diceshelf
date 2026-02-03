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
            // PDF Viewer - always show, let pdfrx handle its own loading
            _buildPdfViewer(theme),

            // Drawing overlay
            Obx(() {
              if (controller.annotationMode.value == AnnotationMode.drawing ||
                  controller.annotationMode.value == AnnotationMode.eraser) {
                return DrawingOverlay(controller: controller);
              }
              return const SizedBox.shrink();
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
                bottom: controller.showToolbar.value ? 0 : -100,
                left: 0,
                right: 0,
                child: _buildBottomBar(l10n, theme),
              ),
            ),

            // Page indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(child: PageIndicator(controller: controller)),
            ),

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
    return GestureDetector(
      onTap: controller.toggleToolbar,
      child: pdf.PdfViewer.file(
        controller.pdfFile.path,
        params: pdf.PdfViewerParams(
          enableTextSelection:
              controller.annotationMode.value == AnnotationMode.highlight,
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
          onDocumentChanged: (document) {
            if (document != null) {
              controller.onDocumentLoaded(
                controller.document,
                document.pages.length,
              );
            }
          },
          pagePaintCallbacks: [
            // Paint highlights
            (canvas, pageRect, page) {
              final pageHighlights = controller.highlights.where(
                (h) => h.pageIndex == page.pageNumber - 1,
              );

              for (final highlight in pageHighlights) {
                final paint = Paint()
                  ..color = highlight.color
                  ..style = PaintingStyle.fill;

                for (final rect in highlight.rects) {
                  // Scale rect to page coordinates
                  final scaledRect = Rect.fromLTRB(
                    rect.left * pageRect.width,
                    rect.top * pageRect.height,
                    rect.right * pageRect.width,
                    rect.bottom * pageRect.height,
                  );
                  canvas.drawRect(scaledRect, paint);
                }
              }
            },
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(LocalizationService l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
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
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => controller.isSearching.value = true,
              color: theme.colorScheme.onSurface,
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isPageBookmarked(controller.currentPage.value - 1)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color:
                      controller.isPageBookmarked(
                        controller.currentPage.value - 1,
                      )
                      ? EverblushColors.yellow
                      : theme.colorScheme.onSurface,
                ),
                onPressed: () =>
                    controller.toggleBookmark(controller.currentPage.value - 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(LocalizationService l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: AnnotationToolbar(controller: controller),
    );
  }
}
