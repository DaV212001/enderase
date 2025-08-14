import 'package:flutter/material.dart';

import '../constants/constants.dart';

ColorScheme appColor([bool? isDark]) => ColorScheme.fromSeed(
  seedColor: AppConstants.primaryColor,
  primary: AppConstants.primaryColor,
  secondary: AppConstants.secondaryColor,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  surface: (isDark ?? false)
      ? const Color(0xFF1D2428)
      : const Color(0xFFF1F4F8),
  brightness: isDark == null
      ? Brightness.light
      : isDark
      ? Brightness.dark
      : Brightness.light,
);

// Cache to store the theme based on the isDark parameter
Map<bool?, ThemeData> _themeCache = {};

ThemeData appTheme(BuildContext context, {bool? isDark}) {
  // Check if the theme for this isDark parameter is already cached
  if (_themeCache.containsKey(isDark)) {
    return _themeCache[isDark]!;
  }

  // If not cached, create the theme
  ColorScheme themeColor = appColor(isDark);
  ThemeData theme = ThemeData(
    primaryColor: themeColor.primary,
    colorScheme: themeColor,
    fontFamily: 'Lexend',
    useMaterial3: true,
    scaffoldBackgroundColor: (isDark ?? true)
        ? Color(0xFF1D2428)
        : const Color(0xFFF1F4F8),
    appBarTheme: AppBarTheme(
      color: isDark == true ? themeColor.secondary : null,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontFamily: 'Lexend',
        color: isDark == true ? Colors.white : Colors.black,
      ),
    ),
    cardColor: isDark == true ? const Color(0xFF111823) : Colors.white,
    tabBarTheme: TabBarThemeData(
      labelStyle: TextStyle(
        color: (isDark ?? true) ? Colors.white : themeColor.primary,
        fontFamily: 'Lexend',
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        color: (isDark ?? true)
            ? AppConstants.primaryColor.withValues(alpha: 0.5)
            : Colors.black,
        fontFamily: 'Lexend',
      ),
      unselectedLabelColor: (isDark ?? true)
          ? themeColor.primary.withValues(alpha: 0.5)
          : Colors.black,
    ),
    // scaffoldBackgroundColor: (isDark ?? true)
    //     ? themeColor.surface
    //     : const Color(0xFFF8F6F6),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        backgroundColor: WidgetStatePropertyAll(themeColor.primary),
      ),
    ),
  );

  // Cache the newly created theme
  _themeCache[isDark] = theme;

  // Return the newly created theme
  return theme;
}
