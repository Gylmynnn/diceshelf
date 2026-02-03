import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/constants/strings.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/pdf_document.dart';

/// Controller for the Library screen
class LibraryController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _pdfService = Get.find<PdfService>();

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
    documents.assignAll(allDocs);

    // Recent documents (last 10)
    recentDocuments.assignAll(allDocs.take(10));

    // Favorites
    favoriteDocuments.assignAll(allDocs.where((d) => d.isFavorite));
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
        loadDocuments();

        // Open the PDF
        Get.toNamed('/pdf-viewer', arguments: doc);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Open existing document
  void openDocument(PdfDocument doc) {
    // Update last opened time
    final updated = doc.copyWith(lastOpenedAt: DateTime.now());
    _storageService.documentsBox.put(doc.id, updated);
    loadDocuments();

    Get.toNamed('/pdf-viewer', arguments: updated);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(PdfDocument doc) async {
    final updated = doc.copyWith(isFavorite: !doc.isFavorite);
    await _storageService.documentsBox.put(doc.id, updated);
    loadDocuments();
  }

  /// Delete document from library
  Future<void> deleteDocument(PdfDocument doc) async {
    await _pdfService.deleteFromStorage(doc.filePath);
    await _pdfService.deleteThumbnail(doc.id);
    await _storageService.documentsBox.delete(doc.id);

    // Also delete associated annotations and bookmarks
    final highlights = _storageService.highlightsBox.values.where(
      (h) => h.documentId == doc.id,
    );
    for (final h in highlights) {
      await _storageService.highlightsBox.delete(h.id);
    }

    final bookmarks = _storageService.bookmarksBox.values.where(
      (b) => b.documentId == doc.id,
    );
    for (final b in bookmarks) {
      await _storageService.bookmarksBox.delete(b.id);
    }

    loadDocuments();
  }

  void setTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  /// Regenerate thumbnail for a document (if missing)
  Future<void> regenerateThumbnail(PdfDocument doc) async {
    if (doc.thumbnailPath != null) return;

    final thumbnailPath = await _pdfService.generateThumbnail(
      doc.filePath,
      doc.id,
    );

    if (thumbnailPath != null) {
      final updated = doc.copyWith(thumbnailPath: thumbnailPath);
      await _storageService.documentsBox.put(doc.id, updated);
      loadDocuments();
    }
  }
}
