// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Дұрыс сөйле';

  @override
  String get navWords => 'Слова';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navInfo => 'О приложении';

  @override
  String get tabMispronounced => 'Часто произносимые с ошибкой';

  @override
  String get tabParasite => 'Иноязычные слова';

  @override
  String get searchHint => 'Введите слово для поиска';

  @override
  String get searchClear => 'Очистить';

  @override
  String get listen => 'Слушать';

  @override
  String get stop => 'Остановить';

  @override
  String get emptyTitle => 'Ничего не найдено';

  @override
  String get emptySubtitle => 'Попробуйте другое слово';

  @override
  String get errorTitle => 'Сервис временно недоступен';

  @override
  String get errorSubtitle =>
      'Проверьте подключение к интернету и попробуйте снова';

  @override
  String get retry => 'Повторить';

  @override
  String get audioError => 'Не удалось воспроизвести звук';

  @override
  String get detailIncorrect => 'Неправильно';

  @override
  String get detailCorrect => 'Правильно';

  @override
  String get addFavorite => 'Добавить в избранное';

  @override
  String get removeFavorite => 'Удалить из избранного';

  @override
  String get favoriteSaveError => 'Не удалось сохранить слово';

  @override
  String get favoritesEmptyTitle => 'В избранном пока пусто';

  @override
  String get favoritesEmptySubtitle =>
      'Нажмите ☆ рядом со словом, чтобы сохранить его здесь. Избранные слова можно слушать без интернета.';

  @override
  String get favoriteRemovedFromDictionary => 'Удалено из словаря';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Язык устройства';

  @override
  String get infoTitle => 'О приложении';

  @override
  String get infoBody =>
      'Это приложение позволяет прослушать правильное произношение слов и выражений казахского языка. Оно состоит из двух разделов.\n\nПервый раздел учит правильно произносить часто употребляемые казахские слова.\n\nВо втором разделе приводятся казахские варианты иноязычных слов, которые встречаются в повседневной речи и казахские аналоги которых вы, возможно, не знаете. Для наглядности они даны с примерами предложений и правильным произношением. Мы уверены, что приложение станет полезным инструментом для всех, кто хочет хорошо говорить по-казахски!';

  @override
  String get infoThanks =>
      'Благодарим Назарбаев Университет за возможность создать это приложение.';

  @override
  String get infoGrant => 'Ссылка на спонсора проекта: 021220FD4351.';
}
