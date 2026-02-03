import 'dart:ui';

import 'package:hive/hive.dart';

import '../../core/abstracts/base_annotation.dart';

part 'highlight.g.dart';

/// Represents a text highlight annotation
@HiveType(typeId: 1)
class Highlight extends HiveObject implements BaseAnnotation {
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

  /// Selected text content
  @HiveField(6)
  final String text;

  /// Text selection rects (serialized as List<double>: [left, top, right, bottom, ...])
  @HiveField(7)
  final List<double> rectsData;

  /// Optional note attached to this highlight
  @HiveField(8)
  final String? note;

  @override
  Color get color => Color(colorValue);

  @override
  AnnotationType get type => AnnotationType.highlight;

  /// Get the selection rects
  List<Rect> get rects {
    final List<Rect> result = [];
    for (int i = 0; i < rectsData.length; i += 4) {
      result.add(
        Rect.fromLTRB(
          rectsData[i],
          rectsData[i + 1],
          rectsData[i + 2],
          rectsData[i + 3],
        ),
      );
    }
    return result;
  }

  Highlight({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.colorValue,
    required this.text,
    required this.rectsData,
    this.note,
  });

  factory Highlight.create({
    required String id,
    required String documentId,
    required int pageIndex,
    required Color color,
    required String text,
    required List<Rect> rects,
    String? note,
  }) {
    final now = DateTime.now();
    final rectsData = <double>[];
    for (final rect in rects) {
      rectsData.addAll([rect.left, rect.top, rect.right, rect.bottom]);
    }
    return Highlight(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      createdAt: now,
      updatedAt: now,
      colorValue: color.toARGB32(),
      text: text,
      rectsData: rectsData,
      note: note,
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
      'text': text,
      'rectsData': rectsData,
      'note': note,
    };
  }

  @override
  Highlight copyWith({Color? color, DateTime? updatedAt, String? note}) {
    return Highlight(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      colorValue: color?.toARGB32() ?? colorValue,
      text: text,
      rectsData: rectsData,
      note: note ?? this.note,
    );
  }
}
