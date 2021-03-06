// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ApplicationThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
        colorScheme: colorScheme,
        textTheme: _textTheme,
        // Matches manifest.json colors and background color.
        primaryColor: const Color(0xFF030303),
        appBarTheme: AppBarTheme(
          textTheme: _textTheme.apply(bodyColor: colorScheme.onPrimary),
          color: colorScheme.background,
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.primary),
          brightness: colorScheme.brightness,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        canvasColor: colorScheme.background,
        scaffoldBackgroundColor: colorScheme.background,
        highlightColor: Colors.transparent,
        accentColor: colorScheme.primary,
        focusColor: focusColor,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.alphaBlend(
            _lightFillColor.withOpacity(0.80),
            _darkFillColor,
          ),
          contentTextStyle: _textTheme.subtitle1?.apply(color: _darkFillColor),
        ),
        cardTheme: CardTheme(color: Colors.grey[850]));
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFFB93C5D),
    primaryVariant: Color(0xFF117378),
    secondary: Color(0xFFEFF3F3),
    secondaryVariant: Color(0xFFFAFBFB),
    background: Color(0xFFE6EBEB),
    surface: Color(0xFFFAFBFB),
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFFFF8383),
    primaryVariant: Color(0xFF1CDEC9),
    secondary: Color(0xFF4D1F7C),
    secondaryVariant: Color(0xFF451B6F),
    background: Color(0xFF241E30),
    surface: Color(0xFF1F1929),
    onBackground: Color(0x0DFFFFFF),
    // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headline1: fontStyle(fontWeight: _bold, fontSize: 36.0),
    headline2:
        fontStyle(fontWeight: _bold, fontSize: 32.0),
    headline3:
        fontStyle(fontWeight: _bold, fontSize: 38.0),
    headline4:
        fontStyle(fontWeight: _bold, fontSize: 26.0),
    headline5:
        fontStyle(fontWeight: _bold, fontSize: 24.0),
    headline6:
        fontStyle(fontWeight: _bold, fontSize: 20.0),
    subtitle1:
        fontStyle(fontWeight: _bold, fontSize: 18.0),
    subtitle2:
        fontStyle(fontWeight: _bold, fontSize: 16.0),
    caption:
        fontStyle(fontWeight: _semiBold, fontSize: 16.0),
    overline:
        fontStyle(fontWeight: _medium, fontSize: 12.0),
    bodyText1: fontStyle(fontWeight: _regular, fontSize: 14.0),
    bodyText2: fontStyle(fontWeight: _regular, fontSize: 16.0),
    button:
        fontStyle(fontWeight: _semiBold, fontSize: 14.0),
  );

  static TextStyle fontStyle(
          {required FontWeight fontWeight, required double fontSize}) =>
      TextStyle(
          fontWeight: fontWeight, fontSize: fontSize, fontFamily: "FiraCode");
}
