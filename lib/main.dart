import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'app.dart';
import 'config.dart';
import 'favorites.dart';
import 'locale.dart';
import 'playback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (apiBaseUrl.isEmpty) {
    runApp(const _MissingConfig());
    return;
  }

  final api = Api(apiBaseUrl);
  final favorites = FavoritesStore(api, Directory('${(await getApplicationSupportDirectory()).path}/favorites'));
  final playback = PlaybackController(api, favorites, await getTemporaryDirectory());
  final locale = LocaleController();
  await Future.wait([favorites.load(), locale.load()]);

  runApp(DurysSoileApp(
    scope: (child) => AppScope(api: api, favorites: favorites, playback: playback, locale: locale, child: child),
  ));
}

/// A build without API_BASE_URL is a packaging mistake; say so plainly
/// instead of showing empty lists.
class _MissingConfig extends StatelessWidget {
  const _MissingConfig();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This build has no API_BASE_URL.\n\n'
                'Build it with --dart-define=API_BASE_URL=https://…/api/v1.0',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}
