import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api.dart';
import 'favorites.dart';
import 'l10n/app_localizations.dart';
import 'locale.dart';
import 'playback.dart';
import 'screens/favorites_screen.dart';
import 'screens/info_screen.dart';
import 'screens/words_screen.dart';
import 'theme.dart';

/// The app's services, available to every widget below it.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.api,
    required this.favorites,
    required this.playback,
    required this.locale,
    required super.child,
  });

  final Api api;
  final FavoritesStore favorites;
  final PlaybackController playback;
  final LocaleController locale;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}

class DurysSoileApp extends StatelessWidget {
  const DurysSoileApp({super.key, required this.scope});

  final AppScope Function(Widget child) scope;

  @override
  Widget build(BuildContext context) => scope(Builder(builder: (context) {
        final locale = AppScope.of(context).locale;
        return ListenableBuilder(
          listenable: locale,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            locale: locale.locale,
            supportedLocales: LocaleController.supported,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeShell(),
          ),
        );
      }));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  StreamSubscription<int>? _failures;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_failures != null) return;
    final scope = AppScope.of(context);
    _failures = scope.playback.failures.listen((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).audioError)),
      );
    });
    // Bring the offline favourites up to date with the backend on start.
    scope.favorites.refresh();
  }

  @override
  void dispose() {
    _failures?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [WordsScreen(), FavoritesScreen(), InfoScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.list_alt), label: l10n.navWords),
          NavigationDestination(
            icon: const Icon(Icons.star_outline),
            selectedIcon: const Icon(Icons.star),
            label: l10n.navFavorites,
          ),
          NavigationDestination(icon: const Icon(Icons.info_outline), label: l10n.navInfo),
        ],
      ),
    );
  }
}
