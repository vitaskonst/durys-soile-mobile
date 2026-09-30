// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Дұрыс сөйле';

  @override
  String get navWords => 'Words';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navInfo => 'About';

  @override
  String get tabMispronounced => 'Commonly mispronounced';

  @override
  String get tabParasite => 'Foreign words';

  @override
  String get searchHint => 'Search for a word';

  @override
  String get searchClear => 'Clear';

  @override
  String get listen => 'Listen';

  @override
  String get stop => 'Stop';

  @override
  String get emptyTitle => 'Nothing found';

  @override
  String get emptySubtitle => 'Try another word';

  @override
  String get errorTitle => 'The service is temporarily unavailable';

  @override
  String get errorSubtitle => 'Check your internet connection and try again';

  @override
  String get retry => 'Retry';

  @override
  String get audioError => 'Could not play the audio';

  @override
  String get detailIncorrect => 'Incorrect';

  @override
  String get detailCorrect => 'Correct';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get favoriteSaveError => 'Could not save the word';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Tap ☆ next to a word to keep it here. Favorites play without an internet connection.';

  @override
  String get favoriteRemovedFromDictionary => 'No longer in the dictionary';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get infoTitle => 'About the app';

  @override
  String get infoBody =>
      'This app lets you listen to the correct pronunciation of Kazakh words and expressions. It has two sections.\n\nThe first teaches you to pronounce commonly used Kazakh words correctly.\n\nThe second gives the Kazakh equivalents of foreign words used in everyday speech, whose Kazakh counterparts you may not know. Each comes with example sentences and its correct pronunciation. We believe the app will be a useful tool for everyone who wants to speak Kazakh well!';

  @override
  String get infoThanks =>
      'We thank Nazarbayev University for making this app possible.';

  @override
  String get infoGrant => 'Project sponsor reference: 021220FD4351.';
}
