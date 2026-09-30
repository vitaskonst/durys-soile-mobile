import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// App name, the same in every language.
  ///
  /// In kk, this message translates to:
  /// **'Дұрыс сөйле'**
  String get appTitle;

  /// Bottom navigation: the word lists.
  ///
  /// In kk, this message translates to:
  /// **'Сөздер'**
  String get navWords;

  /// Bottom navigation: saved words.
  ///
  /// In kk, this message translates to:
  /// **'Таңдаулылар'**
  String get navFavorites;

  /// Bottom navigation: about the app.
  ///
  /// In kk, this message translates to:
  /// **'Қосымша туралы'**
  String get navInfo;

  /// Tab: words that are commonly mispronounced.
  ///
  /// In kk, this message translates to:
  /// **'Жиі қате айтылатын сөздер'**
  String get tabMispronounced;

  /// Tab: foreign words with their Kazakh equivalents.
  ///
  /// In kk, this message translates to:
  /// **'Бөгде сөздер'**
  String get tabParasite;

  /// Search field placeholder; searches words by their beginning.
  ///
  /// In kk, this message translates to:
  /// **'Іздейтін сөзіңізді енгізіңіз'**
  String get searchHint;

  /// Button that clears the search field.
  ///
  /// In kk, this message translates to:
  /// **'Тазалау'**
  String get searchClear;

  /// Play a word's pronunciation.
  ///
  /// In kk, this message translates to:
  /// **'Тыңдау'**
  String get listen;

  /// Stop playback.
  ///
  /// In kk, this message translates to:
  /// **'Тоқтату'**
  String get stop;

  /// A search found nothing.
  ///
  /// In kk, this message translates to:
  /// **'Табылмады'**
  String get emptyTitle;

  /// Hint below emptyTitle.
  ///
  /// In kk, this message translates to:
  /// **'Басқа сөзді іздеп көріңіз'**
  String get emptySubtitle;

  /// The word lists could not be loaded.
  ///
  /// In kk, this message translates to:
  /// **'Қызмет уақытша қолжетімсіз'**
  String get errorTitle;

  /// Hint below errorTitle.
  ///
  /// In kk, this message translates to:
  /// **'Интернет байланысын тексеріп, қайталап көріңіз'**
  String get errorSubtitle;

  /// Retry a failed load.
  ///
  /// In kk, this message translates to:
  /// **'Қайталау'**
  String get retry;

  /// A pronunciation could not be played.
  ///
  /// In kk, this message translates to:
  /// **'Дыбысты ойнату мүмкін болмады'**
  String get audioError;

  /// Label of an example sentence using the word wrongly.
  ///
  /// In kk, this message translates to:
  /// **'Дұрыс емес'**
  String get detailIncorrect;

  /// Label of the corrected example sentence.
  ///
  /// In kk, this message translates to:
  /// **'Дұрыс'**
  String get detailCorrect;

  /// Button: save a word to favorites.
  ///
  /// In kk, this message translates to:
  /// **'Таңдаулыларға қосу'**
  String get addFavorite;

  /// Button: remove a word from favorites.
  ///
  /// In kk, this message translates to:
  /// **'Таңдаулылардан алып тастау'**
  String get removeFavorite;

  /// A word could not be saved to favorites (e.g. no internet).
  ///
  /// In kk, this message translates to:
  /// **'Сөзді сақтау мүмкін болмады'**
  String get favoriteSaveError;

  /// Favorites tab with no saved words.
  ///
  /// In kk, this message translates to:
  /// **'Таңдаулы сөздер жоқ'**
  String get favoritesEmptyTitle;

  /// Explains how to add favorites and that they work offline.
  ///
  /// In kk, this message translates to:
  /// **'Сөздің жанындағы ☆ белгісін басып, оны осында сақтаңыз. Таңдаулы сөздерді интернетсіз де тыңдауға болады.'**
  String get favoritesEmptySubtitle;

  /// A saved word that was deleted from the dictionary.
  ///
  /// In kk, this message translates to:
  /// **'Сөздіктен алынып тасталды'**
  String get favoriteRemovedFromDictionary;

  /// Setting: the app's interface language.
  ///
  /// In kk, this message translates to:
  /// **'Тіл'**
  String get language;

  /// Language option: follow the phone's language.
  ///
  /// In kk, this message translates to:
  /// **'Құрылғы тілі'**
  String get languageSystem;

  /// Heading of the About screen.
  ///
  /// In kk, this message translates to:
  /// **'Қосымша туралы'**
  String get infoTitle;

  /// About the app.
  ///
  /// In kk, this message translates to:
  /// **'Қазақ тіліндегі тілдік бірліктердің дұрыс дыбысталуын тыңдауға мүмкіндік беретін бұл қосымша екі бөлімнен тұрады.\n\nБірінші бөлім қазақ тілінде жиі қолданылатын сөздерді дұрыс айтуға, дұрыс дыбыстауға үйретеді.\n\nЕкінші бөлімде күнделікті қолданыстағы, бәлкім қазақша баламасын білмей жүрген бөгде тіл сөздерінің қазақ тіліндегі нұсқасы беріледі. Түсінікті болу үшін олар мысал ретінде сөйлеммен және дұрыс дыбысталуымен берілген. Қосымша қазақ тілінде жақсы сөйлегісі келетіндерге қажетті құралы болады деген сенімдеміз!'**
  String get infoBody;

  /// Acknowledgement.
  ///
  /// In kk, this message translates to:
  /// **'Қосымшаны жасауға мүмкіндік берген Назарбаев Университетіне алғыс білдіреміз.'**
  String get infoThanks;

  /// Grant reference; keep the number as is.
  ///
  /// In kk, this message translates to:
  /// **'Жоба демеушісі туралы сілтеме: 021220FD4351.'**
  String get infoGrant;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
