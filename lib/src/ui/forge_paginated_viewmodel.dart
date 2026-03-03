import 'forge_viewmodel.dart';

/// Base ViewModel for page-based (1, 2, 3…) pagination.
///
/// Usage:
/// ```dart
/// class ArticleListViewModel extends ForgePaginatedViewModel<Article> {
///   ArticleListViewModel(this._repository);
///   final ArticleRepository _repository;
///
///   @override
///   Future<List<Article>> loadPage(int page) async {
///     final result = await _repository.getArticles(page: page, limit: 20);
///     return result.dataOrNull ?? [];
///   }
/// }
/// ```
abstract class ForgePaginatedViewModel<T> extends ForgeViewModel {
  final List<T> items = <T>[];

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Implement to fetch [page] from your repository.
  Future<List<T>> loadPage(int page);

  /// Clears all items and reloads from page 1.
  Future<void> refresh() async {
    items.clear();
    _currentPage = 0;
    _hasMore = true;
    await loadNextPage(reset: true);
  }

  /// Loads the next page. Safe to call multiple times — debounced internally.
  Future<void> loadNextPage({bool reset = false}) async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = reset ? 1 : _currentPage + 1;

    try {
      final newItems = await loadPage(nextPage);
      if (reset) {
        items
          ..clear()
          ..addAll(newItems);
      } else {
        items.addAll(newItems);
      }
      _currentPage = nextPage;
      _hasMore = newItems.isNotEmpty;
      clearError();
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
