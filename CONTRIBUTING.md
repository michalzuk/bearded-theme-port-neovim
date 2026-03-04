# Contributing to bearded.nvim

Thanks for your interest in contributing.

## Development setup

1. Clone the repository.
2. Ensure `python3` and `nvim` are installed and available in `PATH`.
3. Run tests:

```bash
python3 -m unittest discover -s tests
```

## Pull requests

- Keep changes focused and explain the rationale in the PR description.
- Update docs when user-facing behavior changes.
- Add or update tests when core logic changes.
- Ensure local tests pass before opening or updating a PR.

## Regenerating palettes

If your change touches palette generation:

```bash
python3 scripts/update-palettes.py --themes-dir /path/to/bearded-theme/dist/vscode/themes
```

Then run tests again.
