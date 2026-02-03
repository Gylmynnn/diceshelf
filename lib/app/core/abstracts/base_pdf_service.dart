import 'dart:io';

/// Abstract base class for PDF operations
/// Provides contract for PDF file handling
abstract class BasePdfService {
  /// Open file picker and return selected PDF file
  Future<File?> pickPdfFile();

  /// Get PDF file from path
  Future<File?> getPdfFile(String path);

  /// Copy PDF to app storage directory
  Future<File> copyToAppStorage(File file);

  /// Delete PDF from app storage
  Future<void> deleteFromStorage(String path);

  /// Check if PDF file exists
  Future<bool> exists(String path);

  /// Get file size in bytes
  Future<int> getFileSize(String path);

  /// Extract text from page for search
  Future<String> extractTextFromPage(String path, int pageIndex);
}
