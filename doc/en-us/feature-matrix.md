# Component responsibilities

| Component area | Shared responsibility | Application responsibility |
|---|---|---|
| Theme | Base theme and Expressive overlay | Brand seed, theme selection and customizations |
| Adaptive layout | Geometry, capacity and partition calculations | Content constraints and layout policy |
| Navigation | Shell rendering and measured content bounds | Destinations, routes, badges and persisted placement |
| Settings | Sections, segments and labelled choice controls | State, persistence, platform gates and business rows |
| Profile | Adapter-backed profile and avatar components | Data, storage, entry points and localization |
| Common translations | Shared appearance and navigation ARB values | Runtime delegates and application-specific wording |

Applications may adopt individual packages and components independently. The library
does not prescribe a brand, route structure or business layout. Record actual usage
and integration validation in each application's documentation.
