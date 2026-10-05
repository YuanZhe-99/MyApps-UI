import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'appearance.dart';

/// One app-owned destination, including optional badges in its icon widgets.
class MyAppsDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  /// Purpose: Describe a navigation destination.
  /// Inputs: `icon`, `selectedIcon`, localized `label`.
  /// Returns: A destination descriptor.
  /// Side effects: None.
  /// Notes: Routing remains app-owned.
  const MyAppsDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Actual constraints below navigation, available to descendants.
class MyAppsShellLayout extends InheritedWidget {
  final double contentWidth;
  final bool hasRail;

  /// Purpose: Publish measured shell content space.
  /// Inputs: `contentWidth`, `hasRail`, `child`.
  /// Returns: An inherited layout snapshot.
  /// Side effects: None.
  /// Notes: Width already excludes any rail and divider.
  const MyAppsShellLayout({
    super.key,
    required this.contentWidth,
    required this.hasRail,
    required super.child,
  });

  /// Purpose: Read actual shell constraints when the caller is inside a shell.
  /// Inputs: `context`.
  /// Returns: Layout snapshot or null.
  /// Side effects: Registers an inherited dependency.
  /// Notes: Full-window routes use a null result and their own window width.
  static MyAppsShellLayout? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyAppsShellLayout>();

  /// Purpose: Notify pages when content width or navigation occupancy changes.
  /// Inputs: `oldWidget`.
  /// Returns: Whether descendants must rebuild.
  /// Side effects: None.
  /// Notes: None.
  @override
  bool updateShouldNotify(MyAppsShellLayout oldWidget) =>
      contentWidth != oldWidget.contentWidth || hasRail != oldWidget.hasRail;
}

/// Reusable navigation rendering with a stable content slot across layout changes.
class MyAppsNavigationShell extends StatelessWidget {
  final Widget child;
  final List<MyAppsDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final AppUiStyle style;
  final NavPlacement placement;
  final bool railOnRight;
  final bool extendedRail;
  final bool floatingExpressiveBar;
  final double railMinWidth;
  final double minExtendedWidth;
  final double railGroupAlignment;
  final PreferredSizeWidget? appBar;

  /// Purpose: Construct an app-independent navigation shell.
  /// Inputs: Destinations, selection callback, child and navigation preferences.
  /// Returns: A navigation shell.
  /// Side effects: None.
  /// Notes: At least two destinations and a valid selection are required.
  const MyAppsNavigationShell({
    super.key,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.style = AppUiStyle.expressive,
    this.placement = NavPlacement.bottom,
    this.railOnRight = false,
    this.extendedRail = false,
    this.floatingExpressiveBar = true,
    this.railMinWidth = 80,
    this.minExtendedWidth = 200,
    this.railGroupAlignment = 0,
    this.appBar,
  }) : assert(destinations.length >= 2),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  /// Purpose: Render navigation and publish actual content constraints.
  /// Inputs: `context`.
  /// Returns: Scaffold containing navigation and the stable page slot.
  /// Side effects: Calls the selection callback for user navigation.
  /// Notes: The body structure never changes when placement or style changes.
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final showRail = switch (placement) {
        NavPlacement.bottom => false,
        NavPlacement.sideOnWide => constraints.maxWidth >= 600,
        NavPlacement.side => true,
      };
      final floating =
          !showRail && floatingExpressiveBar && style == AppUiStyle.expressive;
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final railWidth = math.max(railMinWidth, 80 * textScale);
      final rail = _rail(railWidth);
      return Scaffold(
        appBar: appBar,
        extendBody: floating,
        body: Row(
          children: [
            if (showRail && !railOnRight) rail else const SizedBox.shrink(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, content) {
                  final mq = MediaQuery.of(context);
                  return MyAppsShellLayout(
                    contentWidth: content.maxWidth,
                    hasRail: showRail,
                    child: MediaQuery(
                      data: mq.copyWith(
                        viewPadding: mq.viewPadding.copyWith(
                          bottom: floating
                              ? math.max(
                                  mq.viewPadding.bottom,
                                  mq.padding.bottom,
                                )
                              : mq.viewPadding.bottom,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ),
            if (showRail && railOnRight) rail else const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: showRail
            ? null
            : floating
            ? _ExpressiveNavBar(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              )
            : NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: d.label,
                    ),
                ],
              ),
      );
    },
  );

  /// Purpose: Build a scrollable side rail and its divider.
  /// Inputs: `width` — minimum rail width for the current text scale.
  /// Returns: Rail with an adjacent divider.
  /// Side effects: Calls the selection callback.
  /// Notes: App-owned extended rails and group alignment are supported.
  Widget _rail(double width) {
    final navigation = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              minWidth: width,
              minExtendedWidth: math.max(minExtendedWidth, width),
              extended: extendedRail,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: extendedRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              groupAlignment: railGroupAlignment,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: railOnRight
          ? [const VerticalDivider(width: 1), navigation]
          : [navigation, const VerticalDivider(width: 1)],
    );
  }
}

/// The Expressive bottom navigation bar (0.6.1): a compact floating pill that
/// hugs its items, modelled on Material 3 Expressive's floating navigation.
/// The selected destination shows its icon and label side by side in a
/// tonal pill; the others show their icon only. It floats over the page
/// (the shell sets `extendBody`), with margins from the screen edges.
class _ExpressiveNavBar extends StatelessWidget {
  final List<MyAppsDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Key on the island's surface, so tests can tell it from the classic bar.
  static const islandKey = ValueKey('floatingNavBarIsland');

  /// Purpose: Create the Expressive navigation bar.
  /// Inputs: `destinations`, `selectedIndex`, `onSelected`.
  /// Returns: A new `_ExpressiveNavBar` instance.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only.
  const _ExpressiveNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Purpose: Build the island and its items.
  /// Inputs: `context`.
  /// Returns: The floating bar, centred above the system inset.
  /// Side effects: None.
  /// Notes: The bar is as wide as its items; on very narrow screens it scales
  /// down instead of overflowing.
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Center(
          heightFactor: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Material(
              key: islandKey,
              color: cs.surfaceContainer,
              surfaceTintColor: Colors.transparent,
              shadowColor: cs.shadow,
              elevation: 3,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < destinations.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _ExpressiveNavItem(
                        destination: destinations[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One destination of [_ExpressiveNavBar].
class _ExpressiveNavItem extends StatelessWidget {
  final MyAppsDestination destination;
  final bool selected;
  final VoidCallback onTap;

  /// Purpose: Create one Expressive navigation item.
  /// Inputs: `destination`, `selected`, `onTap`.
  /// Returns: A new `_ExpressiveNavItem` instance.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only.
  const _ExpressiveNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  /// Purpose: Build the item: icon, plus the label while selected.
  /// Inputs: `context`.
  /// Returns: A tappable pill.
  /// Side effects: Calls [onTap] when tapped.
  /// Notes: The pill's width and colour animate when the selection moves.
  /// Unselected items carry a tooltip and a semantic label, since their text
  /// is hidden.
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    const duration = Duration(milliseconds: 250);
    Widget item = InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 16),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: selected ? cs.secondaryContainer : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: fg, size: 24),
              child: selected
                  ? (destination.selectedIcon ?? destination.icon)
                  : destination.icon,
            ),
            AnimatedSize(
              duration: duration,
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
    if (!selected) {
      item = Tooltip(message: destination.label, child: item);
    }
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: selected ? null : destination.label,
      child: item,
    );
  }
}
