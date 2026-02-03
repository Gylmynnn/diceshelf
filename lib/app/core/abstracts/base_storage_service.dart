/// Abstract base class for local storage services
/// Defines contract for key-value persistence
abstract class BaseStorageService {
  /// Initialize the storage
  Future<void> init();

  /// Get value by key
  T? get<T>(String key);

  /// Save value with key
  Future<void> put<T>(String key, T value);

  /// Delete value by key
  Future<void> remove(String key);

  /// Check if key exists
  bool containsKey(String key);

  /// Clear all stored data
  Future<void> clear();
}
