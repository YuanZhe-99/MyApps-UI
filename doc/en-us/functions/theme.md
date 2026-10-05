# Theme API

`MyAppsTheme(seedColor: ...)`: `scheme`, `build`, `light`, `dark`.
`MyAppsTheme.applyStyle(base, style)` applies the shared overlay to a custom base,
preserving card colors/elevation and input density.

`AppUiStyle`: `material3`, `expressive`. `NavPlacement`: `bottom`, `sideOnWide`, `side`.

Private helpers construct morphing buttons, emphasized text and Expressive component overrides.
Every method is pure construction; persistence and navigation remain caller-owned.
