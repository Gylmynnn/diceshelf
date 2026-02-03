import 'package:flutter/material.dart';

/// Enum for annotation types
enum AnnotationType { highlight, note, drawing }

/// Abstract base class for PDF annotations
/// All annotation types must extend this class
abstract class BaseAnnotation {
  /// Unique identifier
  final String id;

  /// PDF document ID this annotation belongs to
  final String documentId;

  /// Page number (0-based index)
  final int pageIndex;

  /// When the annotation was created
  final DateTime createdAt;

  /// When the annotation was last modified
  final DateTime updatedAt;

  /// Color of the annotation
  final Color color;

  /// Type of annotation
  AnnotationType get type;

  const BaseAnnotation({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
  });

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson();

  /// Create a copy with updated fields
  BaseAnnotation copyWith({Color? color, DateTime? updatedAt});
}
