import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum ini bisa Anda pindahkan ke sini dari settingpage.dart
enum AppTheme { orange, blue, green }

class ThemeProvider extends ChangeNotifier {
  Color _mainColor = Colors.orange;
  AppTheme _currentTheme = AppTheme.orange;

  Color get mainColor => _mainColor;
  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    loadTheme();
  }

  // Mengatur tema baru dan memberitahu semua listener
  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    switch (theme) {
      case AppTheme.orange:
        _mainColor = Colors.orange;
        break;
      case AppTheme.blue:
        _mainColor = Colors.blue;
        break;
      case AppTheme.green:
        _mainColor = Colors.green;
        break;
    }

    // Simpan pilihan tema ke memori perangkat
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme_index', theme.index);

    notifyListeners(); // Memberitahu widget lain bahwa ada perubahan
  }

  // Memuat tema yang tersimpan saat aplikasi dibuka
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Baca dari memori, jika tidak ada, default ke orange (index 0)
    int themeIndex = prefs.getInt('theme_index') ?? 0;
    AppTheme savedTheme = AppTheme.values[themeIndex];
    setTheme(savedTheme);
  }
}