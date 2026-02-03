import 'package:hive/hive.dart';

part 'pdf_document.g.dart';

/// PDF Document model for library management
@HiveType(typeId: 0)
class PdfDocument extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final int pageCount;

  @HiveField(4)
  final int fileSize;

  @HiveField(5)
  final DateTime addedAt;

  @HiveField(6)
  final DateTime lastOpenedAt;

  @HiveField(7)
  final int lastPageIndex;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final String? thumbnailPath;

  @HiveField(10)
  final String? collectionId;

  PdfDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.fileSize,
    required this.addedAt,
    required this.lastOpenedAt,
    this.lastPageIndex = 0,
    this.isFavorite = false,
    this.thumbnailPath,
    this.collectionId,
  });

  PdfDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    int? fileSize,
    DateTime? addedAt,
    DateTime? lastOpenedAt,
    int? lastPageIndex,
    bool? isFavorite,
    String? thumbnailPath,
    String? collectionId,
    bool clearCollectionId = false,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      collectionId: clearCollectionId
          ? null
          : (collectionId ?? this.collectionId),
    );
  }

  /// Format file size for display
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
