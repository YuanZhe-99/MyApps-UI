# Behavior contract

Preserve `material3`, `expressive`, `bottom`, `sideOnWide` and `side` enum names.
Expressive is the default and changes component shapes and typography, not colors.
Dynamic color is accepted from the caller; platform eligibility is app-owned.
Split requires width >= 600, height >= 480 and width / height >= 0.82.
Navigation eligibility is width-only at 600. Actual placement remains app-owned.
Capacity uses the content width, minimum item width, gap and maximum column count.
Existing settings files and sync formats are unaffected.

App pages now pass their context to content-width helpers, reading measured shell
space. Context-free legacy helpers retain their width-only behavior for compatibility.
Routes outside the shell use full window width without an imaginary rail subtraction.
