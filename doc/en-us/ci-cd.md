# Verification and publication

CI verifies all three packages on Flutter 3.47.6: resolve dependencies, check formatting,
analyze, then run Flutter tests for UI/profile and Dart tests for adaptive rules.
Run the same checks locally before publishing. Use GPL-3.0 for extracted code.
Run `python3 tool/check_docs.py` and `python3 tool/test_common_l10n.py` as well.
Consumers verify shared ARB values in their existing Flutter test workflow.
Packages share one tagged version. Publish both remotes before consumer updates;
completed extraction milestones advance application patch versions by 0.0.1.
No remote CI success is claimed until a run has been inspected.
