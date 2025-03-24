import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_constants.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: ThemeConstants.lightPrimary,
      secondary: ThemeConstants.lightSecondary,
      tertiary: ThemeConstants.lightTertiary,
      error: ThemeConstants.lightError,
      background: ThemeConstants.lightBackground,
      surface: ThemeConstants.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ThemeConstants.lightOnSurface,
    ),
    scaffoldBackgroundColor: ThemeConstants.lightBackground,
    cardColor: ThemeConstants.lightSurface,
    cardTheme: CardTheme(
      elevation: ThemeConstants.elevationM,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusL)),
      margin: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingS),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      displayLarge: ThemeConstants.displayLarge,
      displayMedium: ThemeConstants.displayMedium,
      displaySmall: ThemeConstants.displaySmall,
      headlineMedium: ThemeConstants.headlineMedium,
      titleLarge: ThemeConstants.titleLarge,
      bodyLarge: ThemeConstants.bodyLarge,
      bodyMedium: ThemeConstants.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingL, vertical: ThemeConstants.spacingM),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusM)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusM)),
      contentPadding: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingM),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    iconTheme: IconThemeData(size: ThemeConstants.spacingL)
  );

  final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: ThemeConstants.darkPrimary,
      secondary: ThemeConstants.darkSecondary,
      tertiary: ThemeConstants.darkTertiary,
      error: ThemeConstants.darkError,
      background: ThemeConstants.darkBackground,
      surface: ThemeConstants.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ThemeConstants.darkOnSurface,
    ),
    scaffoldBackgroundColor: ThemeConstants.darkBackground,
    cardColor: ThemeConstants.darkSurface,
    cardTheme: CardTheme(
      elevation: ThemeConstants.elevationM,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusL)),
      margin: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingS),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      displayLarge: ThemeConstants.displayLarge.copyWith(color: Colors.white),
      displayMedium: ThemeConstants.displayMedium.copyWith(color: Colors.white),
      displaySmall: ThemeConstants.displaySmall.copyWith(color: Colors.white),
      headlineMedium: ThemeConstants.headlineMedium.copyWith(color: Colors.white),
      titleLarge: ThemeConstants.titleLarge.copyWith(color: Colors.white),
      bodyLarge: ThemeConstants.bodyLarge.copyWith(color: ThemeConstants.darkOnSurface),
      bodyMedium: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.darkOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingL, vertical: ThemeConstants.spacingM),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusM)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusM)),
      contentPadding: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingM),
      filled: true,
      fillColor: Color(0xFF2C2C2C),
    ),
    iconTheme: IconThemeData(size: ThemeConstants.spacingL, color: ThemeConstants.darkOnSurface)
  );
}