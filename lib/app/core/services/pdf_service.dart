import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../abstracts/base_pdf_service.dart';

/// Implementation of PDF file operations
class PdfService extends GetxService implements BasePdfService {
  late Directory _appDocDir;
  late Directory _thumbnailDir;

  /// Thumbnail dimensions (A4 ratio approximately)
  static const int thumbnailWidth = 200;
  static const int thumbnailHeight = 280;

  Future<PdfService> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();

    // Create pdfs directory
    final pdfDir = Directory(p.join(_appDocDir.path, 'pdfs'));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    // Create thumbnails directory
    _thumbnailDir = Directory(p.join(_appDocDir.path, 'thumbnails'));
    if (!await _thumbnailDir.exists()) {
      await _thumbnailDir.create(recursive: true);
    }

    return this;
  }

  @override
  Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<File?> getPdfFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  Future<File> copyToAppStorage(File file) async {
    final fileName = p.basename(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = p.join(_appDocDir.path, 'pdfs', '${timestamp}_$fileName');
    return await file.copy(newPath);
  }

  @override
  Future<void> deleteFromStorage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists(String path) async {
    return await File(path).exists();
  }

  @override
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  @override
  Future<String> extractTextFromPage(String path, int pageIndex) async {
    // Text extraction is handled by pdfrx package in the viewer
    return '';
  }

  /// Generate thumbnail for PDF first page
  /// Returns the path to the saved thumbnail, or null if generation failed
  Future<String?> generateThumbnail(String pdfPath, String documentId) async {
    try {
      final thumbnailPath = p.join(_thumbnailDir.path, '$documentId.png');

      // Check if thumbnail already exists
      final thumbnailFile = File(thumbnailPath);
      if (await thumbnailFile.exists()) {
        return thumbnailPath;
      }

      // Open PDF document
      final pdfDocument = await PdfDocument.openFile(pdfPath);

      try {
        // Get first page (pdfrx uses 1-based indexing in pages list)
        if (pdfDocument.pages.isEmpty) {
          return null;
        }

        final page = pdfDocument.pages[0];

        // Calculate scale to fit within thumbnail dimensions while maintaining aspect ratio
        final double scaleX = thumbnailWidth / page.width;
        final double scaleY = thumbnailHeight / page.height;
        final double scale = scaleX < scaleY ? scaleX : scaleY;

        final int renderWidth = (page.width * scale).round();
        final int renderHeight = (page.height * scale).round();

        // Render page to image
        final pdfImage = await page.render(
          fullWidth: renderWidth.toDouble(),
          fullHeight: renderHeight.toDouble(),
          backgroundColor: const ui.Color(0xFFFFFFFF),
        );

        if (pdfImage == null) {
          return null;
        }

        // Convert to PNG bytes
        final image = await pdfImage.createImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData == null) {
          return null;
        }

        // Save to file
        final pngBytes = byteData.buffer.asUint8List();
        await thumbnailFile.writeAsBytes(pngBytes);

        return thumbnailPath;
      } finally {
        pdfDocument.dispose();
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Delete thumbnail for a document
  Future<void> deleteThumbnail(String documentId) async {
    final thumbnailPath = p.join(_thumbnailDir.path, '$documentId.png');
    final file = File(thumbnailPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get page count of a PDF document
  Future<int> getPageCount(String pdfPath) async {
    PdfDocument? pdfDocument;
    try {
      pdfDocument = await PdfDocument.openFile(pdfPath);
      return pdfDocument.pages.length;
    } catch (e) {
      debugPrint('Error getting page count: $e');
      return 0;
    } finally {
      pdfDocument?.dispose();
    }
  }
}
