import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/pdf_document.dart';

class HighlightsController extends GetxController {
  final _storageService = Get.find<StorageService>();

  final RxList<Highlight> highlights = <Highlight>[].obs;
  final RxMap<String, PdfDocument> documents = <String, PdfDocument>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHighlights();
  }

  void loadHighlights() {
    final allHighlights = _storageService.highlightsBox.values.toList();
    allHighlights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    highlights.assignAll(allHighlights);

    // Load document titles
    for (final highlight in allHighlights) {
      if (!documents.containsKey(highlight.documentId)) {
        final doc = _storageService.documentsBox.get(highlight.documentId);
        if (doc != null) {
          documents[highlight.documentId] = doc;
        }
      }
    }
  }

  String getDocumentTitle(String documentId) {
    return documents[documentId]?.title ?? 'Unknown Document';
  }

  Future<void> deleteHighlight(Highlight highlight) async {
    await _storageService.highlightsBox.delete(highlight.id);
    highlights.remove(highlight);
  }

  void openDocument(Highlight highlight) {
    // Get fresh document from storage to ensure we have latest data
    final doc = _storageService.documentsBox.get(highlight.documentId);
    if (doc != null) {
      // Pass both document and highlight info to jump to the highlight
      Get.toNamed(
        '/pdf-viewer',
        arguments: {'document': doc, 'jumpToHighlight': highlight},
      );
    }
  }
}
