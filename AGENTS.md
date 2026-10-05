# AGENTS.md — MyApps-UI

Agent operating rules only; architecture and behavior belong in `doc/en-us/`.

## Reading order

Read `doc/en-us/architecture.md`, the relevant concept page, then
`doc/en-us/functions/INDEX.md` and its per-file page. Read source comments and
implementation to confirm behavior before editing.

## Workflow

- Fetch both remotes and check divergence before editing.
- Preserve unrelated work and keep changes scoped.
- Update English and Chinese documentation together: matching files, headings,
  tables and examples. English is authoritative.
- Each function, constructor, getter and significant callback needs concise
  Purpose, Inputs, Returns, Side effects and Notes doc comments.
- Public exports are the API; consumers must not import `src/`.
- Keep packages independent of app models, routes, storage singletons and state
  management. Applications supply brand colors and content constraints.
- Verify each package with dependency resolution, formatting, analysis and tests.
- Do not commit secrets, private host names, generated outputs or library lockfiles.

## Compatibility

Preserve enum names used in existing settings, default Expressive behavior and
existing split thresholds unless the user approves a behavior change. Extraction
must preserve application public facades. Shared implementation does not imply
shared cross-application preferences or profile data.

## Publication

`origin` is `<local_gitea_address>`; `github` is the public MyApps-UI mirror.
Use relative `../MyApps-UI.git` URLs in consuming submodules. Never put the
private remote host or port in tracked files.

Packages use one repository version and annotated tag. Validate, commit and push
the library commit to both remotes before any application pointer update.
A release must be available on both remotes and consumers pin its tagged commit.
Ask before pushes unless the user has already authorized them; application
release versions remain the user's decision.
