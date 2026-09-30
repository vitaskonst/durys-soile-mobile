import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common.dart';
import '../widgets/word_tile.dart';

/// Saved words, stored on the device. Pull down to check them against the
/// dictionary; the app also does that on every start.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = AppScope.of(context).favorites;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navFavorites, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: favorites,
        builder: (context, _) {
          final all = favorites.all;
          return RefreshIndicator(
            onRefresh: favorites.refresh,
            child: all.isEmpty
                // Scrollable even when empty, so pull-to-refresh still works.
                ? ListView(children: [
                    const SizedBox(height: 96),
                    MessageState(title: l10n.favoritesEmptyTitle, subtitle: l10n.favoritesEmptySubtitle),
                  ])
                : ListView.separated(
                    itemCount: all.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
                    itemBuilder: (context, index) =>
                        WordTile(word: all[index].word, removed: all[index].removed),
                  ),
          );
        },
      ),
    );
  }
}
