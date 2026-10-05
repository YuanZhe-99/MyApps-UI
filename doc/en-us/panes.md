# Wide-screen pane partitioning

## Policy

P5 has three policies: automatic packing, a user-selected count clamped to actual
capacity, and app-designed semantic panes. `resolveLayoutColumns` shares automatic
and selected column decisions without owning preferences. `MyAppsRegionLayout`
supports any number of regions: automatic/selected equal-width packing or explicit
app-designed normalized rectangles, with a one-column fallback. The application
chooses which policies a page exposes; settings master/detail is one designed case.

`MyAppsPaneLayout` renders app-owned primary and secondary panes. Without a
separating display feature it preserves the app's split gate and preferred primary
width. A divider is included in the width budget. Applications provide minimum
usable widths and retain selection, navigation and persistence.

Non-zero occlusions and half-open folds divide the local content rectangle. Flat
zero-width folds and cutouts do not request two panes. A vertical separator places
primary content on the left and secondary content on the right; a horizontal
separator places primary content above secondary content. Each pane receives a
region-local MediaQuery when a physical separator is present. Without separators,
the original window MediaQuery is retained for existing nested page split gates.
If two usable regions cannot satisfy the app's minimum sizes, only primary content
is displayed in the largest usable region. A separator never overrides the app's
existing window-shape split gate.

## Coordinates and interaction

The caller passes the content rectangle in window coordinates. Shell snapshots
publish their content rectangle after navigation and shell app bars; settings
pages additionally exclude their own app bar and system top inset. Display features
remain in window coordinates until partitioning. This avoids subtracting the rail
twice and handles left/right rails independently.

`onSplitChanged` reports the effective two-pane mode during layout, so app tap
handlers can push a route when only one pane fits. The callback must update only
the app's cached routing flag, without setState. Primary content stays in a stable
slot as mode, divider direction and display features change. Secondary route state
is app-owned. Multiple separating features are partitioned recursively; the two
largest usable regions are selected in reading order.

## Verification

Tests cover the established phone, foldable, tablet and desktop sizes, vertical and
horizontal separators, zero-width half-open folds, flat folds, cutouts, undersized
regions, rail offsets, region-local geometry, callbacks and primary state retention.
Simulated display features validate geometry; physical-device posture reporting
remains dependent on Flutter and the platform.
