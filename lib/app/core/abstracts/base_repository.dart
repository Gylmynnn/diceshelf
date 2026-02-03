/// Abstract base class for all repositories
/// Provides common CRUD operations pattern
abstract class BaseRepository<T, ID> {
  /// Get all items
  Future<List<T>> getAll();

  /// Get item by ID
  Future<T?> getById(ID id);

  /// Save item (create or update)
  Future<void> save(T item);

  /// Delete item by ID
  Future<void> delete(ID id);

  /// Delete all items
  Future<void> deleteAll();
}
