import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/constants/strings.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/thumbnail_queue_service.dart';
import '../../../data/models/pdf_document.dart';

/// Controller for the Library screen
class LibraryController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _pdfService = Get.find<PdfService>();
  final _thumbnailQueue = Get.find<ThumbnailQueueService>();

  final RxList<PdfDocument> documents = <PdfDocument>[].obs;
  final RxList<PdfDocument> recentDocuments = <PdfDocument>[].obs;
  final RxList<PdfDocument> favoriteDocuments = <PdfDocument>[].obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = false.obs;

  /// Current library view mode (list, grid, staggered)
  final Rx<LibraryViewMode> viewMode = LibraryViewMode.list.obs;

  @override
  void onInit() {
    super.onInit();
    _loadViewMode();
    loadDocuments();
  }

  /// Load saved view mode from storage
  void _loadViewMode() {
    final savedMode = _storageService.get<String>(AppStrings.viewModeKey);
    if (savedMode != null) {
      viewMode.value = LibraryViewMode.fromValue(savedMode);
    }
  }

  /// Cycle to next view mode
  void cycleViewMode() {
    viewMode.value = viewMode.value.next;
    _storageService.put(AppStrings.viewModeKey, viewMode.value.value);
  }

  /// Set specific view mode
  void setViewMode(LibraryViewMode mode) {
    viewMode.value = mode;
    _storageService.put(AppStrings.viewModeKey, mode.value);
  }

  /// Load all documents from storage
  void loadDocuments() {
    final allDocs = _storageService.documentsBox.values.toList();

    // Sort by last opened
    allDocs.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));

    // Single pass to categorize documents
    final recent = <PdfDocument>[];
    final favorites = <PdfDocument>[];

    for (var i = 0; i < allDocs.length; i++) {
      final doc = allDocs[i];
      if (i < 10) recent.add(doc);
      if (doc.isFavorite) favorites.add(doc);
    }

    documents.assignAll(allDocs);
    recentDocuments.assignAll(recent);
    favoriteDocuments.assignAll(favorites);
  }

  /// Open file picker and add PDF to library
  Future<void> pickAndAddPdf() async {
    isLoading.value = true;
    try {
      final file = await _pdfService.pickPdfFile();
      if (file != null) {
        // Copy to app storage
        final copiedFile = await _pdfService.copyToAppStorage(file);
        final fileSize = await copiedFile.length();

        final docId = const Uuid().v4();

        // Get page count
        final pageCount = await _pdfService.getPageCount(copiedFile.path);

        // Generate thumbnail
        final thumbnailPath = await _pdfService.generateThumbnail(
          copiedFile.path,
          docId,
        );

        final doc = PdfDocument(
          id: docId,
          title: p.basenameWithoutExtension(file.path),
          filePath: copiedFile.path,
          pageCount: pageCount,
          fileSize: fileSize,
          addedAt: DateTime.now(),
          lastOpenedAt: DateTime.now(),
          thumbnailPath: thumbnailPath,
        );

        await _storageService.documentsBox.put(doc.id, doc);

        // Targeted update instead of full reload
        _addDocumentToLists(doc);

        // Open the PDF
        Get.toNamed('/pdf-viewer', arguments: doc);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Add document to lists without full reload
  void _addDocumentToLists(PdfDocument doc) {
    documents.insert(0, doc);
    recentDocuments.insert(0, doc);
    if (recentDocuments.length > 10) {
      recentDocuments.removeLast();
    }
    if (doc.isFavorite) {
      favoriteDocuments.insert(0, doc);
    }
  }

  /// Open existing document
  void openDocument(PdfDocument doc) {
    // Get fresh document from storage to ensure we have latest lastPageIndex
    final freshDoc = _storageService.documentsBox.get(doc.id) ?? doc;

    // Update last opened time
    final updated = freshDoc.copyWith(lastOpenedAt: DateTime.now());
    _storageService.documentsBox.put(doc.id, updated);

    // Targeted update - move to front of lists
    _updateDocumentInLists(updated);

    Get.toNamed('/pdf-viewer', arguments: updated);
  }

  /// Update document in lists without full reload
  void _updateDocumentInLists(PdfDocument updated) {
    // Update in main list
    final docIndex = documents.indexWhere((d) => d.id == updated.id);
    if (docIndex != -1) {
      documents.removeAt(docIndex);
      documents.insert(0, updated);
    }

    // Update recent list
    recentDocuments.removeWhere((d) => d.id == updated.id);
    recentDocuments.insert(0, updated);
    if (recentDocuments.length > 10) {
      recentDocuments.removeLast();
    }

    // Update favorites if needed
    final favIndex = favoriteDocuments.indexWhere((d) => d.id == updated.id);
    if (updated.isFavorite) {
      if (favIndex != -1) {
        favoriteDocuments[favIndex] = updated;
      } else {
        favoriteDocuments.insert(0, updated);
      }
    } else if (favIndex != -1) {
      favoriteDocuments.removeAt(favIndex);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(PdfDocument doc) async {
    final updated = doc.copyWith(isFavorite: !doc.isFavorite);
    await _storageService.documentsBox.put(doc.id, updated);

    // Targeted update
    _updateDocumentInLists(updated);
  }

  /// Delete document from library
  Future<void> deleteDocument(PdfDocument doc) async {
    // Remove from lists first for instant UI feedback
    _removeDocumentFromLists(doc);

    // Then do async cleanup
    await Future.wait([
      _pdfService.deleteFromStorage(doc.filePath),
      _pdfService.deleteThumbnail(doc.id),
      _storageService.documentsBox.delete(doc.id),
    ]);

    // Batch delete associated annotations and bookmarks
    final highlightIds = _storageService.highlightsBox.values
        .where((h) => h.documentId == doc.id)
        .map((h) => h.id)
        .toList();
    await _storageService.highlightsBox.deleteAll(highlightIds);

    final bookmarkIds = _storageService.bookmarksBox.values
        .where((b) => b.documentId == doc.id)
        .map((b) => b.id)
        .toList();
    await _storageService.bookmarksBox.deleteAll(bookmarkIds);

    // Also delete drawings
    final drawingIds = _storageService.drawingsBox.values
        .where((d) => d.documentId == doc.id)
        .map((d) => d.id)
        .toList();
    await _storageService.drawingsBox.deleteAll(drawingIds);
  }

  /// Remove document from lists without storage operations
  void _removeDocumentFromLists(PdfDocument doc) {
    documents.removeWhere((d) => d.id == doc.id);
    recentDocuments.removeWhere((d) => d.id == doc.id);
    favoriteDocuments.removeWhere((d) => d.id == doc.id);
  }

  void setTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  /// Regenerate thumbnail for a document (if missing)
  /// Uses the priority queue to avoid UI blocking
  Future<void> regenerateThumbnail(PdfDocument doc, {int priority = 0}) async {
    if (doc.thumbnailPath != null) return;

    final thumbnailPath = await _thumbnailQueue.requestThumbnail(
      doc.filePath,
      doc.id,
      priority: priority,
    );

    if (thumbnailPath != null) {
      final updated = doc.copyWith(thumbnailPath: thumbnailPath);
      await _storageService.documentsBox.put(doc.id, updated);

      // Targeted update
      _updateDocumentInLists(updated);
    }
  }

  /// Queue thumbnail regeneration for all documents missing thumbnails
  /// Uses low priority so it doesn't interfere with user interactions
  Future<void> queueMissingThumbnails() async {
    for (final doc in documents) {
      if (doc.thumbnailPath == null) {
        // Don't await - let them process in background
        regenerateThumbnail(doc, priority: -1);
      }
    }
  }
}
