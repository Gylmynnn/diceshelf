import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart' as pdf;
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/drawing.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/pdf_document.dart' as models;
import '../../library/controllers/library_controller.dart';

/// Annotation mode for the PDF viewer
enum AnnotationMode { none, highlight, drawing, eraser }

/// Controller for the PDF Viewer screen
class PdfViewerController extends GetxController {
  final _storageService = Get.find<StorageService>();

  late models.PdfDocument document;
  pdf.PdfViewerController? pdfViewerController;
  pdf.PdfDocument? pdfDocument;
  pdf.PdfTextSearcher? textSearcher;

  final Rx<AnnotationMode> annotationMode = AnnotationMode.none.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 0.obs;
  final RxDouble zoomLevel = 1.0.obs;
  final RxBool isLoading = true.obs;
  final RxBool showToolbar = true.obs;

  // Zoom lock feature
  final RxBool isZoomLocked = false.obs;
  final RxDouble lockedZoomLevel = 1.0.obs;

  // Highlights - with page index cache for O(1) lookup
  final RxList<Highlight> highlights = <Highlight>[].obs;
  final Map<int, List<Highlight>> _highlightsByPage = {};
  final Rx<Color> selectedHighlightColor =
      EverblushColors.highlightColors[0].obs;

  // Drawings - with page index cache for O(1) lookup
  final RxList<Drawing> drawings = <Drawing>[].obs;
  final Map<int, Drawing> _drawingsByPage = {};
  final Rx<Color> selectedDrawingColor = EverblushColors.cyan.obs;
  final RxDouble strokeWidth = 3.0.obs;
  final RxList<Offset> currentStroke = <Offset>[].obs;

  // Bookmarks
  final RxList<Bookmark> bookmarks = <Bookmark>[].obs;

  // Favorite
  final RxBool isFavorite = false.obs;

  // Search
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxInt searchResultCount = 0.obs;
  final RxInt currentSearchIndex = 0.obs;
  final RxBool isSearchInProgress = false.obs;

  // Jump to highlight from external navigation
  Highlight? _jumpToHighlight;

  // Debounce timer for saving page
  Timer? _savePageDebounce;

  @override
  void onInit() {
    super.onInit();

    // Handle both old and new argument formats
    final args = Get.arguments;
    if (args is models.PdfDocument) {
      document = args;
    } else if (args is Map<String, dynamic>) {
      document = args['document'] as models.PdfDocument;
      _jumpToHighlight = args['jumpToHighlight'] as Highlight?;
    }

    isFavorite.value = document.isFavorite;
    loadAnnotations();
  }

  @override
  void onClose() {
    // Cancel debounce timer
    _savePageDebounce?.cancel();

    // Remove listener before dispose
    textSearcher?.removeListener(_onSearchUpdate);
    textSearcher?.dispose();

    // Clear all lists to prevent memory leaks
    highlights.clear();
    drawings.clear();
    bookmarks.clear();
    currentStroke.clear();
    _highlightsByPage.clear();
    _drawingsByPage.clear();

    super.onClose();
  }

