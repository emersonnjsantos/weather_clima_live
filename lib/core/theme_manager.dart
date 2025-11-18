import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o estado e a persistência do tema para a aplicação
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs;

  ThemeManager() {
    _loadTheme();
  }

  /// Obtém o modo de tema atual
  ThemeMode get themeMode => _themeMode;

  /// Verifica se o tema atual é escuro
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Verifica se o tema atual é claro
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Carrega o tema das preferências compartilhadas
  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final String? savedTheme = _prefs?.getString(_themeKey);

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = ThemeMode.light;
        }
      }
      notifyListeners();
    } catch (e) {
      // Volta ao tema claro se o carregamento falhar
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }

  /// Alterna entre tema claro e escuro
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Define um modo de tema específico
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await _prefs?.setString(_themeKey, modeString);
    } catch (e) {
      // Trata erro de salvamento de forma elegante
      debugPrint('Falha ao salvar preferência de tema: $e');
    }
  }

  /// Obtém o nome de exibição do modo de tema
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
