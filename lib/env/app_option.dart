import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

enum CustomTextDirection {
  localeBased,
  ltr,
  rtl,
}

// See http://en.wikipedia.org/wiki/Right-to-left
const List<String> rtlLanguages = <String>[
  'ar', // Arabic
  'fa', // Farsi
  'he', // Hebrew
  'ps', // Pashto
  'ur', // Urdu
];

// Fake locale to represent the system Locale option.
const systemLocaleOption = Locale('system');

class AppOption {
  final TargetPlatform platform;
  final ThemeMode themeMode;
  final double _textScaleFactor;
  final Locale? _locale;
  final CustomTextDirection customTextDirection;
  final double? timeDilation;

  // isRelease
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  AppOption(
      {required this.platform,
      this.timeDilation,
      this.themeMode = ThemeMode.light,
      double textScaleFactor = -1.0,
      Locale? locale,
      this.customTextDirection = CustomTextDirection.localeBased})
      : _textScaleFactor = textScaleFactor,
        _locale = locale;

  // We use a sentinel value to indicate the system text scale option. By
  // default, return the actual text scale factor, otherwise return the
  // sentinel value.
  double textScaleFactor(BuildContext context, {bool useSentinel = false}) {
    if (_textScaleFactor == systemTextScaleFactorOption) {
      return useSentinel
          ? systemTextScaleFactorOption
          : MediaQuery.of(context).textScaleFactor;
    } else {
      return _textScaleFactor;
    }
  }

  /// Returns a text direction based on the [CustomTextDirection] setting.
  /// If it is based on locale and the locale cannot be determined, returns
  /// null.
  TextDirection? resolvedTextDirection() {
    switch (customTextDirection) {
      case CustomTextDirection.localeBased:
        final language = _locale?.languageCode.toLowerCase();
        if (language == null) return null;
        return rtlLanguages.contains(language)
            ? TextDirection.rtl
            : TextDirection.ltr;
      case CustomTextDirection.rtl:
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }

  /// Returns a [SystemUiOverlayStyle] based on the [ThemeMode] setting.
  /// In other words, if the theme is dark, returns light; if the theme is
  /// light, returns dark.
  SystemUiOverlayStyle resolvedSystemUiOverlayStyle() {
    Brightness brightness;
    switch (themeMode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      default:
        brightness = WidgetsBinding.instance!.window.platformBrightness;
    }

    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return overlayStyle;
  }

  Locale get locale => _locale!;

  @override
  bool operator ==(Object other) =>
      other is AppOption &&
      themeMode == other.themeMode &&
      _textScaleFactor == other._textScaleFactor &&
      customTextDirection == other.customTextDirection &&
      locale == other.locale &&
      timeDilation == other.timeDilation &&
      platform == other.platform;

  @override
  int get hashCode => hashValues(themeMode, _textScaleFactor,
      customTextDirection, locale, timeDilation, platform);

  static AppOption of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_AppOptionChangedNotify>();
    return scope!.appOpstionState.appOpstion;
  }

  static void update(BuildContext context, AppOption appOption) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_AppOptionChangedNotify>();
    scope?.appOpstionState.updateOption(appOption);
  }
}

class _AppOptionChangedNotify extends InheritedWidget {
  _AppOptionChangedNotify(
      {Key? key, required this.appOpstionState, required this.child})
      : super(key: key, child: child);
  final Widget child;
  final AppOptionState appOpstionState;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class ApplicationProvider extends StatefulWidget {
  ApplicationProvider({Key? key, required this.appOpstion, required this.child})
      : super(key: key);
  final Widget child;
  final AppOption appOpstion;

  @override
  State<StatefulWidget> createState() => AppOptionState();
}

class AppOptionState extends State<ApplicationProvider> {
  late AppOption appOpstion;
  Timer? _timeDilationTimer;

  @override
  void initState() {
    super.initState();
    appOpstion = widget.appOpstion;
  }

  @override
  Widget build(BuildContext context) {
    return _AppOptionChangedNotify(appOpstionState: this, child: widget.child);
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  void updateOption(AppOption option) {
    if (option != appOpstion) {
      handlerTimeDilation(option);
      setState(() {
        appOpstion = option;
      });
    }
  }

  void handlerTimeDilation(AppOption option) {
    if (option.timeDilation != option.timeDilation) {
      _timeDilationTimer?.cancel();
      _timeDilationTimer = null;
      if ((option.timeDilation ?? 0) > 1) {
        // We delay the time dilation change long enough that the user can see
        // that UI has started reacting and then we slam on the brakes so that
        // they see that the time is in fact now dilated.
        _timeDilationTimer = Timer(const Duration(milliseconds: 150), () {
          timeDilation = option.timeDilation ?? 0;
        });
      }
    }
  }
}
