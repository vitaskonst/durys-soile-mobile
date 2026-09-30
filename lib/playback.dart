import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'api.dart';
import 'favorites.dart';

/// Plays words' pronunciations, one at a time.
///
/// Favourites play from their saved file, so they work offline. Other clips
/// are downloaded once into [_cacheDir] and played from there, so a replay
/// costs nothing.
class PlaybackController extends ChangeNotifier {
  PlaybackController(this._api, this._favorites, this._cacheDir) {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) _reset();
    });
  }

  final Api _api;
  final FavoritesStore _favorites;
  final Directory _cacheDir;
  final AudioPlayer _player = AudioPlayer();
  final StreamController<int> _failures = StreamController.broadcast();

  int? _loadingId;
  int? _playingId;
  // Bumped by every toggle, so a slow download for an earlier tap is dropped.
  int _request = 0;

  int? get loadingId => _loadingId;
  int? get playingId => _playingId;

  /// Ids of words whose audio could not be played.
  Stream<int> get failures => _failures.stream;

  /// Plays a word, or stops it if it is the one loading or playing.
  Future<void> toggle(int wordId) async {
    final request = ++_request;
    if (_playingId == wordId || _loadingId == wordId) {
      await _player.stop();
      _reset();
      return;
    }

    await _player.stop();
    _loadingId = wordId;
    _playingId = null;
    notifyListeners();
    try {
      final file = _favorites.audioFile(wordId) ?? await _cached(wordId);
      if (request != _request) return;
      await _player.setFilePath(file.path);
      if (request != _request) return;
      _loadingId = null;
      _playingId = wordId;
      notifyListeners();
      await _player.play();
    } on Exception catch (error) {
      if (request != _request) return;
      debugPrint('could not play word $wordId: $error');
      _reset();
      _failures.add(wordId);
    }
  }

  Future<File> _cached(int wordId) async {
    final file = File('${_cacheDir.path}/audio/$wordId.mp3');
    if (await file.exists() && await file.length() > 0) return file;
    final fetched = await _api.audio(wordId);
    if (fetched.status != FetchStatus.ok) {
      throw ApiException('no audio for word $wordId');
    }
    await file.parent.create(recursive: true);
    // Write then rename, so an interrupted download is never played later.
    final temp = File('${file.path}.part');
    await temp.writeAsBytes(fetched.value!, flush: true);
    return temp.rename(file.path);
  }

  void _reset() {
    if (_loadingId == null && _playingId == null) return;
    _loadingId = null;
    _playingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _failures.close();
    super.dispose();
  }
}
