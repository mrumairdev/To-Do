import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../theme/app_theme_variant.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs) {
    _variant = AppThemeVariant.fromStorage(
      _prefs.getString(_themeKey),
    );
  }

  static const String _themeKey = 'app_theme_variant';

  final SharedPreferences _prefs;
  late AppThemeVariant _variant;

  AppThemeVariant get variant => _variant;

  ThemeData get themeData => AppTheme.themeFor(_variant);

  Future<void> setVariant(AppThemeVariant variant) async {
    if (_variant == variant) {
      return;
    }

    _variant = variant;
    await _prefs.setString(_themeKey, variant.storageKey);
    notifyListeners();
  }
}
