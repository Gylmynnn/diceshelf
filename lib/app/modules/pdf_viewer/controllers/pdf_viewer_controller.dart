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

/// Annotation mode for the PDF viewer
enum AnnotationMode { none, highlight, drawing, eraser }

/// Controller for the PDF Viewer screen
class PdfViewerController extends GetxController {
  final _storageService = Get.find<StorageService>();

  late models.PdfDocument document;
  pdf.PdfViewerController? pdfController;

  final Rx<AnnotationMode> annotationMode = AnnotationMode.none.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 0.obs;
  final RxDouble zoomLevel = 1.0.obs;
  final RxBool isLoading = true.obs;
  final RxBool showToolbar = true.obs;

  // Highlights
  final RxList<Highlight> highlights = <Highlight>[].obs;
  final Rx<Color> selectedHighlightColor =
      EverblushColors.highlightColors[0].obs;

  // Drawings
  final RxList<Drawing> drawings = <Drawing>[].obs;
  final Rx<Color> selectedDrawingColor = EverblushColors.cyan.obs;
  final RxDouble strokeWidth = 3.0.obs;
  final RxList<Offset> currentStroke = <Offset>[].obs;

  // Bookmarks
  final RxList<Bookmark> bookmarks = <Bookmark>[].obs;

  // Search
  final RxString searchQuery = ''.obs;
  final RxList<pdf.PdfTextRanges> searchResults = <pdf.PdfTextRanges>[].obs;
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    document = Get.arguments as models.PdfDocument;
    loadAnnotations();
  }

  void onDocumentLoaded(models.PdfDocument doc, int pages) {
    totalPages.value = pages;
    isLoading.value = false;

    // Update document page count if needed
    if (document.pageCount != pages) {
      final updated = document.copyWith(pageCount: pages);
      _storageService.documentsBox.put(document.id, updated);
      document = updated;
    }
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    _saveLastPage(page);
  }

  void _saveLastPage(int page) {
    final updated = document.copyWith(lastPageIndex: page - 1);
    _storageService.documentsBox.put(document.id, updated);
  }

  void loadAnnotations() {
    // Load highlights
    final docHighlights = _storageService.highlightsBox.values
        .where((h) => h.documentId == document.id)
        .toList();
    highlights.assignAll(docHighlights);

    // Load drawings
    final docDrawings = _storageService.drawingsBox.values
        .where((d) => d.documentId == document.id)
        .toList();
    drawings.assignAll(docDrawings);

    // Load bookmarks
    final docBookmarks = _storageService.bookmarksBox.values
        .where((b) => b.documentId == document.id)
        .toList();
    bookmarks.assignAll(docBookmarks);
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
  }

  Future<void> updateHighlightNote(String highlightId, String note) async {
    final index = highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      final updated = highlights[index].copyWith(note: note);
      await _storageService.highlightsBox.put(highlightId, updated);
      highlights[index] = updated;
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    await _storageService.highlightsBox.delete(highlightId);
    highlights.removeWhere((h) => h.id == highlightId);
  }

  // Drawing operations
  void startStroke(Offset point) {
    currentStroke.clear();
    currentStroke.add(point);
  }

  void updateStroke(Offset point) {
    currentStroke.add(point);
  }

  Future<void> endStroke(int pageIndex) async {
    if (currentStroke.isEmpty) return;

    // Get existing drawing for this page or create new one
    var drawing = drawings.firstWhereOrNull((d) => d.pageIndex == pageIndex);

    final stroke = DrawingStroke.fromPoints(
      points: currentStroke.toList(),
      color: annotationMode.value == AnnotationMode.eraser
          ? Colors.transparent
          : selectedDrawingColor.value,
      strokeWidth: strokeWidth.value,
      isEraser: annotationMode.value == AnnotationMode.eraser,
    );

    if (drawing != null) {
      drawing = drawing.addStroke(stroke);
      await _storageService.drawingsBox.put(drawing.id, drawing);
      final index = drawings.indexWhere((d) => d.id == drawing!.id);
      drawings[index] = drawing;
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
    }

    currentStroke.clear();
  }

  Future<void> clearDrawings(int pageIndex) async {
    final drawing = drawings.firstWhereOrNull((d) => d.pageIndex == pageIndex);
    if (drawing != null) {
      await _storageService.drawingsBox.delete(drawing.id);
      drawings.removeWhere((d) => d.id == drawing.id);
    }
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
    // This would be handled by the PDF viewer widget
  }

  // Search
  Future<void> search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    searchQuery.value = query;
    // Search implementation would use pdfrx's text search
    isSearching.value = false;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  void toggleToolbar() {
    showToolbar.value = !showToolbar.value;
  }

  File get pdfFile => File(document.filePath);
}
