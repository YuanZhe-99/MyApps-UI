"""Synchronize shared appearance/navigation ARB strings into application catalogs."""

import argparse
import json
from pathlib import Path


def synchronize(app_roots, write=False, catalog_root=None):
    """Purpose: Check/apply common strings. Inputs: App roots, mode, catalogs. Returns: Drift list. Side effects: Optional writes. Notes: Validate all inputs first."""
    catalogs = catalog_root or Path(__file__).resolve().parent.parent / 'l10n'
    common = {}
    for source in sorted(catalogs.glob('common_*.arb')):
        locale = source.stem.removeprefix('common_')
        entries = json.loads(source.read_text())
        assert entries and all(isinstance(v, str) for v in entries.values()), source
        common[locale] = entries
    assert common, 'No common catalogs found'
    changes, drift = [], []
    for app in app_roots:
        directory = Path(app) / 'lib/l10n'
        assert directory.is_dir(), f'ARB directory missing: {directory}'
        sources = sorted(directory.glob('app_*.arb'))
        assert sources, f'No application catalogs: {directory}'
        for target in sources:
            locale = target.stem.removeprefix('app_')
            if locale not in common:
                continue
            text = target.read_text()
            data = json.loads(text)
            assert isinstance(data, dict), target
            differences = [key for key, value in common[locale].items()
                           if data.get(key) != value]
            for key in differences:
                drift.append(f'{target}: {key}')
                data[key] = common[locale][key]
            if differences:
                changes.append((target, json.dumps(data, ensure_ascii=False, indent=2) + '\n'))
    if write:
        for target, text in changes:
            target.write_text(text)
    return drift


def main():
    """Purpose: Execute catalog validation/update. Inputs: CLI args. Returns: Exit code. Side effects: Reads/writes catalogs. Notes: Check mode fails on drift."""
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--check', action='store_true')
    mode.add_argument('--write', action='store_true')
    parser.add_argument('apps', nargs='+', type=Path)
    args = parser.parse_args()
    drift = synchronize(args.apps, write=args.write)
    if drift:
        print('\n'.join(drift))
    print(f'Common translations: {len(drift)} differences' + (' applied' if args.write else ''))
    return 1 if drift and args.check else 0


if __name__ == '__main__':
    raise SystemExit(main())
