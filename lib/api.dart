import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

enum FetchStatus { ok, notModified, notFound }

/// A conditional GET's outcome. [value] and [etag] are set when [status] is
/// [FetchStatus.ok]; for [FetchStatus.notModified] the caller's copy is
/// still current.
class Fetched<T> {
  const Fetched(this.status, {this.value, this.etag});

  final FetchStatus status;
  final T? value;
  final String? etag;
}

/// The Дұрыс сөйле API (`/words`, `/audio`).
class Api {
  Api(String baseUrl, {http.Client? client})
      : _base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 20);

  final String _base;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_base/$path').replace(queryParameters: query);

  /// One page of a list. NOTE: the API's `offset` is a page number, not a
  /// row offset: it returns rows [page * limit, (page + 1) * limit). The
  /// filter matches words by their beginning, case-insensitively.
  Future<List<Word>> words(WordType type, {required int page, required int limit, String filter = ''}) async {
    final response = await _get(_uri('words', {
      'type': type.apiValue,
      'offset': '$page',
      'limit': '$limit',
      'sort': 'asc',
      if (filter.isNotEmpty) 'filter': filter,
    }));
    if (response.statusCode != 200) {
      throw ApiException('GET /words answered ${response.statusCode}');
    }
    return [
      for (final item in jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>)
        Word.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// A single word; with [etag], answers [FetchStatus.notModified] if the
  /// word has not changed since.
  Future<Fetched<Word>> word(int id, {String? etag}) async {
    final response = await _get(_uri('words/$id'), etag: etag);
    return _fetched(response, 'GET /words/$id',
        (body) => Word.fromJson(jsonDecode(utf8.decode(body)) as Map<String, dynamic>));
  }

  /// A word's pronunciation as MP3 (the format every platform can play);
  /// with [etag], answers [FetchStatus.notModified] if it has not changed.
  Future<Fetched<Uint8List>> audio(int id, {String? etag}) async {
    final response = await _get(_uri('audio/$id'), etag: etag);
    return _fetched(response, 'GET /audio/$id', (body) => body);
  }

  Future<http.Response> _get(Uri uri, {String? etag}) async {
    try {
      return await _client
          .get(uri, headers: {'If-None-Match': ?etag})
          .timeout(_timeout);
    } on Exception catch (error) {
      throw ApiException('GET ${uri.path} failed: $error');
    }
  }

  Fetched<T> _fetched<T>(http.Response response, String what, T Function(Uint8List body) parse) {
    switch (response.statusCode) {
      case 200:
        return Fetched(FetchStatus.ok, value: parse(response.bodyBytes), etag: response.headers['etag']);
      case 304:
        return const Fetched(FetchStatus.notModified);
      case 404:
        return const Fetched(FetchStatus.notFound);
      default:
        throw ApiException('$what answered ${response.statusCode}');
    }
  }
}
