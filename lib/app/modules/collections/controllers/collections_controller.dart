import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/collection.dart';
import '../../../data/models/pdf_document.dart';

class CollectionsController extends GetxController {
  final _storageService = Get.find<StorageService>();

  final collections = <Collection>[].obs;
  final isLoading = true.obs;

  // For creating/editing collection
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedColor = Rx<Color>(Colors.blue);
  final selectedIconName = 'folder'.obs;

  // Available colors for collections
  static const List<Color> availableColors = [
    Color(0xFF6B9FD4), // Blue
    Color(0xFFE57373), // Red
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFFFD54F), // Yellow
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFF06292), // Pink
  ];

  // Available icons for collections
  static const List<String> availableIcons = [
    'folder',
    'book',
    'document',
    'archive',
    'briefcase',
    'category',
    'clipboard',
    'note',
    'bookmark',
    'star',
    'heart',
    'flag',
    'tag',
    'layer',
    'box',
  ];

  @override
  void onInit() {
    super.onInit();
    loadCollections();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void loadCollections() {
    isLoading.value = true;
    final box = _storageService.collectionsBox;
    collections.value = box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    isLoading.value = false;
  }

  /// Create a new collection
  Future<Collection?> createCollection() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return null;

    final collection = Collection(
      id: const Uuid().v4(),
      name: name,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      colorValue: selectedColor.value.toARGB32(),
      iconName: selectedIconName.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.collectionsBox.put(collection.id, collection);
    loadCollections();
    _clearForm();
    return collection;
  }

  /// Update an existing collection
  Future<void> updateCollection(Collection collection) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final updated = collection.copyWith(
      name: name,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      colorValue: selectedColor.value.toARGB32(),
      iconName: selectedIconName.value,
      updatedAt: DateTime.now(),
    );

    await _storageService.collectionsBox.put(updated.id, updated);
    loadCollections();
    _clearForm();
  }

  /// Delete a collection
  Future<void> deleteCollection(Collection collection) async {
    // Remove collection reference from all documents
    final documentsBox = _storageService.documentsBox;
    for (final doc in documentsBox.values) {
      if (doc.collectionId == collection.id) {
        final updated = doc.copyWith(clearCollectionId: true);
        await documentsBox.put(doc.id, updated);
      }
    }

    await _storageService.collectionsBox.delete(collection.id);
    loadCollections();
  }

  /// Add a document to a collection
  Future<void> addDocumentToCollection(
    PdfDocument document,
    Collection collection,
  ) async {
    // Update document with collection ID
    final updatedDoc = document.copyWith(collectionId: collection.id);
    await _storageService.documentsBox.put(document.id, updatedDoc);

    // Update collection's document list
    final updatedCollection = collection.addDocument(document.id);
    await _storageService.collectionsBox.put(collection.id, updatedCollection);

    loadCollections();
  }

  /// Remove a document from its collection
  Future<void> removeDocumentFromCollection(PdfDocument document) async {
    if (document.collectionId == null) return;

    // Get the collection
    final collection = _storageService.collectionsBox.get(
      document.collectionId,
    );
    if (collection != null) {
      final updatedCollection = collection.removeDocument(document.id);
      await _storageService.collectionsBox.put(
        collection.id,
        updatedCollection,
      );
    }

    // Update document
    final updatedDoc = document.copyWith(clearCollectionId: true);
    await _storageService.documentsBox.put(document.id, updatedDoc);

    loadCollections();
  }

  /// Move document to another collection
  Future<void> moveDocumentToCollection(
    PdfDocument document,
    Collection? targetCollection,
  ) async {
    // Remove from current collection
    await removeDocumentFromCollection(document);

    // Add to new collection if specified
    if (targetCollection != null) {
      // Re-fetch the document after removal
      final doc = _storageService.documentsBox.get(document.id);
      if (doc != null) {
        await addDocumentToCollection(doc, targetCollection);
      }
    }
  }

  /// Get documents in a collection
  List<PdfDocument> getDocumentsInCollection(Collection collection) {
    return _storageService.documentsBox.values
        .where((doc) => doc.collectionId == collection.id)
        .toList()
      ..sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
  }

  /// Prepare form for editing
  void prepareForEdit(Collection collection) {
    nameController.text = collection.name;
    descriptionController.text = collection.description ?? '';
    selectedColor.value = Color(collection.colorValue);
    selectedIconName.value = collection.iconName;
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedColor.value = availableColors.first;
    selectedIconName.value = 'folder';
  }

  /// Reset form for new collection
  void prepareForCreate() {
    _clearForm();
  }

  /// Show collection picker dialog
  Future<Collection?> showCollectionPicker(BuildContext context) async {
    final l10n = Get.find<LocalizationService>();

    return showModalBottomSheet<Collection>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.tr('moveToCollection'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              // None option
              ListTile(
                leading: Icon(
                  Iconsax.close_circle,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(l10n.tr('removeFromCollection')),
                onTap: () => Navigator.pop(context, null),
              ),
              const Divider(height: 1),
              // Collections list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(
                            collection.colorValue,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getIconData(collection.iconName),
                          color: Color(collection.colorValue),
                        ),
                      ),
                      title: Text(collection.name),
                      subtitle: Text(
                        '${collection.documentCount} ${l10n.tr('documents')}',
                      ),
                      onTap: () => Navigator.pop(context, collection),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get IconData from icon name string
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Iconsax.folder_2;
      case 'book':
        return Iconsax.book;
      case 'document':
        return Iconsax.document;
      case 'archive':
        return Iconsax.archive;
      case 'briefcase':
        return Iconsax.briefcase;
      case 'category':
        return Iconsax.category;
      case 'clipboard':
        return Iconsax.clipboard;
      case 'note':
        return Iconsax.note;
      case 'bookmark':
        return Iconsax.bookmark;
      case 'star':
        return Iconsax.star;
      case 'heart':
        return Iconsax.heart;
      case 'flag':
        return Iconsax.flag;
      case 'tag':
        return Iconsax.tag;
      case 'layer':
        return Iconsax.layer;
      case 'box':
        return Iconsax.box;
      default:
        return Iconsax.folder_2;
    }
  }
}
