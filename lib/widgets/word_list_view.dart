import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../word_list.dart';
import 'common.dart';
import 'word_tile.dart';

/// A word list that loads the next page as the user nears its end.
class WordListView extends StatefulWidget {
  const WordListView({super.key, required this.controller});

  final WordListController controller;

  @override
  State<WordListView> createState() => _WordListViewState();
}

// Keep-alive: switching tabs must not throw away a scrolled, loaded list.
class _WordListViewState extends State<WordListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final list = widget.controller;
        if (list.isInitial) {
          if (list.error != null) {
            return Center(
              child: MessageState(title: l10n.errorTitle, subtitle: l10n.errorSubtitle, onRetry: list.retry),
            );
          }
          if (list.done) {
            return Center(child: MessageState(title: l10n.emptyTitle, subtitle: l10n.emptySubtitle));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final items = list.items;
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Start loading the next page a screen before the end.
            if (notification.metrics.extentAfter < 600) list.loadMore();
            return false;
          },
          child: ListView.separated(
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) {
              if (index < items.length) return WordTile(word: items[index]);
              if (list.error != null) {
                return MessageState(title: l10n.errorTitle, subtitle: l10n.errorSubtitle, onRetry: list.retry);
              }
              if (list.done) return const SizedBox(height: 8);
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            },
          ),
        );
      },
    );
  }
}
