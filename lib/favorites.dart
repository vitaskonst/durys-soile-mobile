import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

/// A saved word: its data and pronunciation, stored on the device.
class Favorite {
  Favorite({
    required this.word,
    required this.addedAt,
    this.wordEtag,
    this.audioEtag,
    this.hasAudio = false,
    this.removed = false,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        word: Word.fromJson(json['word'] as Map<String, dynamic>),
        addedAt: DateTime.parse(json['addedAt'] as String),
        wordEtag: json['wordEtag'] as String?,
        audioEtag: json['audioEtag'] as String?,
        hasAudio: json['hasAudio'] as bool? ?? false,
        removed: json['removed'] as bool? ?? false,
      );

  Word word;
  final DateTime addedAt;
  String? wordEtag;
  String? audioEtag;
  bool hasAudio;

  /// The word was deleted from the dictionary. It stays until the user
  /// removes it, flagged, with whatever was saved.
  bool removed;

  Map<String, dynamic> toJson() => {
        'word': word.json,
        'addedAt': addedAt.toIso8601String(),
        'wordEtag': wordEtag,
        'audioEtag': audioEtag,
        'hasAudio': hasAudio,
        'removed': removed,
      };
}

/// Favourites, kept on the device so they work offline, and refreshed from
/// the backend with conditional requests: a word or clip is downloaded again
/// only if it changed there.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._api, this._dir);

  final Api _api;
  final Directory _dir;
  final Map<int, Favorite> _favorites = {};
  final Set<int> _saving = {};
  bool _refreshing = false;

  File get _index => File('${_dir.path}/favorites.json');

  /// Newest first.
  List<Favorite> get all => _favorites.values.toList()..sort((a, b) => b.addedAt.compareTo(a.addedAt));

  bool contains(int wordId) => _favorites.containsKey(wordId);

  /// The word is being downloaded to become a favourite.
  bool isSaving(int wordId) => _saving.contains(wordId);

  /// The saved pronunciation, if the word is a favourite and it has one.
  File? audioFile(int wordId) {
    final favorite = _favorites[wordId];
    return favorite != null && favorite.hasAudio ? _audioPath(wordId) : null;
  }

  File _audioPath(int wordId) => File('${_dir.path}/audio/$wordId.mp3');

  Future<void> load() async {
    if (!await _index.exists()) return;
    try {
      final list = jsonDecode(await _index.readAsString()) as List<dynamic>;
      for (final item in list) {
        final favorite = Favorite.fromJson(item as Map<String, dynamic>);
        _favorites[favorite.word.id] = favorite;
      }
    } on FormatException catch (error) {
      // Only reachable if the file was damaged outside the app: start over
      // rather than never starting again.
      debugPrint('favorites index unreadable, ignoring it: $error');
    }
    notifyListeners();
  }

  /// Saves a word with its pronunciation. Needs the network; throws
  /// [ApiException] if the word cannot be downloaded.
  Future<void> add(Word word) async {
    if (contains(word.id) || !_saving.add(word.id)) return;
    notifyListeners();
    try {
      final fetched = await _api.word(word.id);
      if (fetched.status != FetchStatus.ok) {
        throw ApiException('word ${word.id} is not available');
      }
      final favorite = Favorite(word: fetched.value!, wordEtag: fetched.etag, addedAt: DateTime.now());
      final audio = await _api.audio(word.id);
      if (audio.status == FetchStatus.ok) {
        await _writeAudio(word.id, audio.value!);
        favorite
          ..hasAudio = true
          ..audioEtag = audio.etag;
      }
      _favorites[word.id] = favorite;
      await _save();
    } finally {
      _saving.remove(word.id);
      notifyListeners();
    }
  }

  Future<void> remove(int wordId) async {
    if (_favorites.remove(wordId) == null) return;
    final audio = _audioPath(wordId);
    if (await audio.exists()) await audio.delete();
    await _save();
    notifyListeners();
  }

  /// Checks every favourite against the backend and downloads what changed.
  /// Favourites that cannot be checked (e.g. offline) keep their copy until
  /// the next refresh. Returns how many were updated or found removed.
  Future<int> refresh() async {
    if (_refreshing) return 0;
    _refreshing = true;
    var changed = 0;
    try {
      for (final favorite in _favorites.values.toList()) {
        try {
          if (await _refreshOne(favorite)) changed++;
        } on ApiException catch (error) {
          debugPrint('could not refresh favourite ${favorite.word.id}: $error');
        }
      }
      if (changed > 0) {
        await _save();
        notifyListeners();
      }
    } finally {
      _refreshing = false;
    }
    return changed;
  }

  Future<bool> _refreshOne(Favorite favorite) async {
    final id = favorite.word.id;
    var changed = false;
    final word = await _api.word(id, etag: favorite.wordEtag);
    switch (word.status) {
      case FetchStatus.notFound:
        if (favorite.removed) return false;
        favorite.removed = true;
        return true;
      case FetchStatus.notModified:
        if (favorite.removed) {
          favorite.removed = false; // restored on the backend, unchanged
          changed = true;
        }
      case FetchStatus.ok:
        favorite
          ..word = word.value!
          ..wordEtag = word.etag
          ..removed = false;
        changed = true;
    }

    final audio = await _api.audio(id, etag: favorite.hasAudio ? favorite.audioEtag : null);
    switch (audio.status) {
      case FetchStatus.ok:
        await _writeAudio(id, audio.value!);
        favorite
          ..hasAudio = true
          ..audioEtag = audio.etag;
        changed = true;
      case FetchStatus.notFound:
        if (favorite.hasAudio) {
          final file = _audioPath(id);
          if (await file.exists()) await file.delete();
          favorite
            ..hasAudio = false
            ..audioEtag = null;
          changed = true;
        }
      case FetchStatus.notModified:
        break;
    }
    return changed;
  }

  Future<void> _writeAudio(int wordId, Uint8List bytes) async {
    final file = _audioPath(wordId);
    await file.parent.create(recursive: true);
    await _atomicWrite(file, bytes);
  }

  Future<void> _save() async {
    await _dir.create(recursive: true);
    final json = jsonEncode([for (final favorite in all) favorite.toJson()]);
    await _atomicWrite(_index, utf8.encode(json));
  }

  // Write then rename, so a crash mid-write never leaves a truncated file.
  static Future<void> _atomicWrite(File file, List<int> bytes) async {
    final temp = File('${file.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);
  }
}
