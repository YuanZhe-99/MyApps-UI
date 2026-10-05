import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Verify settings callbacks, policy and spacing.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers widget tests.
/// Notes: Application providers are deliberately absent.
void main() {
  testWidgets('segments forward selection and disable without a callback', (
    tester,
  ) async {
    Set<int>? result;
    Widget control(ValueChanged<Set<int>>? callback) => MaterialApp(
      home: Scaffold(
        body: MyAppsSettingsSegments<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('One')),
            ButtonSegment(value: 2, label: Text('Two')),
          ],
          selected: const {1},
          onSelectionChanged: callback,
        ),
      ),
    );
    await tester.pumpWidget(control((selection) => result = selection));
    await tester.tap(find.text('Two'));
    expect(result, {2});
    result = null;
    await tester.pumpWidget(control(null));
    await tester.tap(find.text('Two'));
    expect(result, isNull);
  });
  testWidgets('choice respects width, option count, disabled state and help', (
    tester,
  ) async {
    int? result;
    Widget choice(double width, {bool enabled = true, int count = 2}) =>
        MaterialApp(
          home: Scaffold(
            body: Align(
              child: SizedBox(
                width: width,
                child: MyAppsSettingsChoice<int>(
                  label: 'Choice',
                  value: 1,
                  values: List.generate(count, (i) => i + 1),
                  labelFor: (v) => 'Option $v',
                  helpFor: (v) => 'Help $v',
                  onChanged: (v) => result = v,
                  enabled: enabled,
                  segmentMinWidth: 340,
                  maxSegments: 3,
                ),
              ),
            ),
          ),
        );
    await tester.pumpWidget(choice(400));
    expect(find.text('Help 1'), findsOneWidget);
    await tester.tap(find.text('Option 2'));
    expect(result, 2);
    await tester.pumpWidget(choice(300));
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    await tester.pumpWidget(choice(400, count: 4, enabled: false));
    expect(
      tester
          .widget<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>),
          )
          .onChanged,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('section keeps caller spacing and child widgets', (tester) async {
    const spacing = EdgeInsets.fromLTRB(16, 24, 16, 8);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MyAppsSettingsSection(
            title: 'General',
            headingPadding: spacing,
            children: [Text('Row')],
          ),
        ),
      ),
    );
    expect(find.text('Row'), findsOneWidget);
    expect(
      tester
          .widget<Padding>(
            find
                .ancestor(
                  of: find.text('General'),
                  matching: find.byType(Padding),
                )
                .first,
          )
          .padding,
      spacing,
    );
    expect(tester.takeException(), isNull);
  });
}
