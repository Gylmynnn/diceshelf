import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../abstracts/base_storage_service.dart';
import '../constants/strings.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/collection.dart';
import '../../data/models/drawing.dart';
import '../../data/models/highlight.dart';
import '../../data/models/pdf_document.dart';

/// Implementation of storage service using Hive
class StorageService extends GetxService implements BaseStorageService {
  late Box<PdfDocument> _documentsBox;
  late Box<Highlight> _highlightsBox;
  late Box<Drawing> _drawingsBox;
  late Box<Bookmark> _bookmarksBox;
  late Box<Collection> _collectionsBox;
  late Box _settingsBox;

  Box<PdfDocument> get documentsBox => _documentsBox;
  Box<Highlight> get highlightsBox => _highlightsBox;
  Box<Drawing> get drawingsBox => _drawingsBox;
  Box<Bookmark> get bookmarksBox => _bookmarksBox;
  Box<Collection> get collectionsBox => _collectionsBox;
  Box get settingsBox => _settingsBox;

  @override
  Future<StorageService> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(PdfDocumentAdapter());
    Hive.registerAdapter(HighlightAdapter());
    Hive.registerAdapter(DrawingAdapter());
    Hive.registerAdapter(DrawingStrokeAdapter());
    Hive.registerAdapter(BookmarkAdapter());
    Hive.registerAdapter(CollectionAdapter());

    // Open boxes
    _documentsBox = await Hive.openBox<PdfDocument>(AppStrings.documentsBoxKey);
    _highlightsBox = await Hive.openBox<Highlight>(
      AppStrings.annotationsBoxKey,
    );
    _drawingsBox = await Hive.openBox<Drawing>('drawings');
    _bookmarksBox = await Hive.openBox<Bookmark>(AppStrings.bookmarksBoxKey);
    _collectionsBox = await Hive.openBox<Collection>(
      AppStrings.collectionsBoxKey,
    );
    _settingsBox = await Hive.openBox(AppStrings.settingsBoxKey);

    return this;
  }

  @override
  T? get<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _settingsBox.delete(key);
  }

  @override
  bool containsKey(String key) {
    return _settingsBox.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _settingsBox.clear();
  }
}
