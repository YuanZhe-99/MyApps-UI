# Roadmap

| Stage | Deliverable | Gate |
|---|---|---|
| P1 | Theme factory, style enums, split and packing rules | Package checks and consumer regression suites |
| P2 | Navigation components and actual content-space measurement | All placement modes, resize and retained page state |
| P3 | Profile model, merge, repository adapters, avatar editor | Old JSON, sync, restore, delayed image arrival |
| P4 | Settings components, common translations and tooling | Independent consumer adoption and documentation parity |

0.1.0 implements P1. No placeholder profile package or navigation framework is shipped.
P2 must resolve the legacy width-based rail prediction without subtracting a rail twice.
Hinge-aware layout and text scaling must be verified before changing split behavior.
