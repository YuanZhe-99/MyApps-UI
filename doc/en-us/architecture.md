# Architecture

Three packages ship from one repository and share a version. `myapps_ui` depends
only on Flutter; `myapps_adaptive` imports only Dart core. Neither owns persistence,
routing, localization or Riverpod providers. Apps retain their public theme facade
and layout entry point, supplying brand colors and page-specific constraints.

Navigation rendering and measured content space are shared in P2; see
[navigation.md](navigation.md). `myapps_profile` supplies adapter-backed profile and
avatar components; see [profile.md](profile.md). Settings controls and common ARB
catalog tooling are described in [settings.md](settings.md). The shared catalogs
feed app localization files; applications retain runtime delegates and differences.
MyApps-DATA
continues to own synchronization, backup and transfer engines.
