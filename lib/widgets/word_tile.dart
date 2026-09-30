import 'package:flutter/material.dart';

import '../api.dart';
import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../theme.dart';
import 'common.dart';

/// Adds or removes a favourite; a failed download shows a snackbar.
Future<void> toggleFavorite(BuildContext context, Word word) async {
  final favorites = AppScope.of(context).favorites;
  final messenger = ScaffoldMessenger.of(context);
  final error = AppLocalizations.of(context).favoriteSaveError;
  if (favorites.contains(word.id)) {
    await favorites.remove(word.id);
    return;
  }
  try {
    await favorites.add(word);
  } on ApiException {
    messenger.showSnackBar(SnackBar(content: Text(error)));
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favorites;
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final saved = favorites.contains(word.id);
        return IconButton(
          tooltip: saved ? l10n.removeFavorite : l10n.addFavorite,
          onPressed: favorites.isSaving(word.id) ? null : () => toggleFavorite(context, word),
          icon: favorites.isSaving(word.id)
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(saved ? Icons.star : Icons.star_outline,
                  color: saved ? Theme.of(context).colorScheme.secondary : null),
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final playback = AppScope.of(context).playback;
    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) => IconButton(
        tooltip: AppLocalizations.of(context).listen,
        onPressed: () => playback.toggle(word.id),
        icon: PlayIndicator(isLoading: playback.loadingId == word.id, isPlaying: playback.playingId == word.id),
      ),
    );
  }
}

/// A word in a list: the word, its Kazakh replacement if it has one, and
/// buttons to play it and to save it. Words with usage examples open a
/// detail sheet; tapping the others plays them.
class WordTile extends StatelessWidget {
  const WordTile({super.key, required this.word, this.removed = false});

  final Word word;

  /// A favourite that was deleted from the dictionary.
  final bool removed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: word.hasDetails ? () => showWordDetail(context, word) : () => AppScope.of(context).playback.toggle(word.id),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4, top: 6, bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.word, style: theme.textTheme.bodyLarge),
                  if (word.suggestion != null)
                    Text(word.suggestion!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                  if (removed)
                    Text(l10n.favoriteRemovedFromDictionary,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                ],
              ),
            ),
            PlayButton(word: word),
            FavoriteButton(word: word),
            if (word.hasDetails)
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant)
            else
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

Future<void> showWordDetail(BuildContext context, Word word) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _WordDetail(word: word),
    );

class _WordDetail extends StatelessWidget {
  const _WordDetail({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playback = AppScope.of(context).playback;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word.word, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    if (word.suggestion != null)
                      Text(word.suggestion!,
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
              FavoriteButton(word: word),
            ],
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: playback,
            builder: (context, _) => FilledButton.tonalIcon(
              onPressed: () => playback.toggle(word.id),
              icon: PlayIndicator(
                isLoading: playback.loadingId == word.id,
                isPlaying: playback.playingId == word.id,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              label: Text(AppLocalizations.of(context).listen),
            ),
          ),
          for (final version in word.correctVersions.where((v) => v.hasExamples)) ...[
            const SizedBox(height: 16),
            _UsageCard(version: version),
          ],
        ],
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.version});

  final CorrectVersion version;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final usage = Theme.of(context).extension<UsageColors>()!;
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (version.incorrectUsage?.trim().isNotEmpty ?? false)
              _UsageBlock(label: l10n.detailIncorrect, text: version.incorrectUsage!, color: usage.incorrect),
            if ((version.incorrectUsage?.trim().isNotEmpty ?? false) &&
                (version.correctUsage?.trim().isNotEmpty ?? false))
              const SizedBox(height: 12),
            if (version.correctUsage?.trim().isNotEmpty ?? false)
              _UsageBlock(label: l10n.detailCorrect, text: version.correctUsage!, color: usage.correct),
          ],
        ),
      ),
    );
  }
}

class _UsageBlock extends StatelessWidget {
  const _UsageBlock({required this.label, required this.text, required this.color});

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(text, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
