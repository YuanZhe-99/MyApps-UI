import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Exercise measured constraints and content-state retention.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers widget tests.
/// Notes: Checks placement, direction, style and resizing on one live page.
void main() {
  const destinations = [
    MyAppsDestination(icon: Icon(Icons.home), label: '首页'),
    MyAppsDestination(icon: Icon(Icons.settings), label: '设置'),
  ];
  testWidgets('actual width and page state survive all navigation changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 720);
    addTearDown(tester.view.reset);
    final page = GlobalKey<_ProbeState>();
    double measured = 0;
    Future<void> pump(
      NavPlacement placement, {
      bool right = false,
      AppUiStyle style = AppUiStyle.expressive,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyAppsNavigationShell(
            destinations: destinations,
            selectedIndex: 0,
            onSelected: (_) {},
            placement: placement,
            railOnRight: right,
            style: style,
            child: _Probe(key: page, onWidth: (value) => measured = value),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pump(NavPlacement.bottom);
    final state = page.currentState;
    expect(measured, 1000);
    await tester.tap(find.text('increment'));
    await tester.pump();
    expect(state!.count, 1);
    await pump(NavPlacement.sideOnWide);
    expect(measured, 919);
    expect(page.currentState, same(state));
    await pump(NavPlacement.side, right: true);
    expect(measured, 919);
    expect(page.currentState, same(state));
    tester.view.physicalSize = const Size(412, 915);
    await pump(NavPlacement.side);
    expect(measured, 331);
    await pump(NavPlacement.sideOnWide);
    expect(measured, 412);
    await pump(NavPlacement.bottom, style: AppUiStyle.material3);
    expect(page.currentState, same(state));
    expect(state.count, 1);
  });
  testWidgets('short rail and enlarged text fit without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(915, 300);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(915, 300),
            textScaler: TextScaler.linear(2),
          ),
          child: MyAppsNavigationShell(
            destinations: destinations,
            selectedIndex: 0,
            onSelected: (_) {},
            placement: NavPlacement.side,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(NavigationRail)).width,
      greaterThanOrEqualTo(160),
    );
  });
}

class _Probe extends StatefulWidget {
  final ValueChanged<double> onWidth;

  /// Purpose: Construct a state-retention probe.
  /// Inputs: `onWidth`, `key`.
  /// Returns: Probe widget.
  /// Side effects: None.
  /// Notes: Test-only.
  const _Probe({super.key, required this.onWidth});

  /// Purpose: Create the mutable probe state.
  /// Inputs: None.
  /// Returns: Probe state.
  /// Side effects: None.
  /// Notes: Test-only.
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  int count = 0;

  /// Purpose: Report inherited width and expose a stateful counter.
  /// Inputs: `context`.
  /// Returns: Counter button.
  /// Side effects: Reports width and increments state on tap.
  /// Notes: Test-only.
  @override
  Widget build(BuildContext context) {
    widget.onWidth(MyAppsShellLayout.maybeOf(context)!.contentWidth);
    return Center(
      child: TextButton(
        onPressed: () => setState(() => count++),
        child: const Text('increment'),
      ),
    );
  }
}
