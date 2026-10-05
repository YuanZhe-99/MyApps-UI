import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'appearance.dart';

class MyAppsTheme {
  /// Purpose: Configure the shared theme with an application brand color.
  /// Inputs: `seedColor` — the application brand color.
  /// Returns: A configured `MyAppsTheme` instance.
  /// Side effects: None.
  /// Notes: Dynamic-color platform policy belongs to the caller.
  const MyAppsTheme({required this.seedColor});

  /// Brand seed used when the caller supplies no dynamic color scheme.
  final Color seedColor;

  /// How long Expressive buttons take to morph between their resting and
  /// pressed shapes.
  static const Duration _morphDuration = Duration(milliseconds: 200);

  /// Purpose: Resolve the color scheme for one brightness.
  /// Inputs: `brightness`; `dynamicScheme` — the platform's wallpaper-derived
  /// scheme for that brightness, or null.
  /// Returns: `ColorScheme` — the dynamic scheme when given, otherwise
  /// `ColorScheme.fromSeed(seedColor)`.
  /// Side effects: None.
  /// Notes: Which platforms may pass a dynamic scheme is decided by the caller
  /// (the existing apps allow Android only). Both styles share the same
  /// colors, so switching style never changes the palette.
  ColorScheme scheme(Brightness brightness, [ColorScheme? dynamicScheme]) =>
      dynamicScheme ??
      ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);

  /// Purpose: Build the theme for one brightness and style.
  /// Inputs: `brightness`; `dynamicScheme` — optional platform scheme;
  /// `style` — defaults to [AppUiStyle.expressive].
  /// Returns: `ThemeData`.
  /// Side effects: None.
  /// Notes: Material 3 is Flutter's stock theme plus outlined text fields,
  /// which keep every form looking as it did before extraction. Expressive layers
  /// [_expressive] on top of exactly that theme, so the two differ only in
  /// shape, type weight and component details, never in layout or color.
  ThemeData build(
    Brightness brightness, [
    ColorScheme? dynamicScheme,
    AppUiStyle style = AppUiStyle.expressive,
  ]) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme(brightness, dynamicScheme),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
    return applyStyle(base, style);
  }

  /// Purpose: Apply shared component styling to an application-owned base theme.
  /// Inputs: `base` — existing theme; `style` — requested interface style.
  /// Returns: The base theme or its Expressive variant.
  /// Side effects: None.
  /// Notes: Keeps existing card customization and field density.
  static ThemeData applyStyle(ThemeData base, AppUiStyle style) =>
      style == AppUiStyle.expressive ? _expressive(base) : base;

  /// Purpose: Return a button style whose shape morphs when pressed.
  /// Inputs: None.
  /// Returns: `ButtonStyle` — pill at rest, rounded square while pressed.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only. `Material` animates
  /// between the two shapes over [_morphDuration], approximating the
  /// Expressive shape-morph without a custom widget. Size and padding are
  /// untouched, so no layout moves.
  static ButtonStyle _morphingButtonStyle() => ButtonStyle(
    animationDuration: _morphDuration,
    shape: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.pressed)
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          : const StadiumBorder(),
    ),
  );

  /// Purpose: Make display, headline and title styles heavier.
  /// Inputs: `text` — the base theme's text theme.
  /// Returns: `TextTheme` with emphasized weights.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only. Approximates the
  /// Expressive "emphasized" type scale by weight only; sizes and line heights
  /// stay stock, so no text reflows. Body and label styles are unchanged.
  static TextTheme _emphasized(TextTheme text) {
    /// Purpose: Apply a font weight to an optional text style.
    /// Inputs: `s`, `w`.
    /// Returns: TextStyle or null.
    /// Side effects: None.
    /// Notes: Internal theme helper.
    TextStyle? bold(TextStyle? s, FontWeight w) => s?.copyWith(fontWeight: w);
    return text.copyWith(
      displayLarge: bold(text.displayLarge, FontWeight.w500),
      displayMedium: bold(text.displayMedium, FontWeight.w500),
      displaySmall: bold(text.displaySmall, FontWeight.w500),
      headlineLarge: bold(text.headlineLarge, FontWeight.w600),
      headlineMedium: bold(text.headlineMedium, FontWeight.w600),
      headlineSmall: bold(text.headlineSmall, FontWeight.w600),
      titleLarge: bold(text.titleLarge, FontWeight.w600),
      titleMedium: bold(text.titleMedium, FontWeight.w600),
      titleSmall: bold(text.titleSmall, FontWeight.w600),
    );
  }

  /// Purpose: Layer the Material 3 Expressive approximation onto a theme.
  /// Inputs: `base` — the stock Material 3 theme from [build].
  /// Returns: `ThemeData`.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only. Theme-level only:
  /// larger corner radii (cards, dialogs, sheets, menus, chips, fields, FAB,
  /// snack bars), press-to-morph buttons, emphasized title weights, the
  /// 2024 progress-indicator and slider designs, and the fade-forward page
  /// transition. Spring motion, wavy indicators, button groups and other
  /// Expressive components have no Flutter equivalent and are not imitated.
  static ThemeData _expressive(ThemeData base) {
    final cs = base.colorScheme;
    final morph = _morphingButtonStyle();

    /// Purpose: Construct a rounded component shape.
    /// Inputs: `r` — corner radius.
    /// Returns: RoundedRectangleBorder.
    /// Side effects: None.
    /// Notes: Internal theme helper.
    RoundedRectangleBorder rounded(double r) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

    /// Purpose: Construct an outlined field border.
    /// Inputs: `color`, `width`.
    /// Returns: OutlineInputBorder.
    /// Side effects: None.
    /// Notes: Internal theme helper.
    OutlineInputBorder field(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      textTheme: _emphasized(base.textTheme),
      filledButtonTheme: FilledButtonThemeData(style: morph),
      elevatedButtonTheme: ElevatedButtonThemeData(style: morph),
      outlinedButtonTheme: OutlinedButtonThemeData(style: morph),
      textButtonTheme: TextButtonThemeData(style: morph),
      iconButtonTheme: IconButtonThemeData(style: morph),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(animationDuration: _morphDuration),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: rounded(20),
      ),
      cardTheme: base.cardTheme.copyWith(shape: rounded(20)),
      dialogTheme: DialogThemeData(shape: rounded(32)),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(shape: rounded(16)),
      menuTheme: MenuThemeData(
        style: MenuStyle(shape: WidgetStatePropertyAll(rounded(16))),
      ),
      chipTheme: ChipThemeData(shape: rounded(12)),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded(16),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: field(cs.outline),
        enabledBorder: field(cs.outline),
        focusedBorder: field(cs.primary, 2),
        errorBorder: field(cs.error),
        focusedErrorBorder: field(cs.error, 2),
        disabledBorder: field(cs.onSurface.withValues(alpha: 0.12)),
      ),
      // `year2023: false` is the only opt-in to the 2024 indicator and slider
      // designs; it is deprecated only because false will become the default.
      // ignore: deprecated_member_use
      progressIndicatorTheme: const ProgressIndicatorThemeData(year2023: false),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Purpose: Return the light theme used by the app.
  /// Inputs: `dynamicScheme` — optional light platform scheme; `style`.
  /// Returns: `ThemeData`.
  /// Side effects: None.
  /// Notes: None.
  ThemeData light([
    ColorScheme? dynamicScheme,
    AppUiStyle style = AppUiStyle.expressive,
  ]) => build(Brightness.light, dynamicScheme, style);

  /// Purpose: Return the dark theme used by the app.
  /// Inputs: `dynamicScheme` — optional dark platform scheme; `style`.
  /// Returns: `ThemeData`.
  /// Side effects: None.
  /// Notes: None.
  ThemeData dark([
    ColorScheme? dynamicScheme,
    AppUiStyle style = AppUiStyle.expressive,
  ]) => build(Brightness.dark, dynamicScheme, style);
}
