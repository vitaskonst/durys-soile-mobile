import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Replays the backend's API contract over real entries from its seed data
/// (test/fixtures): `offset` is a PAGE number, `filter` a case-insensitive
/// prefix, `correctVersions` is omitted for commonly mispronounced words, and
/// single words and clips carry ETags and answer If-None-Match with 304.
///
/// Tests can edit or delete words, replace clips, and go [offline].
class FakeBackend {
  FakeBackend() {
    for (final type in ['parasite', 'commonly-mispronounced']) {
      final rows = jsonDecode(File('test/fixtures/$type.json').readAsStringSync()) as List<dynamic>;
      for (final row in rows) {
        final word = Map<String, dynamic>.from(row as Map)..remove('filename');
        word['type'] = type;
        words[word['id'] as int] = word;
        audio[word['id'] as int] = utf8.encode('mp3 of ${word['word']}');
      }
    }
  }

  static const base = 'https://api.test/api/v1.0';

  final Map<int, Map<String, dynamic>> words = {};
  final Map<int, List<int>> audio = {};
  final List<Uri> requests = [];
  bool offline = false;

  late final http.Client client = MockClient(_handle);

  Future<http.Response> _handle(http.Request request) async {
    if (offline) throw http.ClientException('offline', request.url);
    requests.add(request.url);
    final path = request.url.path.replaceFirst('/api/v1.0/', '');
    final parts = path.split('/');
    final ifNoneMatch = request.headers['If-None-Match'];

    if (parts[0] == 'words' && parts.length == 1) {
      final q = request.url.queryParameters;
      final page = int.parse(q['offset']!);
      final limit = int.parse(q['limit']!);
      final filter = (q['filter'] ?? '').toLowerCase();
      final rows = (words.values
              .where((w) => w['type'] == q['type'] && (w['word'] as String).toLowerCase().startsWith(filter))
              .toList()
            ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int)))
          .skip(page * limit)
          .take(limit)
          .toList();
      return _json(rows);
    }

    final id = int.parse(parts[1]);
    if (parts[0] == 'words') {
      final word = words[id];
      if (word == null) return http.Response('{"detail":"Not Found"}', 404);
      final body = utf8.encode(jsonEncode(word));
      return _conditional(body, ifNoneMatch, {'content-type': 'application/json'});
    }
    final clip = words.containsKey(id) ? audio[id] : null;
    if (clip == null) return http.Response('{"detail":"Not Found"}', 404);
    return _conditional(clip, ifNoneMatch, {'content-type': 'audio/mpeg'});
  }

  static String etagOf(List<int> body) => '"${sha256.convert(body).toString().substring(0, 32)}"';

  http.Response _conditional(List<int> body, String? ifNoneMatch, Map<String, String> headers) {
    final etag = etagOf(body);
    if (ifNoneMatch == etag) return http.Response('', 304, headers: {'etag': etag});
    return http.Response.bytes(body, 200, headers: {...headers, 'etag': etag});
  }

  http.Response _json(Object value) =>
      http.Response.bytes(utf8.encode(jsonEncode(value)), 200, headers: {'content-type': 'application/json'});
}
