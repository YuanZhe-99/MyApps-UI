# Settings API

## Declarations

| Declaration | Responsibility |
|---|---|
| MyAppsSettingsSection constructor/build | Bind heading padding and render caller-owned rows |
| MyAppsSettingsSegments constructor/build | Render and forward a single selection without persistence |
| MyAppsSettingsSegmentRow constructor/build | Render icon, title, description and pane-width choice with shared spacing |
| MyAppsSettingsChoice constructor/build | Bind values, labels, help and caller width/count policy |
| MyAppsSettingsChoice._segmented/_dropdown | Render the selected mode and forward enabled selection |
| tool/common_l10n.py synchronize/main | Validate/apply common ARB values and provide CLI check/write modes |

Constructors have no side effects. Builds read theme and constraints; user selections
invoke callbacks. Catalog synchronization reads all supported application catalogs,
reports missing/different values and writes only in explicit write mode. Other entries
and metadata remain app-owned. See [../settings.md](../settings.md).
