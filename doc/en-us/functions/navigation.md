# Navigation API

| Declaration | Purpose |
|---|---|
| MyAppsDestination | App-owned icon widgets and localized label |
| MyAppsNavigationShell | Render bottom/side navigation around a stable content slot |
| MyAppsShellLayout | Publish actual content width and rail occupancy |
| MyAppsShellLayout.maybeOf | Read layout and subscribe to changes; null outside shell |
| MyAppsShellLayout.updateShouldNotify | Notify on changed width or rail occupancy |
| MyAppsNavigationShell.build | Resolve placement, render navigation and measure body |
| MyAppsNavigationShell._rail | Scrollable rail with text-scaled width and divider |
| _ExpressiveNavBar | Existing compact floating pill rendering |
| _ExpressiveNavItem | Selected label, semantic state and tooltip |

Constructors create widget/descriptor instances without side effects. Rendering
invokes only caller-provided selection callbacks. Private bar/item build methods
use the active theme and preserve existing floating-navigation keys and animation.
See [../navigation.md](../navigation.md) for constraints and state ownership.
