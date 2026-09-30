import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../word_list.dart';
import '../widgets/word_list_view.dart';

/// Both word lists, as tabs, under one search field.
class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final _search = TextEditingController();
  late final List<WordListController> _lists;
  Timer? _debounce;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final api = AppScope.of(context).api;
    _lists = [
      WordListController(api, WordType.mispronounced),
      WordListController(api, WordType.parasite),
    ];
    for (final list in _lists) {
      list.search('');
    }
    _search.addListener(() => setState(() {})); // the clear button
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    // Typing should not fire a request per keystroke, but clearing the
    // field should feel instant.
    _debounce = Timer(query.isEmpty ? Duration.zero : const Duration(milliseconds: 300), () {
      for (final list in _lists) {
        if (list.query != query.trim()) list.search(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    for (final list in _lists) {
      list.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(128),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: _onQueryChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.searchClear,
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _search.clear();
                                _onQueryChanged('');
                              },
                            ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      isDense: true,
                    ),
                  ),
                ),
                TabBar(tabs: [
                  Tab(child: Text(l10n.tabMispronounced, textAlign: TextAlign.center, maxLines: 2)),
                  Tab(child: Text(l10n.tabParasite, textAlign: TextAlign.center, maxLines: 2)),
                ]),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [for (final list in _lists) WordListView(controller: list)]),
      ),
    );
  }
}
