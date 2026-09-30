import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The interface language: the device's by default, or one the user picked.
/// The dictionary itself is Kazakh either way.
class LocaleController extends ChangeNotifier {
  static const supported = [Locale('kk'), Locale('ru'), Locale('en')];
  static const _key = 'locale';

  Locale? _locale;

  /// null means "follow the device".
  Locale? get locale => _locale;

  Future<void> load() async {
    final code = (await SharedPreferences.getInstance()).getString(_key);
    _locale = supported.where((l) => l.languageCode == code).firstOrNull;
    notifyListeners();
  }

  Future<void> set(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
