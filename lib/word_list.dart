import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

/// One word list, loaded a page at a time as the user scrolls, for the
/// current search [query] (words starting with it).
class WordListController extends ChangeNotifier {
  WordListController(this._api, this.type, {this.pageSize = 30});

  final Api _api;
  final WordType type;
  final int pageSize;

  final List<Word> _items = [];
  String _query = '';
  int _nextPage = 0;
  bool _loading = false;
  bool _done = false;
  Object? _error;
  // Bumped by every search, so a page arriving for an earlier one is dropped.
  int _generation = 0;

  List<Word> get items => List.unmodifiable(_items);
  String get query => _query;
  bool get loading => _loading;
  bool get done => _done;
  Object? get error => _error;

  /// Nothing loaded yet: show a full-screen loading, error or empty state.
  bool get isInitial => _items.isEmpty;

  /// Starts over with a new search; an empty query lists every word.
  Future<void> search(String query) {
    _generation++;
    _query = query.trim();
    _items.clear();
    _nextPage = 0;
    _done = false;
    _error = null;
    _loading = false;
    notifyListeners();
    return loadMore();
  }

  /// Loads the next page, unless one is loading or the list is complete.
  Future<void> loadMore() async {
    if (_loading || _done) return;
    final generation = _generation;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _api.words(type, page: _nextPage, limit: pageSize, filter: _query);
      if (generation != _generation) return;
      _items.addAll(page);
      _nextPage++;
      // A short page is the last one; no need to ask for an empty one.
      _done = page.length < pageSize;
    } on ApiException catch (error) {
      if (generation != _generation) return;
      _error = error;
    } finally {
      if (generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// After an error: try the failed page again.
  Future<void> retry() => loadMore();
}
