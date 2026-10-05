# Navigation and content space

`MyAppsNavigationShell` renders caller-owned destinations and selection without
knowing routes, localization, persistence or providers. `MyAppsDestination` accepts
widgets for icons so an app can supply badges. Material 3 uses the classic bottom
bar; Expressive uses the compact floating pill unless the caller disables it.
Placement is bottom, side on wide, or side; rail side and extension are independent.

## Actual constraints

`MyAppsShellLayout` is an inherited snapshot measured inside the shell's Expanded
content box. It reports actual content width and whether navigation occupies a rail.
Pages use this width once, subtracting only their own padding. Routes outside the
shell fall back to their full window width. Window shape remains measured against
the full viewport for the unchanged split gate. A rail's minimum width grows with
large text; measured constraints, rather than an assumed 81 pixels, determine space.

## State and accessibility

The scaffold body always has the same three-slot row and content wrapper, whether
navigation is below, left or right. Switching placement, style or window dimensions
keeps the page element in that slot. Apps own route and selection state. Rails scroll
at compact heights; floating bars scale to fit. Selected and unselected destinations
retain semantic labels, selection state and tooltips. Existing split thresholds are
unchanged; hinge-aware pane partitioning remains outside this milestone.

## Verification

Widget tests cover all placements, both styles, actual measured widths, text scaling,
short windows, extended rails and state retention across resize and style changes.
Application suites additionally exercise routes, optional destinations and badges.
