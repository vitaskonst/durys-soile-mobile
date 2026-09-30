// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Дұрыс сөйле';

  @override
  String get navWords => 'Сөздер';

  @override
  String get navFavorites => 'Таңдаулылар';

  @override
  String get navInfo => 'Қосымша туралы';

  @override
  String get tabMispronounced => 'Жиі қате айтылатын сөздер';

  @override
  String get tabParasite => 'Бөгде сөздер';

  @override
  String get searchHint => 'Іздейтін сөзіңізді енгізіңіз';

  @override
  String get searchClear => 'Тазалау';

  @override
  String get listen => 'Тыңдау';

  @override
  String get stop => 'Тоқтату';

  @override
  String get emptyTitle => 'Табылмады';

  @override
  String get emptySubtitle => 'Басқа сөзді іздеп көріңіз';

  @override
  String get errorTitle => 'Қызмет уақытша қолжетімсіз';

  @override
  String get errorSubtitle => 'Интернет байланысын тексеріп, қайталап көріңіз';

  @override
  String get retry => 'Қайталау';

  @override
  String get audioError => 'Дыбысты ойнату мүмкін болмады';

  @override
  String get detailIncorrect => 'Дұрыс емес';

  @override
  String get detailCorrect => 'Дұрыс';

  @override
  String get addFavorite => 'Таңдаулыларға қосу';

  @override
  String get removeFavorite => 'Таңдаулылардан алып тастау';

  @override
  String get favoriteSaveError => 'Сөзді сақтау мүмкін болмады';

  @override
  String get favoritesEmptyTitle => 'Таңдаулы сөздер жоқ';

  @override
  String get favoritesEmptySubtitle =>
      'Сөздің жанындағы ☆ белгісін басып, оны осында сақтаңыз. Таңдаулы сөздерді интернетсіз де тыңдауға болады.';

  @override
  String get favoriteRemovedFromDictionary => 'Сөздіктен алынып тасталды';

  @override
  String get language => 'Тіл';

  @override
  String get languageSystem => 'Құрылғы тілі';

  @override
  String get infoTitle => 'Қосымша туралы';

  @override
  String get infoBody =>
      'Қазақ тіліндегі тілдік бірліктердің дұрыс дыбысталуын тыңдауға мүмкіндік беретін бұл қосымша екі бөлімнен тұрады.\n\nБірінші бөлім қазақ тілінде жиі қолданылатын сөздерді дұрыс айтуға, дұрыс дыбыстауға үйретеді.\n\nЕкінші бөлімде күнделікті қолданыстағы, бәлкім қазақша баламасын білмей жүрген бөгде тіл сөздерінің қазақ тіліндегі нұсқасы беріледі. Түсінікті болу үшін олар мысал ретінде сөйлеммен және дұрыс дыбысталуымен берілген. Қосымша қазақ тілінде жақсы сөйлегісі келетіндерге қажетті құралы болады деген сенімдеміз!';

  @override
  String get infoThanks =>
      'Қосымшаны жасауға мүмкіндік берген Назарбаев Университетіне алғыс білдіреміз.';

  @override
  String get infoGrant => 'Жоба демеушісі туралы сілтеме: 021220FD4351.';
}
