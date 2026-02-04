import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'pdf_service.dart';

/// Priority-based thumbnail generation queue service.
/// Generates thumbnails one-by-one to prevent UI jank.
class ThumbnailQueueService extends GetxService {
  final PdfService _pdfService = Get.find<PdfService>();

  /// Queue of pending thumbnail requests
  final Queue<_ThumbnailRequest> _queue = Queue();

  /// Currently processing request
  bool _isProcessing = false;

  /// Completers for pending requests (keyed by documentId)
  final Map<String, Completer<String?>> _pendingCompleters = {};

  /// Request thumbnail generation with priority.
  /// Higher priority items are processed first.
  /// Returns the thumbnail path when complete.
  Future<String?> requestThumbnail(
    String pdfPath,
    String documentId, {
    int priority = 0,
  }) async {
    // Check if already in queue
    if (_pendingCompleters.containsKey(documentId)) {
      return _pendingCompleters[documentId]!.future;
    }

    final completer = Completer<String?>();
    _pendingCompleters[documentId] = completer;

    final request = _ThumbnailRequest(
      pdfPath: pdfPath,
      documentId: documentId,
      priority: priority,
      completer: completer,
    );

    _enqueue(request);
    _processQueue();

    return completer.future;
  }

  /// Enqueue with priority sorting
  void _enqueue(_ThumbnailRequest request) {
    // Insert based on priority (higher priority = earlier in queue)
    final list = _queue.toList();
    int insertIndex = list.length;

    for (int i = 0; i < list.length; i++) {
      if (request.priority > list[i].priority) {
        insertIndex = i;
        break;
      }
    }

    list.insert(insertIndex, request);
    _queue.clear();
    _queue.addAll(list);
  }

  /// Process queue items one by one
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final request = _queue.removeFirst();

      try {
        // Add small delay between generations to allow UI to breathe
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await _pdfService.generateThumbnail(
          request.pdfPath,
          request.documentId,
        );

        request.completer.complete(result);
      } catch (e) {
        debugPrint('ThumbnailQueue: Error generating thumbnail: $e');
        request.completer.complete(null);
      } finally {
        _pendingCompleters.remove(request.documentId);
      }
    }

    _isProcessing = false;
  }

  /// Increase priority of a specific document (e.g., when visible on screen)
  void boostPriority(String documentId) {
    final list = _queue.toList();
    final index = list.indexWhere((r) => r.documentId == documentId);

    if (index > 0) {
      final request = list.removeAt(index);
      final boosted = _ThumbnailRequest(
        pdfPath: request.pdfPath,
        documentId: request.documentId,
        priority: request.priority + 10,
        completer: request.completer,
      );

      _queue.clear();
      _enqueue(boosted);
      for (final r in list) {
        _queue.add(r);
      }
    }
  }

  /// Cancel pending request for a document
  void cancelRequest(String documentId) {
    _queue.toList().removeWhere((r) => r.documentId == documentId);
    _pendingCompleters.remove(documentId);
  }

  /// Clear all pending requests
  void clearQueue() {
    for (final completer in _pendingCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _queue.clear();
    _pendingCompleters.clear();
  }

  @override
  void onClose() {
    clearQueue();
    super.onClose();
  }
}

class _ThumbnailRequest {
  final String pdfPath;
  final String documentId;
  final int priority;
  final Completer<String?> completer;

  _ThumbnailRequest({
    required this.pdfPath,
    required this.documentId,
    required this.priority,
    required this.completer,
  });
}
