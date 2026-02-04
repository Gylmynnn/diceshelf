import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../controllers/pdf_viewer_controller.dart';

class DrawingOverlay extends StatelessWidget {
  final PdfViewerController controller;

  const DrawingOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewSize = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onPanStart: (details) {
              controller.startStroke(details.localPosition, viewSize);
            },
            onPanUpdate: (details) {
              controller.updateStroke(details.localPosition, viewSize);
            },
            onPanEnd: (details) {
              controller.endStroke(controller.currentPage.value - 1, viewSize);
            },
            child: Obx(
              () => CustomPaint(
                painter: DrawingPainter(
                  currentStroke: controller.currentStroke.toList(),
                  viewSize: viewSize,
                  color:
                      controller.annotationMode.value == AnnotationMode.eraser
                      ? EverblushColors.textMuted
                      : controller.selectedDrawingColor.value,
                  strokeWidth: controller.strokeWidth.value,
                  isEraser:
                      controller.annotationMode.value == AnnotationMode.eraser,
                ),
                size: Size.infinite,
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> currentStroke;
  final Size viewSize;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingPainter({
    required this.currentStroke,
    required this.viewSize,
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

    // Convert normalized coordinates back to screen coordinates
    final screenPoints = currentStroke
        .map((p) => Offset(p.dx * viewSize.width, p.dy * viewSize.height))
        .toList();

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
