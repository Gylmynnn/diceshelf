import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../controllers/pdf_viewer_controller.dart';

class DrawingOverlay extends StatelessWidget {
  final PdfViewerController controller;

  const DrawingOverlay({super.key, required this.controller});

  /// Convert a screen-local position to page-relative normalized coordinates (0-1).
  /// Returns null if the position cannot be mapped to the current page.
  Offset? _screenToPageNormalized(Offset localPosition, BuildContext context) {
    final pdfController = controller.pdfViewerController;
    if (pdfController == null) return null;

    try {
      final layout = pdfController.layout;
      final pageIndex = controller.currentPage.value - 1;
      if (pageIndex < 0 || pageIndex >= layout.pageLayouts.length) return null;

      // Convert local position to global position
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;
      final globalPosition = renderBox.localToGlobal(localPosition);

      // Convert global screen position to document coordinates
      final docPosition = pdfController.globalToDocument(globalPosition);
      if (docPosition == null) return null;

      // Get the current page rect in document coordinates
      final pageRect = layout.pageLayouts[pageIndex];

      // Normalize relative to the page (0-1 range)
      final normalized = Offset(
        (docPosition.dx - pageRect.left) / pageRect.width,
        (docPosition.dy - pageRect.top) / pageRect.height,
      );

      return normalized;
    } catch (e) {
      return null;
    }
  }

  /// Convert page-relative normalized coordinates (0-1) back to screen-local position.
  /// Returns null if the position cannot be mapped.
  Offset? _pageNormalizedToScreen(Offset normalized, BuildContext context) {
    final pdfController = controller.pdfViewerController;
    if (pdfController == null) return null;

    try {
      final layout = pdfController.layout;
      final pageIndex = controller.currentPage.value - 1;
      if (pageIndex < 0 || pageIndex >= layout.pageLayouts.length) return null;

      // Get the current page rect in document coordinates
      final pageRect = layout.pageLayouts[pageIndex];

      // Convert from normalized (0-1) to document coordinates
      final docPosition = Offset(
        pageRect.left + normalized.dx * pageRect.width,
        pageRect.top + normalized.dy * pageRect.height,
      );

      // Convert document coordinates to global screen position
      final globalPosition = pdfController.documentToGlobal(docPosition);
      if (globalPosition == null) return null;

      // Convert global to local position within this widget
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;
      return renderBox.globalToLocal(globalPosition);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onPanStart: (details) {
          final normalized = _screenToPageNormalized(
            details.localPosition,
            context,
          );
          if (normalized != null) {
            controller.startStrokeNormalized(normalized);
          }
        },
        onPanUpdate: (details) {
          final normalized = _screenToPageNormalized(
            details.localPosition,
            context,
          );
          if (normalized != null) {
            controller.updateStrokeNormalized(normalized);
          }
        },
        onPanEnd: (details) {
          controller.endStroke(controller.currentPage.value - 1);
        },
        child: Obx(
          () => CustomPaint(
            painter: DrawingPainter(
              currentStroke: controller.currentStroke.toList(),
              screenPointConverter: (normalized) =>
                  _pageNormalizedToScreen(normalized, context),
              color: controller.annotationMode.value == AnnotationMode.eraser
                  ? EverblushColors.textMuted
                  : controller.selectedDrawingColor.value,
              strokeWidth: controller.strokeWidth.value,
              isEraser:
                  controller.annotationMode.value == AnnotationMode.eraser,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> currentStroke;
  final Offset? Function(Offset normalized) screenPointConverter;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingPainter({
    required this.currentStroke,
    required this.screenPointConverter,
    required this.color,
    required this.strokeWidth,
    required this.isEraser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentStroke.isEmpty) return;

    final paint = Paint()
      ..color = isEraser ? color.withValues(alpha: 0.3) : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Convert normalized page coordinates back to screen coordinates
    final screenPoints = <Offset>[];
    for (final p in currentStroke) {
      final screenPoint = screenPointConverter(p);
      if (screenPoint != null) {
        screenPoints.add(screenPoint);
      }
    }

    if (screenPoints.isEmpty) return;

    if (screenPoints.length == 1) {
      // Draw a single point as a circle
      canvas.drawCircle(
        screenPoints.first,
        strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    // Draw smooth path through all points
    final path = Path();
    path.moveTo(screenPoints.first.dx, screenPoints.first.dy);

    for (var i = 1; i < screenPoints.length - 1; i++) {
      final p0 = screenPoints[i];
      final p1 = screenPoints[i + 1];

      // Use quadratic bezier for smoother curves
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    // Draw the last point
    if (screenPoints.length > 1) {
      path.lineTo(screenPoints.last.dx, screenPoints.last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.currentStroke.length != currentStroke.length;
  }
}
