import 'dart:convert';
import 'dart:io';

import 'package:duryssoile/api.dart';
import 'package:duryssoile/favorites.dart';
import 'package:duryssoile/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Api api;
  late Directory dir;
  late FavoritesStore store;

  Future<Word> word(int id) async => (await api.word(id)).value!;
  String savedAudio(int id) => utf8.decode(store.audioFile(id)!.readAsBytesSync());
  int requestsTo(String path) => backend.requests.where((u) => u.path.endsWith(path)).length;

  setUp(() {
    backend = FakeBackend();
    api = Api(FakeBackend.base, client: backend.client);
    dir = Directory.systemTemp.createTempSync('favorites_test');
    store = FavoritesStore(api, dir);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('adding saves the word and its clip, and survives a restart', () async {
    await store.add(await word(0));
    expect(store.contains(0), isTrue);
    expect(savedAudio(0), 'mp3 of Аппетит');

    final reopened = FavoritesStore(api, dir);
    await reopened.load();
    expect(reopened.all.single.word.word, 'Аппетит');
    expect(reopened.all.single.word.suggestion, 'Тәбет');
    expect(reopened.audioFile(0)!.existsSync(), isTrue);
  });

  test('favourites play offline: the saved clip needs no network', () async {
    await store.add(await word(0));
    backend.offline = true;
    expect(savedAudio(0), 'mp3 of Аппетит');
  });

  test('refresh downloads nothing when nothing changed', () async {
    await store.add(await word(0));
    final audioRequests = requestsTo('/audio/0');
    expect(await store.refresh(), 0);
    // Both were conditional requests answered with 304, not downloads.
    expect(requestsTo('/audio/0'), audioRequests + 1);
    expect(savedAudio(0), 'mp3 of Аппетит');
  });

  test('refresh picks up an edited word and a replaced clip', () async {
    await store.add(await word(0));
    backend.words[0]!['word'] = 'Аппетит!';
    backend.audio[0] = utf8.encode('new mp3');
    expect(await store.refresh(), 1);
    expect(store.all.single.word.word, 'Аппетит!');
    expect(savedAudio(0), 'new mp3');
  });

  test('a word deleted from the dictionary is flagged, kept, and unflagged if it returns', () async {
    await store.add(await word(0));
    final saved = backend.words.remove(0)!;
    expect(await store.refresh(), 1);
    expect(store.all.single.removed, isTrue);
    expect(savedAudio(0), 'mp3 of Аппетит', reason: 'the saved copy stays');

    backend.words[0] = saved;
    expect(await store.refresh(), 1);
    expect(store.all.single.removed, isFalse);
  });

  test('offline refresh keeps everything as it was', () async {
    await store.add(await word(0));
    backend.offline = true;
    expect(await store.refresh(), 0);
    expect(store.all.single.removed, isFalse);
    expect(savedAudio(0), 'mp3 of Аппетит');
  });

  test('adding fails cleanly offline; removing deletes the saved clip', () async {
    backend.offline = true;
    await expectLater(store.add(const Word(id: 1, word: 'x', type: 'parasite', json: {})), throwsA(isA<ApiException>()));
    expect(store.contains(1), isFalse);
    expect(store.isSaving(1), isFalse);

    backend.offline = false;
    await store.add(await word(1));
    final file = store.audioFile(1)!;
    await store.remove(1);
    expect(store.contains(1), isFalse);
    expect(file.existsSync(), isFalse);
  });

  test('newest favourite first', () async {
    await store.add(await word(0));
    await store.add(await word(33));
    expect(store.all.map((f) => f.word.id), [33, 0]);
  });
}
