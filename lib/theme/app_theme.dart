import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      // Основные зеленые цвета из старой темы
      primary: Color(0xFF2E7D32), // Основной акцентный зеленый
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFA5D6A7),
      onPrimaryContainer: Color(0xFF1B5E20),
      secondary: Color(0xFF4CAF50), // Вторичный зеленый
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC8E6C9),
      onSecondaryContainer: Color(0xFF2E7D32),
      tertiary: Color(0xFF81C784),
      onTertiary: Colors.white,

      // Остальные цвета
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: Color(0xFFF8F9FA),
      onBackground: Color(0xFF1A1C1A),
      surface: Color(0xFFFFFFFF), // Белый для карточек
      onSurface: Color(0xFF1A1C1A),
      surfaceVariant: Color(0xFFE8F5E8), // Светло-зеленый для вариантов поверхности
      onSurfaceVariant: Color(0xFF424941),
      outline: Color(0xFF727970),
      outlineVariant: Color(0xFFC2C9BD),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2F312F),
      onInverseSurface: Color(0xFFF0F1EC),
      inversePrimary: Color(0xFFA5D6A7),
    ),
    // Сохраняем обратную совместимость со старым primaryColor
    primaryColor: Color(0xFF2E7D32),
    primaryColorDark: Color(0xFF1B5E20),
    primaryColorLight: Color(0xFF4CAF50),
    scaffoldBackgroundColor: Color(0xFFF8F9FA),
    cardColor: Color(0xFFFFFFFF), // Белые карточки
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
    ),
    fontFamily: 'Inter',

    // AppBar - зеленый как в старой теме
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2E7D32), // Зеленый AppBar
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1C1A),
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1C1A),
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1C1A),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1C1A),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1C1A),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF424941),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF424941),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFE8F5E8).withOpacity(0.6), // Светло-зеленый фон
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(
        color: Color(0xFF424941),
      ),
    ),

    // FAB - зеленый
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    ),

    // Bottom Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      indicatorColor: Color(0xFFE8F5E8), // Светло-зеленый индикатор
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Elevated Button - зеленый
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Filled Button - зеленый
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      // Основные зеленые цвета из старой темы
      primary: Color(0xFF4CAF50), // Основной акцентный зеленый для темной темы
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1B5E20),
      onPrimaryContainer: Color(0xFFA5D6A7),
      secondary: Color(0xFF81C784), // Вторичный зеленый
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF2E7D32),
      onSecondaryContainer: Color(0xFFC8E6C9),
      tertiary: Color(0xFFA5D6A7),
      onTertiary: Colors.black,

      // Остальные цвета
      error: Color(0xFFC42121),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFC42121),
      background: Color(0xFF1A1C1A),
      onBackground: Color(0xFFE2E3DE),
      surface: Color(0xFF242724), // Светлее фона
      onSurface: Color(0xFFE2E3DE),
      surfaceVariant: Color(0xFF2E312E),
      onSurfaceVariant: Color(0xFFC2C9BD),
      outline: Color(0xFF8C9388),
      outlineVariant: Color(0xFF424941),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E3DE),
      onInverseSurface: Color(0xFF1A1C1A),
      inversePrimary: Color(0xFF2E7D32),
    ),
    // Сохраняем обратную совместимость со старым primaryColor
    primaryColor: Color(0xFF4CAF50),
    primaryColorDark: Color(0xFF2E7D32),
    primaryColorLight: Color(0xFF81C784),
    scaffoldBackgroundColor: Color(0xFF1A1C1A),
    cardColor: Color(0xFF242724),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFF242724),
      surfaceTintColor: Colors.transparent,
    ),
    fontFamily: 'Inter',

    // AppBar - зеленый как в старой теме
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1B5E20), // Темно-зеленый AppBar
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE2E3DE),
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E3DE),
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E3DE),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE2E3DE),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE2E3DE),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFC2C9BD),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFFC2C9BD),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2E312E).withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(
        color: Color(0xFFC2C9BD),
      ),
    ),

    // FAB - зеленый
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    ),

    // Bottom Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFF242724),
      indicatorColor: Color(0xFF1B5E20), // Темно-зеленый индикатор
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Elevated Button - зеленый
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Filled Button - зеленый
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}