"""Check documentation mirrors and public source coverage using only stdlib."""

from pathlib import Path
import re


def main():
    """Purpose: Validate mirrors. Inputs: None. Returns: None. Side effects: Reads docs. Notes: Raises on drift."""
    root = Path(__file__).resolve().parent.parent
    trees = [root / 'doc' / language for language in ('en-us', 'zh-cn')]
    paths = [{p.relative_to(tree) for p in tree.rglob('*.md')} for tree in trees]
    assert paths[0] == paths[1], 'Documentation file sets differ'
    for relative in sorted(paths[0]):
        texts = [(tree / relative).read_text() for tree in trees]
        shapes = [[len(line.split(' ')[0]) for line in text.splitlines()
                   if re.match(r'^#{1,6} ', line)] for text in texts]
        assert shapes[0] == shapes[1], f'Heading mismatch: {relative}'
        tables = [sum(line.startswith('|') for line in text.splitlines()) for text in texts]
        assert tables[0] == tables[1], f'Table mismatch: {relative}'
        for tree, text in zip(trees, texts):
            for link in re.findall(r'\]\(([^)]+)\)', text):
                target = link.split('#')[0]
                if target and '://' not in target:
                    assert (tree / relative.parent / target).exists(), f'Broken link: {relative}: {link}'
    index = (trees[0] / 'functions/INDEX.md').read_text()
    for source in (root / 'packages').glob('*/lib/src/*.dart'):
        assert str(source.relative_to(root)) in index, f'Missing source: {source}'
    print(f'Documentation mirrors verified: {len(paths[0])} pages per language')


if __name__ == '__main__':
    main()
