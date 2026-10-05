import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;
import 'package:flutter/material.dart';
import 'navigation.dart';

/// A scaffold-body adapter for application-designed master/detail regions.
class MyAppsPaneBody extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final bool allowSplit;
  final double Function(double width) primaryWidthFor;
  final ValueChanged<bool> onSplitChanged;
  final double primaryMinWidth;
  final double secondaryMinWidth;
  final double topInset;

  /// Purpose: Adapt app scaffold content to shared pane coordinates.
  /// Inputs: Panes, policy, widths, app-bar top inset and routing callback.
  /// Returns: Body adapter.
  /// Side effects: None.
  /// Notes: Top inset includes this page's app bar and consumed status padding.
  const MyAppsPaneBody({
    super.key,
    required this.primary,
    required this.secondary,
    required this.allowSplit,
    required this.primaryWidthFor,
    required this.onSplitChanged,
    required this.topInset,
    this.primaryMinWidth = 240,
    this.secondaryMinWidth = 280,
  });

  /// Purpose: Resolve shell origin and actual body constraints.
  /// Inputs: `context`.
  /// Returns: Shared pane layout.
  /// Side effects: Reports the actual split mode.
  /// Notes: Full-window routes use a zero shell origin.
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final origin =
          MyAppsShellLayout.maybeOf(context)?.contentBounds?.topLeft ??
          Offset.zero;
      return MyAppsPaneLayout(
        primary: primary,
        secondary: secondary,
        allowSplit: allowSplit,
        primaryWidth: primaryWidthFor(box.maxWidth),
        primaryMinWidth: primaryMinWidth,
        secondaryMinWidth: secondaryMinWidth,
        contentBounds: Rect.fromLTWH(
          origin.dx,
          origin.dy + topInset,
          box.maxWidth,
          box.maxHeight,
        ),
        onSplitChanged: onSplitChanged,
      );
    },
  );
}

/// App-owned panes partitioned around separating window display features.
class MyAppsPaneLayout extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final bool allowSplit;
  final double primaryWidth;
  final double primaryMinWidth;
  final double secondaryMinWidth;
  final double paneMinHeight;
  final Rect contentBounds;
  final ValueChanged<bool>? onSplitChanged;

  /// Purpose: Bind app panes and constraints to a window-coordinate content box.
  /// Inputs: Panes, split gate, preferred/minimum sizes, bounds and mode callback.
  /// Returns: Pane layout.
  /// Side effects: None.
  /// Notes: Mode callback may cache routing state but must not call setState.
  const MyAppsPaneLayout({
    super.key,
    required this.primary,
    required this.secondary,
    required this.allowSplit,
    required this.primaryWidth,
    required this.primaryMinWidth,
    required this.secondaryMinWidth,
    required this.contentBounds,
    this.paneMinHeight = 160,
    this.onSplitChanged,
  });

  /// Purpose: Partition actual content and publish pane-local media geometry.
  /// Inputs: `context`.
  /// Returns: Stable stack of pane regions.
  /// Side effects: Reports effective split mode to the caller.
  /// Notes: Separators never override the caller's window split gate.
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final media = MediaQuery.of(context);
      final bounds = Rect.fromLTWH(
        contentBounds.left,
        contentBounds.top,
        box.maxWidth,
        box.maxHeight,
      );
      var regions = <Rect>[bounds];
      for (final feature in media.displayFeatures) {
        final f = feature.bounds;
        final separating =
            f.width > 0 && f.height > 0 ||
            feature.state == DisplayFeatureState.postureHalfOpened;
        if (!separating || feature.type == DisplayFeatureType.cutout) continue;
        final next = <Rect>[];
        for (final region in regions) {
          if (f.left >= region.left &&
              f.right <= region.right &&
              f.top <= region.top &&
              f.bottom >= region.bottom &&
              f.left > region.left &&
              f.right < region.right) {
            next.add(
              Rect.fromLTRB(region.left, region.top, f.left, region.bottom),
            );
            next.add(
              Rect.fromLTRB(f.right, region.top, region.right, region.bottom),
            );
          } else if (f.top >= region.top &&
              f.bottom <= region.bottom &&
              f.left <= region.left &&
              f.right >= region.right &&
              f.top > region.top &&
              f.bottom < region.bottom) {
            next.add(
              Rect.fromLTRB(region.left, region.top, region.right, f.top),
            );
            next.add(
              Rect.fromLTRB(region.left, f.bottom, region.right, region.bottom),
            );
          } else {
            next.add(region);
          }
        }
        regions = next;
      }
      regions.sort(
        (a, b) => (b.width * b.height).compareTo(a.width * a.height),
      );
      Rect first = regions.first;
      Rect? second;
      if (regions.length > 1) {
        final pair = regions.take(2).toList()
          ..sort((a, b) {
            final vertical = a.top.compareTo(b.top);
            return vertical == 0 ? a.left.compareTo(b.left) : vertical;
          });
        if (allowSplit &&
            pair[0].width >= primaryMinWidth &&
            pair[1].width >= secondaryMinWidth &&
            pair.every((r) => r.height >= paneMinHeight)) {
          first = pair[0];
          second = pair[1];
        }
      } else if (allowSplit &&
          bounds.width >= primaryMinWidth + secondaryMinWidth + 1) {
        final width = primaryWidth.clamp(
          primaryMinWidth,
          bounds.width - secondaryMinWidth - 1,
        );
        first = Rect.fromLTWH(bounds.left, bounds.top, width, bounds.height);
        second = Rect.fromLTRB(
          first.right + 1,
          bounds.top,
          bounds.right,
          bounds.bottom,
        );
      }
      onSplitChanged?.call(second != null);
      return Stack(
        fit: StackFit.expand,
        children: [
          _pane(media, bounds, first, primary, regions.length > 1),
          if (second != null)
            _pane(media, bounds, second, secondary, regions.length > 1),
          if (second != null && regions.length == 1)
            Positioned(
              left: first.right - bounds.left,
              top: 0,
              bottom: 0,
              width: 1,
              child: const VerticalDivider(width: 1),
            ),
        ],
      );
    },
  );

  /// Purpose: Place a pane and translate window geometry to its region.
  /// Inputs: Window media, content bounds, region and pane widget.
  /// Returns: Positioned pane with local MediaQuery.
  /// Side effects: None.
  /// Notes: Region edges retain only overlapping system and keyboard insets.
  Widget _pane(
    MediaQueryData media,
    Rect bounds,
    Rect region,
    Widget child,
    bool partitioned,
  ) {
    final local = !partitioned
        ? media
        : media
              .removeDisplayFeatures(region)
              .copyWith(
                size: region.size,
                displayFeatures: [
                  for (final feature in media.displayFeatures)
                    if (region.overlaps(feature.bounds))
                      DisplayFeature(
                        bounds: feature.bounds.shift(-region.topLeft),
                        type: feature.type,
                        state: feature.state,
                      ),
                ],
              );
    return Positioned(
      left: region.left - bounds.left,
      top: region.top - bounds.top,
      width: math.max(0, region.width),
      height: math.max(0, region.height),
      child: MediaQuery(data: local, child: child),
    );
  }
}
