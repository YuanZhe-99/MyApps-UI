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

Profile consumers add `packages/myapps_ui/packages/myapps_profile` as a path dependency.
Keep existing profile imports as re-export shims and storage/UI entry points as adapters.
MyVidComp updates the shared checkout but has no profile dependency or new profile UI.
