# Integration

Publish the library commit and tag to both remotes first. Applications embed it
at `packages/myapps_ui` using relative submodule URL `../MyApps-UI.git`.
Dependencies point to `packages/myapps_ui/packages/myapps_ui` and
`packages/myapps_ui/packages/myapps_adaptive`. Initialize submodules after cloning.
Re-export shared enums and common layout functions through existing app files.
AppTheme delegates to MyAppsTheme with the original brand seed.
Validate each consumer before committing its pointer. Consumers may update independently.

Development validation can use an ignored `pubspec_overrides.yaml` pointing at a
sibling checkout before publication. Do not commit those machine-local overrides.
