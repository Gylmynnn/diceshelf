import 'package:hive/hive.dart';

part 'bookmark.g.dart';

/// Represents a bookmarked page in a PDF
@HiveType(typeId: 4)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String documentId;

  @HiveField(2)
  final int pageIndex;

  @HiveField(3)
  final String? title;

  @HiveField(4)
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    this.title,
    required this.createdAt,
  });

  factory Bookmark.create({
    required String id,
    required String documentId,
    required int pageIndex,
    String? title,
  }) {
    return Bookmark(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      title: title,
      createdAt: DateTime.now(),
    );
  }

  Bookmark copyWith({String? title}) {
    return Bookmark(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      title: title ?? this.title,
      createdAt: createdAt,
    );
  }
}
