# Architecture

Two packages ship from one repository and share a version. `myapps_ui` depends
only on Flutter; `myapps_adaptive` imports only Dart core. Neither owns persistence,
routing, localization or Riverpod providers. Apps retain their public theme facade
and layout entry point, supplying brand colors and page-specific constraints.

Navigation rendering and measured content space are shared in P2; see
[navigation.md](navigation.md). Profile extraction remains a future milestone. MyApps-DATA
continues to own synchronization, backup and transfer engines.
