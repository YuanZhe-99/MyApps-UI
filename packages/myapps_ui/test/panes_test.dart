import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Verify feature-aware panes and multi-region policies.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers tests.
/// Notes: Features simulate platform reporting.
void main() {
  testWidgets('reference sizes and separator fallback avoid obstruction', (
    tester,
  ) async {
    for (final size in const [
      Size(933, 704),
      Size(704, 933),
      Size(791, 820),
      Size(659, 791),
      Size(1024, 768),
      Size(768, 1024),
      Size(412, 915),
      Size(915, 412),
      Size(1000, 720),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final gate =
          size.width >= 600 &&
          size.height >= 480 &&
          size.width / size.height >= .82;
      bool? split;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              displayFeatures: [
                DisplayFeature(
                  bounds: Rect.fromLTWH(size.width / 2, 0, 0, size.height),
                  type: DisplayFeatureType.fold,
                  state: DisplayFeatureState.postureHalfOpened,
                ),
              ],
            ),
            child: MyAppsPaneLayout(
              primary: const Text('P'),
              secondary: const Text('S'),
              allowSplit: gate,
              primaryWidth: 300,
              primaryMinWidth: 240,
              secondaryMinWidth: 280,
              contentBounds: Offset.zero & size,
              onSplitChanged: (v) => split = v,
            ),
          ),
        ),
      );
      expect(split, gate && size.width / 2 >= 280);
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('P'),
                    matching: find.byType(MediaQuery),
                  )
                  .first,
            )
            .width,
        lessThanOrEqualTo(size.width / 2),
      );
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  testWidgets(
    'vertical and horizontal separators preserve usable local geometry',
    (tester) async {
      for (final horizontal in [false, true]) {
        tester.view.physicalSize = const Size(1000, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Size? local;
        bool? split;
        final feature = DisplayFeature(
          bounds: horizontal
              ? const Rect.fromLTWH(0, 340, 1000, 20)
              : const Rect.fromLTWH(480, 0, 20, 700),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(1000, 700),
                displayFeatures: [feature],
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 1000,
                  height: 700,
                  child: MyAppsPaneLayout(
                    contentBounds: const Rect.fromLTWH(0, 0, 1000, 700),
                    primary: Builder(
                      builder: (context) {
                        local = MediaQuery.sizeOf(context);
                        return const Text('primary');
                      },
                    ),
                    secondary: const Text('secondary'),
                    allowSplit: true,
                    primaryWidth: 400,
                    primaryMinWidth: 240,
                    secondaryMinWidth: 280,
                    onSplitChanged: (value) => split = value,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(split, true);
        expect(
          local,
          horizontal ? const Size(1000, 340) : const Size(480, 700),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'automatic selected and designed regions support more than two children',
    (tester) async {
      Future<void> render({int preference = 0, List<Rect>? design}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1000, 700)),
              child: SizedBox.expand(
                child: MyAppsRegionLayout(
                  contentBounds: const Rect.fromLTWH(0, 0, 1000, 700),
                  minRegionWidth: 200,
                  preferredColumns: preference,
                  designedRegions: design,
                  children: const [Text('A'), Text('B'), Text('C')],
                ),
              ),
            ),
          ),
        );
      }

      await render();
      expect(
        tester.getTopLeft(find.text('A')).dy,
        tester.getTopLeft(find.text('C')).dy,
      );
      await render(preference: 1);
      expect(
        tester.getTopLeft(find.text('C')).dy,
        greaterThan(tester.getTopLeft(find.text('A')).dy),
      );
      await render(
        design: const [
          Rect.fromLTWH(0, 0, .5, 1),
          Rect.fromLTWH(.5, 0, .5, .5),
          Rect.fromLTWH(.5, .5, .5, .5),
        ],
      );
      expect(
        tester.getTopLeft(find.text('B')).dx,
        tester.getTopLeft(find.text('C')).dx,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
