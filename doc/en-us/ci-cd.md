# Verification and publication

CI verifies all three packages on Flutter 3.47.6: resolve dependencies, check formatting,
analyze, then run Flutter tests for UI/profile and Dart tests for adaptive rules.
Run the same checks locally before publishing. Use GPL-3.0 for extracted code.
The initial library version is 0.1.0. Consumers advance their minor versions after validation.
No remote CI success is claimed until a run has been inspected.
