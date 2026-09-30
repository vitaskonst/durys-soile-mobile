import 'package:duryssoile/api.dart';
import 'package:duryssoile/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Api api;

  setUp(() {
    backend = FakeBackend();
    api = Api('${FakeBackend.base}/', client: backend.client);
  });

  test('offset is a page number, as the API expects', () async {
    final first = await api.words(WordType.parasite, page: 0, limit: 10);
    final second = await api.words(WordType.parasite, page: 1, limit: 10);
    expect(first.first.id, 0);
    expect(second.first.id, 10);
    expect(backend.requests.last.queryParameters, {'type': 'parasite', 'offset': '1', 'limit': '10', 'sort': 'asc'});
  });

  test('sends the filter, and parses words with and without correct versions', () async {
    final parasite = await api.words(WordType.parasite, page: 0, limit: 5, filter: 'Апп');
    expect(backend.requests.last.queryParameters['filter'], 'Апп');
    expect(parasite.single.word, 'Аппетит');
    expect(parasite.single.suggestion, 'Тәбет');
    expect(parasite.single.correctVersions.single.hasExamples, isTrue);

    final mispronounced = await api.words(WordType.mispronounced, page: 0, limit: 5);
    expect(mispronounced.first.correctVersions, isEmpty);
    expect(mispronounced.first.hasDetails, isFalse);
  });

  test('a correct version without usage examples has none', () async {
    final word = (await api.word(33)).value!;
    expect(word.correctVersions.first.hasExamples, isFalse);
    expect(word.correctVersions.last.hasExamples, isTrue);
  });

  test('conditional requests: 200 with an ETag, 304 when unchanged, 404 when deleted', () async {
    final first = await api.word(0);
    expect(first.status, FetchStatus.ok);
    expect(first.etag, isNotNull);

    expect((await api.word(0, etag: first.etag)).status, FetchStatus.notModified);

    backend.words[0]!['word'] = 'Аппетит (өзгертілген)';
    final changed = await api.word(0, etag: first.etag);
    expect(changed.status, FetchStatus.ok);
    expect(changed.value!.word, 'Аппетит (өзгертілген)');

    backend.words.remove(0);
    expect((await api.word(0, etag: changed.etag)).status, FetchStatus.notFound);
    expect((await api.audio(0)).status, FetchStatus.notFound);
  });

  test('network failures become ApiException', () async {
    backend.offline = true;
    expect(() => api.words(WordType.parasite, page: 0, limit: 5), throwsA(isA<ApiException>()));
    expect(() => api.audio(1), throwsA(isA<ApiException>()));
  });
}
