import 'dart:ui';

import 'package:hive/hive.dart';

import '../../core/abstracts/base_annotation.dart';

part 'drawing.g.dart';

/// Represents a single stroke in a drawing
@HiveType(typeId: 3)
class DrawingStroke {
  @HiveField(0)
  final List<double> pointsData;

  @HiveField(1)
  final int colorValue;

  @HiveField(2)
  final double strokeWidth;

  @HiveField(3)
  final bool isEraser;

  Color get color => Color(colorValue);

  /// Get points as Offset list
  List<Offset> get points {
    final List<Offset> result = [];
    for (int i = 0; i < pointsData.length; i += 2) {
      result.add(Offset(pointsData[i], pointsData[i + 1]));
    }
    return result;
  }

  DrawingStroke({
    required this.pointsData,
    required this.colorValue,
    required this.strokeWidth,
    this.isEraser = false,
  });

  factory DrawingStroke.fromPoints({
    required List<Offset> points,
    required Color color,
    required double strokeWidth,
    bool isEraser = false,
  }) {
    final pointsData = <double>[];
    for (final point in points) {
      pointsData.addAll([point.dx, point.dy]);
    }
    return DrawingStroke(
      pointsData: pointsData,
      colorValue: color.toARGB32(),
      strokeWidth: strokeWidth,
      isEraser: isEraser,
    );
  }
}

/// Represents a drawing annotation on a PDF page
@HiveType(typeId: 2)
class Drawing extends HiveObject implements BaseAnnotation {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String documentId;

  @override
  @HiveField(2)
  final int pageIndex;

  @override
  @HiveField(3)
  final DateTime createdAt;

  @override
  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final List<DrawingStroke> strokes;

  @override
  Color get color => Color(colorValue);

  @override
  AnnotationType get type => AnnotationType.drawing;

  Drawing({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.colorValue,
    required this.strokes,
  });

  factory Drawing.create({
    required String id,
    required String documentId,
    required int pageIndex,
    required Color color,
    List<DrawingStroke> strokes = const [],
  }) {
    final now = DateTime.now();
    return Drawing(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      createdAt: now,
      updatedAt: now,
      colorValue: color.toARGB32(),
      strokes: strokes,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'pageIndex': pageIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorValue': colorValue,
      'strokes': strokes.length,
    };
  }

  @override
  Drawing copyWith({
    Color? color,
    DateTime? updatedAt,
    List<DrawingStroke>? strokes,
  }) {
    return Drawing(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      colorValue: color?.toARGB32() ?? colorValue,
      strokes: strokes ?? this.strokes,
    );
  }

  Drawing addStroke(DrawingStroke stroke) {
    return copyWith(strokes: [...strokes, stroke]);
  }
}
