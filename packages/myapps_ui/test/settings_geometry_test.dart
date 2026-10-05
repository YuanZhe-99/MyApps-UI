import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Verify settings geometry and accessible fallback.
/// Inputs: None. Returns: None. Side effects: Registers tests.
/// Notes: Uses actual parent width and scaled text.
void main() {
  testWidgets('settings segments fill their pane and use equal widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: MyAppsSettingsSegmentRow<int>(
              leading: const Icon(Icons.palette),
              title: 'Theme',
              segments: const [
                ButtonSegment(value: 1, label: Text('Light')),
                ButtonSegment(value: 2, label: Text('Dark')),
              ],
              selected: const {1},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    final control = find.byType(SegmentedButton<int>);
    expect(tester.getSize(control).width, 568);
    expect(tester.getTopLeft(control).dx, 16);
    final first = tester.getCenter(
      find.ancestor(of: find.text('Light'), matching: find.byType(TextButton)),
    );
    final second = tester.getCenter(
      find.ancestor(of: find.text('Dark'), matching: find.byType(TextButton)),
    );
    expect(second.dx - first.dx, closeTo(284, 1));
    expect(tester.takeException(), isNull);
  });
  testWidgets('long labels and large text use full-width vertical choices', (
    tester,
  ) async {
    Set<int>? selection;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 300,
              child: MyAppsSettingsSegments<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Follow the system')),
                  ButtonSegment(value: 2, label: Text('Side on wide screens')),
                ],
                selected: const {1},
                onSelectionChanged: (value) => selection = value,
              ),
            ),
          ),
        ),
      ),
    );
    final control = find.byType(SegmentedButton<int>);
    expect(
      tester.widget<SegmentedButton<int>>(control).direction,
      Axis.vertical,
    );
    expect(tester.getSize(control).width, 300);
    await tester.tap(find.text('Side on wide screens'));
    expect(selection, {2});
    expect(tester.takeException(), isNull);
  });
}
