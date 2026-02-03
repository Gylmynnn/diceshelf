import 'package:hive/hive.dart';

part 'collection.g.dart';

/// Collection model for organizing PDF documents into folders
@HiveType(typeId: 5)
class Collection extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String iconName;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final List<String> documentIds;

  Collection({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    this.iconName = 'folder',
    required this.createdAt,
    required this.updatedAt,
    this.documentIds = const [],
  });

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? documentIds,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentIds: documentIds ?? List.from(this.documentIds),
    );
  }

  /// Get the number of documents in this collection
  int get documentCount => documentIds.length;

  /// Check if a document is in this collection
  bool containsDocument(String documentId) => documentIds.contains(documentId);

  /// Add a document to this collection
  Collection addDocument(String documentId) {
    if (containsDocument(documentId)) return this;
    return copyWith(
      documentIds: [...documentIds, documentId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a document from this collection
  Collection removeDocument(String documentId) {
    if (!containsDocument(documentId)) return this;
    return copyWith(
      documentIds: documentIds.where((id) => id != documentId).toList(),
      updatedAt: DateTime.now(),
    );
  }
}
