import 'package:duryssoile/api.dart';
import 'package:duryssoile/models.dart';
import 'package:duryssoile/word_list.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Api api;

  setUp(() {
    backend = FakeBackend();
    api = Api(FakeBackend.base, client: backend.client);
  });

  test('loads page after page and stops at a short page', () async {
    final list = WordListController(api, WordType.parasite, pageSize: 15);
    await list.search('');
    expect(list.items, hasLength(15));
    await list.loadMore();
    await list.loadMore();
    expect(list.items, hasLength(40)); // 15 + 15 + 10: the short page ends it
    expect(list.done, isTrue);

    final requests = backend.requests.length;
    await list.loadMore();
    expect(backend.requests.length, requests, reason: 'no request after the last page');
    expect(list.items.map((w) => w.id), List.generate(40, (i) => i));
  });

  test('a search starts over and lists words starting with the query', () async {
    final list = WordListController(api, WordType.parasite, pageSize: 15);
    await list.search('');
    await list.loadMore();
    await list.search(' ва ');
    expect(list.query, 'ва');
    expect(list.items, isNotEmpty);
    expect(list.items.every((w) => w.word.toLowerCase().startsWith('ва')), isTrue);
    expect(backend.requests.last.queryParameters['offset'], '0');
  });

  test('a search that finds nothing ends empty', () async {
    final list = WordListController(api, WordType.mispronounced);
    await list.search('жжжжж');
    expect(list.items, isEmpty);
    expect(list.done, isTrue);
    expect(list.error, isNull);
  });

  test('a page from an earlier search is dropped', () async {
    final list = WordListController(api, WordType.parasite, pageSize: 15);
    // The first search's request is still in flight when the second starts;
    // its page must not end up in the second search's results.
    final first = list.search('');
    await list.search('Апп');
    await first;
    expect(list.query, 'Апп');
    expect(list.items.map((w) => w.word), ['Аппетит']);
  });

  test('errors are kept for a retry, which loads the same page', () async {
    final list = WordListController(api, WordType.parasite, pageSize: 15);
    backend.offline = true;
    await list.search('');
    expect(list.error, isA<ApiException>());
    expect(list.items, isEmpty);

    backend.offline = false;
    await list.retry();
    expect(list.error, isNull);
    expect(list.items.first.id, 0);
  });
}
