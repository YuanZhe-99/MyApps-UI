import 'package:flutter/material.dart';
import 'panes.dart';

/// Multi-region layout for automatic, selected or app-designed content.
class MyAppsRegionLayout extends StatelessWidget {
  final List<Widget> children;
  final bool allowSplit;
  final int preferredColumns;
  final int maxColumns;
  final double minRegionWidth;
  final double gap;
  final List<Rect>? designedRegions;
  final Rect contentBounds;

  /// Purpose: Bind content to automatic, selected or designed region geometry.
  /// Inputs: Children, capacity policy, optional normalized design and bounds.
  /// Returns: Multi-region layout.
  /// Side effects: None.
  /// Notes: Zero preference means auto; normalized design is used only if it fits.
  const MyAppsRegionLayout({
    super.key,
    required this.children,
    required this.contentBounds,
    this.allowSplit = true,
    this.preferredColumns = 0,
    this.maxColumns = 4,
    this.minRegionWidth = 320,
    this.gap = 12,
    this.designedRegions,
  }) : assert(maxColumns > 0),
       assert(minRegionWidth > 0),
       assert(gap >= 0),
       assert(
         designedRegions == null || designedRegions.length == children.length,
       );

  /// Purpose: Keep all regions within a usable display partition.
  /// Inputs: `context`.
  /// Returns: Layout inside the largest unobstructed region.
  /// Side effects: None.
  /// Notes: Semantic panes spanning partitions use MyAppsPaneLayout instead.
  @override
  Widget build(BuildContext context) => MyAppsPaneLayout(
    primary: LayoutBuilder(builder: _regions),
    secondary: const SizedBox.shrink(),
    allowSplit: false,
    primaryWidth: 0,
    primaryMinWidth: 0,
    secondaryMinWidth: 0,
    contentBounds: contentBounds,
  );

  /// Purpose: Resolve the caller's capacity/design and render stable region slots.
  /// Inputs: Local context and available constraints.
  /// Returns: A positioned region stack.
  /// Side effects: None.
  /// Notes: Designed rectangles must be non-overlapping and normalized to 0..1.
  Widget _regions(BuildContext context, BoxConstraints box) {
    final design = designedRegions;
    final usableDesign =
        allowSplit &&
        design != null &&
        design.every(
          (r) =>
              r.left >= 0 &&
              r.top >= 0 &&
              r.right <= 1 &&
              r.bottom <= 1 &&
              r.width * box.maxWidth >= minRegionWidth &&
              r.height > 0,
        );
    if (usableDesign) {
      for (var i = 0; i < design.length; i++) {
        for (var j = i + 1; j < design.length; j++) {
          assert(
            !design[i].overlaps(design[j]),
            'Designed regions must not overlap',
          );
        }
      }
    }
    final capacity = ((box.maxWidth + gap) / (minRegionWidth + gap))
        .floor()
        .clamp(1, maxColumns);
    final columns = !allowSplit || design != null && !usableDesign
        ? 1
        : preferredColumns == 0
        ? capacity
        : preferredColumns.clamp(1, capacity);
    final rows = children.isEmpty
        ? 1
        : (children.length + columns - 1) ~/ columns;
    final width = ((box.maxWidth - gap * (columns - 1)) / columns).clamp(
      0.0,
      box.maxWidth,
    );
    final height = ((box.maxHeight - gap * (rows - 1)) / rows).clamp(
      0.0,
      box.maxHeight,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          Positioned(
            key: ValueKey(i),
            left: usableDesign
                ? design[i].left * box.maxWidth
                : i % columns * (width + gap),
            top: usableDesign
                ? design[i].top * box.maxHeight
                : i ~/ columns * (height + gap),
            width: usableDesign ? design[i].width * box.maxWidth : width,
            height: usableDesign ? design[i].height * box.maxHeight : height,
            child: children[i],
          ),
      ],
    );
  }
}
