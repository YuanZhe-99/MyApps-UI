# Adaptive API

`canSplitLayout(width, height)`, `useNavigationRail(screenWidth)`,
`columnCapacity(contentWidth, minItemWidth: ..., gap: ..., maxColumns: ...)`,
`listRowCount(itemCount, columns)`.

Exports split, navigation and list constants. Non-positive content widths return one column;
non-positive minimum widths return the ceiling. Empty lists require zero rows.
All functions are pure; callers supply logical pixels and business constraints.
