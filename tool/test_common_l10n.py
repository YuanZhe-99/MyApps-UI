"""Behavior tests for catalog synchronization."""

import json
from pathlib import Path
import tempfile
import unittest

from common_l10n import synchronize


class CatalogTests(unittest.TestCase):
    def test_check_and_write_preserve_app_fields_and_metadata(self):
        """Purpose: Validate drift and ownership. Inputs: None. Returns: None. Side effects: Temp files. Notes: Unsupported languages stay intact."""
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            catalogs = root / 'common'
            catalogs.mkdir()
            (catalogs / 'common_en.arb').write_text('{"shared": "Canonical"}')
            app = root / 'app'
            target = app / 'lib/l10n'
            target.mkdir(parents=True)
            data = {'appOnly': 'Own', '@appOnly': {'description': 'Keep'}}
            (target / 'app_en.arb').write_text(json.dumps(data))
            (target / 'app_xx.arb').write_text('{"shared": "Own language"}')
            self.assertEqual(len(synchronize([app], catalog_root=catalogs)), 1)
            self.assertEqual(json.loads((target / 'app_en.arb').read_text()), data)
            synchronize([app], write=True, catalog_root=catalogs)
            data['shared'] = 'Canonical'
            self.assertEqual(json.loads((target / 'app_en.arb').read_text()), data)
            self.assertEqual(json.loads((target / 'app_xx.arb').read_text())['shared'], 'Own language')
            self.assertEqual(synchronize([app], catalog_root=catalogs), [])

    def test_invalid_later_input_does_not_partially_write(self):
        """Purpose: Protect against partial updates. Inputs: None. Returns: None. Side effects: Temp files. Notes: All inputs validate before mutation."""
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            catalogs = root / 'common'
            catalogs.mkdir()
            (catalogs / 'common_en.arb').write_text('{"shared": "New"}')
            target = root / 'app/lib/l10n'
            target.mkdir(parents=True)
            source = target / 'app_en.arb'
            source.write_text('{"shared": "Old"}')
            with self.assertRaises(AssertionError):
                synchronize([root / 'app', root / 'missing'], write=True, catalog_root=catalogs)
            self.assertEqual(source.read_text(), '{"shared": "Old"}')


if __name__ == '__main__':
    unittest.main()
