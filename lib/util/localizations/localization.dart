import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_village/util/localizations/en_strings.dart';
import 'package:school_village/util/localizations/es_strings.dart';

const List<String> _supportedLocales = ["en", "es"];

class LocalizationHelper {
  Locale _locale;

  LocalizationHelper(this._locale);

  static LocalizationHelper of(BuildContext context) => Localizations.of(context, LocalizationHelper);

  String localized(String key) {
    if (this._locale.languageCode == 'es') {
      return es_strings[key] ?? key;
    } else {
      return en_strings[key] ?? key;
    }
  }
}

class LocalizationDelegate extends LocalizationsDelegate<LocalizationHelper> {
  @override
  bool isSupported(Locale locale) {
    return _supportedLocales.contains(locale.languageCode);
  }

  @override
  Future<LocalizationHelper> load(Locale locale) => SynchronousFuture<LocalizationHelper>(LocalizationHelper(locale));

  @override
  bool shouldReload(LocalizationsDelegate old) => false;

}

extension LocalizeResources on State {
  String localize(String key) => LocalizationHelper.of(this.context).localized(key) ?? key;
}

extension LocaizeResources on StatelessWidget {
  String localize(String key, BuildContext context) => LocalizationHelper.of(context).localized(key) ?? key;
}