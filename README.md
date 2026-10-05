# MyApps-UI

Shared theme, navigation, adaptive layout, profiles and settings for the My Apps family.

- `packages/myapps_ui`: Material 3 / Expressive themes with caller-owned brand colors.
- `packages/myapps_adaptive`: Dart-only split and column calculations.
- `packages/myapps_profile`: profile persistence adapters, merge and avatar components.
- `l10n/` and `tool/common_l10n.py`: common ARB translations and consumer checks.

See [architecture](doc/en-us/architecture.md), [integration](doc/en-us/integration.md)
and the [Chinese documentation](doc/zh-cn/architecture.md).

`packages/myapps_profile` supplies adapter-backed profiles, avatars and editing.
Navigation is shared in myapps_ui; applications retain routes and state.
Settings controls and catalog ownership are described in [settings](doc/en-us/settings.md).
License: GPL-3.0; extracted from the My Apps applications.
