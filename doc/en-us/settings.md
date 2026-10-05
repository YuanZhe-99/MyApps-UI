# Settings components and common translations

## Components

`MyAppsSettingsSection` renders a heading and caller-owned rows. Heading padding is
configurable to accommodate application spacing. `MyAppsSettingsSegments` wraps a
single-choice Material segmented button with unchanged values, icons and selection
callbacks. `MyAppsSettingsChoice` provides the labelled segmented/dropdown control
with disabled controls and optional help. Its width threshold
and maximum segment count are explicit parameters; applications retain their policy.

Applications own settings state, persistence, routing, platform gates and business
rows. These widgets do not know Riverpod, storage or application models. Applications
may adopt each component separately, including keeping a dialog-based picker.

## Common translations

`l10n/common_<locale>.arb` owns the identical appearance/navigation strings for
English, Simplified Chinese, Traditional Chinese and Japanese. These catalogs feed
application ARB files rather than adding another runtime localization delegate.
Existing generated getters and app fallback behavior remain compatible. Application
specific text and deliberate translation differences stay in application catalogs.

Run `python3 tool/common_l10n.py --check <app-root> ...` before publication or
`python3 tool/common_l10n.py --write <app-root> ...` to apply the common values.
The tool validates every input before writing, preserves other keys and metadata,
and ignores languages an application does not support. Run each application's
`flutter gen-l10n` after changing its catalog. Consumer CI checks the common keys.

## Validation

Widget tests verify selection callbacks, disabled controls, help and configurable
spacing. Catalog tests cover drift, missing keys, unsupported languages and preserving
application-owned entries. Application settings and full regression suites verify
that controls still write through their original providers.
