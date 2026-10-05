# Roadmap

| Stage | Deliverable | Gate |
|---|---|---|
| P1 | Theme factory, style enums, split and packing rules | Package checks and consumer regression suites |
| P2 | Navigation components and actual content-space measurement | All placement modes, resize and retained page state |
| P3 | Profile model, merge, repository adapters, avatar editor | Old JSON, sync, restore, delayed image arrival |
| P4 | Settings components, common translations and tooling | Independent consumer adoption and documentation parity |

0.1.0 implements P1; 0.1.1 implements P2. Profile extraction remains P3.
P2 reads measured content constraints without subtracting a rail twice.
Hinge-aware layout and text scaling must be verified before changing split behavior.

0.1.2 implements P3: shared profile and avatar components with app-owned adapters.