  void onViewerReady(pdf.PdfDocument doc, pdf.PdfViewerController controller) {
    pdfDocument = doc;
    pdfViewerController = controller;
    totalPages.value = doc.pages.length;
    isLoading.value = false;

    // Initialize text searcher
    textSearcher = pdf.PdfTextSearcher(controller);
    textSearcher!.addListener(_onSearchUpdate);

    // Update document page count if needed
    if (document.pageCount != doc.pages.length) {
      final updated = document.copyWith(pageCount: doc.pages.length);
      _storageService.documentsBox.put(document.id, updated);
      document = updated;
    }

    // Check if we need to jump to a specific highlight
    if (_jumpToHighlight != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        goToHighlight(_jumpToHighlight!);
        _jumpToHighlight = null;
      });
    } else if (document.lastPageIndex >= 0 &&
        document.lastPageIndex < doc.pages.length) {
      // Go to last read page (always restore, even if page 0)
      Future.delayed(const Duration(milliseconds: 300), () {
        goToPage(document.lastPageIndex);
      });
    }
  }

  void _onSearchUpdate() {
    if (textSearcher == null) return;
    searchResultCount.value = textSearcher!.matches.length;
    currentSearchIndex.value = (textSearcher!.currentIndex ?? -1) + 1;
    isSearchInProgress.value = textSearcher!.isSearching;
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    _saveLastPageDebounced(page);
  }

  /// Debounced page save to avoid blocking UI on every page change
  void _saveLastPageDebounced(int page) {
    _savePageDebounce?.cancel();
    _savePageDebounce = Timer(const Duration(milliseconds: 500), () {
      final updated = document.copyWith(lastPageIndex: page - 1);
      _storageService.documentsBox.put(document.id, updated);
      document = updated;
    });
  }

  void loadAnnotations() {
    // Load highlights and build page cache
    final docHighlights = _storageService.highlightsBox.values
        .where((h) => h.documentId == document.id)
        .toList();
    highlights.assignAll(docHighlights);
    _rebuildHighlightsCache();

    // Load drawings and build page cache
    final docDrawings = _storageService.drawingsBox.values
        .where((d) => d.documentId == document.id)
        .toList();
    drawings.assignAll(docDrawings);
    _rebuildDrawingsCache();

    // Load bookmarks
    final docBookmarks = _storageService.bookmarksBox.values
        .where((b) => b.documentId == document.id)
        .toList();
    bookmarks.assignAll(docBookmarks);
  }

  /// Rebuild highlights cache for O(1) page lookup
  void _rebuildHighlightsCache() {
    _highlightsByPage.clear();
    for (final highlight in highlights) {
      _highlightsByPage.putIfAbsent(highlight.pageIndex, () => []);
      _highlightsByPage[highlight.pageIndex]!.add(highlight);
    }
  }

  /// Rebuild drawings cache for O(1) page lookup
  void _rebuildDrawingsCache() {
    _drawingsByPage.clear();
    for (final drawing in drawings) {
      _drawingsByPage[drawing.pageIndex] = drawing;
    }
  }

  /// Get highlights for a specific page - O(1) lookup
  List<Highlight> getHighlightsForPage(int pageIndex) {
    return _highlightsByPage[pageIndex] ?? const [];
  }

  // Annotation mode
  void setAnnotationMode(AnnotationMode mode) {
    if (annotationMode.value == mode) {
      annotationMode.value = AnnotationMode.none;
    } else {
      annotationMode.value = mode;
    }
  }

  void setHighlightColor(Color color) {
    selectedHighlightColor.value = color;
  }

  void setDrawingColor(Color color) {
    selectedDrawingColor.value = color;
  }

  // Highlight operations
  Future<void> addHighlight({
    required int pageIndex,
    required String text,
    required List<Rect> rects,
    String? note,
  }) async {
    final highlight = Highlight.create(
      id: const Uuid().v4(),
      documentId: document.id,
      pageIndex: pageIndex,
      color: selectedHighlightColor.value,
      text: text,
      rects: rects,
      note: note,
    );

    await _storageService.highlightsBox.put(highlight.id, highlight);
    highlights.add(highlight);

    // Update cache
    _highlightsByPage.putIfAbsent(pageIndex, () => []);
    _highlightsByPage[pageIndex]!.add(highlight);

    highlights.refresh();
  }

  Future<void> addHighlightFromSelection(pdf.PdfTextRanges textRanges) async {
    if (pdfDocument == null) return;

    final page = textRanges.pageText.pageNumber;
    final pageIndex = page - 1;

    // Get the selected text
    final selectedText = textRanges.text;
    if (selectedText.isEmpty) return;

    // Get the rects for the selection (normalized to page size 0-1)
    final pdfPage = pdfDocument!.pages[pageIndex];
    final pageWidth = pdfPage.width;
    final pageHeight = pdfPage.height;

    final rects = <Rect>[];
    for (final range in textRanges.ranges) {
      // Get bounds for this range using fragments
      final fragments = textRanges.pageText.fragments;
      for (final fragment in fragments) {
        // Check if fragment overlaps with our range
        final fragStart = fragment.index;
        final fragEnd = fragment.index + fragment.length;

        if (fragStart < range.end && fragEnd > range.start) {
          // This fragment is part of selection
          final bounds = fragment.bounds;
          // Normalize to 0-1 range
          rects.add(
            Rect.fromLTRB(
              bounds.left / pageWidth,
              bounds.top / pageHeight,
              bounds.right / pageWidth,
              bounds.bottom / pageHeight,
            ),
          );
        }
      }
    }

    if (rects.isEmpty) return;

    await addHighlight(pageIndex: pageIndex, text: selectedText, rects: rects);
  }

  Future<void> updateHighlightNote(String highlightId, String note) async {
    final index = highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      final updated = highlights[index].copyWith(note: note);
      await _storageService.highlightsBox.put(highlightId, updated);
      highlights[index] = updated;
      _rebuildHighlightsCache();
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    await _storageService.highlightsBox.delete(highlightId);
    highlights.removeWhere((h) => h.id == highlightId);
    _rebuildHighlightsCache();
  }

  // Drawing operations with page-relative coordinates
  void startStroke(Offset point, Size viewSize) {
    currentStroke.clear();
    // Store normalized coordinates (0-1 range)
    final normalized = Offset(
      point.dx / viewSize.width,
      point.dy / viewSize.height,
    );
    currentStroke.add(normalized);
  }

  void updateStroke(Offset point, Size viewSize) {
    // Store normalized coordinates (0-1 range)
    final normalized = Offset(
      point.dx / viewSize.width,
      point.dy / viewSize.height,
    );
    currentStroke.add(normalized);
  }

  Future<void> endStroke(int pageIndex, Size viewSize) async {
    if (currentStroke.isEmpty) return;

    // Get existing drawing for this page or create new one - O(1) lookup
    var drawing = _drawingsByPage[pageIndex];

    if (annotationMode.value == AnnotationMode.eraser) {
      // Eraser mode: remove strokes that intersect with the eraser path
      if (drawing != null) {
        await eraseStrokes(drawing, currentStroke.toList());
      }
    } else {
      // Drawing mode: add new stroke
      final stroke = DrawingStroke.fromPoints(
        points: currentStroke.toList(),
        color: selectedDrawingColor.value,
        strokeWidth: strokeWidth.value,
        isEraser: false,
      );

      if (drawing != null) {
        drawing = drawing.addStroke(stroke);
        await _storageService.drawingsBox.put(drawing.id, drawing);
        final index = drawings.indexWhere((d) => d.id == drawing!.id);
        drawings[index] = drawing;
        _drawingsByPage[pageIndex] = drawing;
      } else {
        drawing = Drawing.create(
          id: const Uuid().v4(),
          documentId: document.id,
          pageIndex: pageIndex,
          color: selectedDrawingColor.value,
          strokes: [stroke],
        );
        await _storageService.drawingsBox.put(drawing.id, drawing);
        drawings.add(drawing);
        _drawingsByPage[pageIndex] = drawing;
      }
    }

    currentStroke.clear();
    drawings.refresh();
  }

  /// Optimized eraser with point sampling to reduce O(n³) complexity
  Future<void> eraseStrokes(Drawing drawing, List<Offset> eraserPath) async {
    if (eraserPath.isEmpty) return;

    // Sample eraser path to reduce iterations (every 3rd point)
    final sampledPath = <Offset>[];
    for (var i = 0; i < eraserPath.length; i += 3) {
      sampledPath.add(eraserPath[i]);
    }
    // Always include last point
    if (eraserPath.isNotEmpty && sampledPath.last != eraserPath.last) {
      sampledPath.add(eraserPath.last);
    }

    const eraserTolerance = 0.03; // 3% of page size tolerance
    final toleranceSquared = eraserTolerance * eraserTolerance;

    // Filter out strokes that intersect with eraser path
    final remainingStrokes = <DrawingStroke>[];
    for (final stroke in drawing.strokes) {
      bool shouldRemove = false;

      // Sample stroke points too for very long strokes
      final strokePoints = stroke.points.length > 20
          ? [
              for (var i = 0; i < stroke.points.length; i += 3)
                stroke.points[i],
              stroke.points.last,
            ]
          : stroke.points;

      outer:
      for (final strokePoint in strokePoints) {
        for (final eraserPoint in sampledPath) {
          // Use squared distance to avoid sqrt
          final dx = strokePoint.dx - eraserPoint.dx;
          final dy = strokePoint.dy - eraserPoint.dy;
          final distanceSquared = dx * dx + dy * dy;
          if (distanceSquared < toleranceSquared) {
            shouldRemove = true;
            break outer;
          }
        }
      }

      if (!shouldRemove) {
        remainingStrokes.add(stroke);
      }
    }

    if (remainingStrokes.isEmpty) {
      // Delete the whole drawing
      await _storageService.drawingsBox.delete(drawing.id);
      drawings.removeWhere((d) => d.id == drawing.id);
      _drawingsByPage.remove(drawing.pageIndex);
    } else if (remainingStrokes.length != drawing.strokes.length) {
      // Update with remaining strokes
      final updated = drawing.copyWith(strokes: remainingStrokes);
      await _storageService.drawingsBox.put(drawing.id, updated);
      final index = drawings.indexWhere((d) => d.id == drawing.id);
      if (index != -1) {
        drawings[index] = updated;
        _drawingsByPage[drawing.pageIndex] = updated;
      }
    }
  }

  Future<void> clearDrawings(int pageIndex) async {
    final drawing = _drawingsByPage[pageIndex];
    if (drawing != null) {
      await _storageService.drawingsBox.delete(drawing.id);
      drawings.removeWhere((d) => d.id == drawing.id);
      _drawingsByPage.remove(pageIndex);
      drawings.refresh();
    }
  }

  /// Get drawings for a specific page - O(1) lookup
  Drawing? getDrawingForPage(int pageIndex) {
    return _drawingsByPage[pageIndex];
  }

  // Bookmark operations
  bool isPageBookmarked(int pageIndex) {
    return bookmarks.any((b) => b.pageIndex == pageIndex);
  }

  Future<void> toggleBookmark(int pageIndex, {String? title}) async {
    final existing = bookmarks.firstWhereOrNull(
      (b) => b.pageIndex == pageIndex,
    );

    if (existing != null) {
      await _storageService.bookmarksBox.delete(existing.id);
      bookmarks.remove(existing);
    } else {
      final bookmark = Bookmark.create(
        id: const Uuid().v4(),
        documentId: document.id,
        pageIndex: pageIndex,
        title: title,
      );
      await _storageService.bookmarksBox.put(bookmark.id, bookmark);
      bookmarks.add(bookmark);
    }
  }

  void goToPage(int pageIndex) {
    pdfViewerController?.goToPage(pageNumber: pageIndex + 1);
  }

  // Go to a specific highlight
  void goToHighlight(Highlight highlight) {
    if (pdfDocument == null || pdfViewerController == null) return;

    final pageIndex = highlight.pageIndex;
    if (pageIndex < 0 || pageIndex >= pdfDocument!.pages.length) return;

    final page = pdfDocument!.pages[pageIndex];
    final rects = highlight.rects;

    if (rects.isEmpty) {
      // Just go to the page if no rects
      goToPage(pageIndex);
      return;
    }

    // Get the first highlight rect
    final firstRect = rects.first;

    // Create rect in page coordinates for ensureVisible
    final targetRect = pdf.PdfRect(
      firstRect.left * page.width,
      firstRect.top * page.height,
      firstRect.right * page.width,
      firstRect.bottom * page.height,
    );

    // Calculate the rect for the viewer
    final viewerRect = pdfViewerController!.calcRectForRectInsidePage(
      pageNumber: pageIndex + 1,
      rect: targetRect,
    );

    // Ensure the highlight is visible
    pdfViewerController!.ensureVisible(viewerRect, margin: 50);
  }

  // Zoom lock operations
  void toggleZoomLock() {
    if (isZoomLocked.value) {
      // Unlock
      isZoomLocked.value = false;
    } else {
      // Lock at current zoom level
      lockedZoomLevel.value = zoomLevel.value;
      isZoomLocked.value = true;
    }
  }

  void updateZoomLevel(double zoom) {
    zoomLevel.value = zoom;
  }

  // Search operations
  void search(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    searchQuery.value = query;
    textSearcher?.startTextSearch(query, caseInsensitive: true);
  }

  void goToNextSearchResult() {
    textSearcher?.goToNextMatch();
  }

  void goToPreviousSearchResult() {
    textSearcher?.goToPrevMatch();
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResultCount.value = 0;
    currentSearchIndex.value = 0;
    textSearcher?.resetTextSearch();
  }

  void toggleToolbar() {
    showToolbar.value = !showToolbar.value;
  }

  // Favorite operations
  Future<void> toggleFavorite() async {
    final updated = document.copyWith(isFavorite: !document.isFavorite);
    await _storageService.documentsBox.put(document.id, updated);
    document = updated;
    isFavorite.value = updated.isFavorite;

    // Update LibraryController if registered to sync favorite state
    if (Get.isRegistered<LibraryController>()) {
      Get.find<LibraryController>().loadDocuments();
    }
  }

  // Page navigation
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      goToPage(currentPage.value);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 2);
    }
  }

  File get pdfFile => File(document.filePath);
}
