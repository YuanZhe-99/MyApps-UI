import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Verify palette preservation and style-specific component behavior.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers tests.
/// Notes: Apps own platform eligibility for dynamic color.
void main() {
  test('both styles share palette and body text metrics', () {
    for (final brightness in Brightness.values) {
      for (final seed in [const Color(0xFFCE5B78), const Color(0xFF303F9F)]) {
        final factory = MyAppsTheme(seedColor: seed);
        final classic = factory.build(brightness, null, AppUiStyle.material3);
        final expressive = factory.build(brightness);
        expect(expressive.colorScheme, classic.colorScheme);
        expect(
          classic.colorScheme,
          ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
        );
        expect(expressive.textTheme.bodyMedium, classic.textTheme.bodyMedium);
        expect(
          expressive.textTheme.titleLarge!.fontSize,
          classic.textTheme.titleLarge!.fontSize,
        );
        expect(expressive.textTheme.titleLarge!.fontWeight, FontWeight.w600);
        expect(classic.inputDecorationTheme.border, isA<OutlineInputBorder>());
        expect(expressive.snackBarTheme.behavior, SnackBarBehavior.floating);
        final shape = expressive.filledButtonTheme.style!.shape!;
        expect(shape.resolve({}), isA<StadiumBorder>());
        expect(
          shape.resolve({WidgetState.pressed}),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }
    }
  });
  test('caller-provided dynamic scheme is preserved exactly', () {
    final dynamicScheme = ColorScheme.fromSeed(seedColor: Colors.green);
    const factory = MyAppsTheme(seedColor: Colors.pink);
    expect(
      factory.scheme(Brightness.light, dynamicScheme),
      same(dynamicScheme),
    );
    expect(factory.light(dynamicScheme).colorScheme, dynamicScheme);
    expect(factory.light().brightness, Brightness.light);
    expect(factory.dark().brightness, Brightness.dark);
    expect(AppUiStyle.values.map((value) => value.name), [
      'material3',
      'expressive',
    ]);
    expect(NavPlacement.values.map((value) => value.name), [
      'bottom',
      'sideOnWide',
      'side',
    ]);
  });
  test('custom application base retains card colors and field density', () {
    final base = ThemeData(
      cardTheme: const CardThemeData(elevation: 0, color: Colors.blue),
      inputDecorationTheme: const InputDecorationTheme(isDense: true),
    );
    final expressive = MyAppsTheme.applyStyle(base, AppUiStyle.expressive);
    expect(expressive.cardTheme.color, Colors.blue);
    expect(expressive.cardTheme.elevation, 0);
    expect(expressive.inputDecorationTheme.isDense, isTrue);
    expect(MyAppsTheme.applyStyle(base, AppUiStyle.material3), same(base));
  });
}
