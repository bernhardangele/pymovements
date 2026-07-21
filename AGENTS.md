# Pymovements Agent Guide

## Commands

```bash
# Install dev environment (editable, with dev + docs extras)
uv pip install -e ".[dev,docs]"

# Run all tests (unit + doctests, excludes benchmarks/integration)
pytest

# Run a specific test file or directory
pytest tests/unit/events
pytest src/pymovements/gaze/transforms.py  # doctests

# Skip network-requiring tests
pytest -m "not network"

# Run benchmarks
pytest tests/benchmark --benchmark-json benchmark-data.json

# Run integration tests (separate suite)
pytest tests/integration

# Lint / typecheck / style
pre-commit run -a               # all hooks on all files
pre-commit run mypy -a          # mypy only
pre-commit run pylint -a        # pylint only
pre-commit run mypy --files src/pymovements/gaze/transforms.py  # single file

# Tox (multi-Python)
tox -e py312                    # specific Python version
tox -e py312 -- tests/unit/events  # scoped
tox -e pylint
tox -e docs                     # build Sphinx docs
tox -e integration
tox -e benchmark
tox -e build                    # build sdist + wheel

# Minimum dependency check (CI)
MIN_REQ=1 tox -e py310
```

## Code Style

- **PEP-8**, max line length **100**
- **Type annotations** required (PEP-484); mypy strict on `src/`, relaxed on `tests/` and `docs/`
- **Docstrings**: numpydoc style
- **Quotes**: double-quoted strings enforced (pre-commit `double-quote-string-fixer`)
- **Imports**: auto-sorted by `reorder-python-imports` with `--application-directories=src`; `from __future__ import annotations` auto-added to `src/` files (except `__init__.py`)
- **License header**: auto-inserted on all Python files (current year)
- **Trailing commas**: auto-added by `add-trailing-comma`
- **f-strings**: unnecessary f-strings auto-removed
- **Notebooks**: outputs stripped by `nbstripout`; `nbqa` runs autopep8/flake8/isort/pyupgrade on them

## Testing

- **Framework**: pytest with `--import-mode=importlib`, `--doctest-modules`, `xfail_strict=true`
- **Test paths**: `tests/` and `src/` (doctests)
- **Test layout**:
  - `tests/unit/` — mirrors `src/pymovements/` structure
  - `tests/integration/` — dataset downloads, end-to-end processing (requires network for some)
  - `tests/functional/` — gaze/dataset file processing
  - `tests/benchmark/` — pytest-benchmark suite
  - `tests/fixtures/` — shared pytest fixtures (registered in `tests/conftest.py` via `pytest_plugins`)
  - `tests/files/` — test data files (excluded from codespell)
- **Markers**: `network` — tests requiring network access (use `-m "not network"` to skip)
- **Coverage**: branch coverage, omit `docs/`, `tests/`, `_version.py`; parallel runs combined via `tox -e coverage`
- **Warnings**: treated as errors (`filterwarnings = ["error", ...]`); check `pyproject.toml` for allowed ignores
- **Test naming**: files must match `test_*.py` or `*_test.py` (enforced by `name-tests-test` hook; `*_fixtures.py` excluded)

## Architecture

- **Package root**: `src/pymovements/` (src layout)
- **Key subpackages**:
  - `dataset/` — core `Dataset` class
  - `datasets/` — YAML-defined public dataset configs (auto-generated doc pages via `_scripts/write_datasets_yaml.py`)
  - `events/` — event detection (I-VT, microsaccades, etc.)
  - `gaze/` — `Gaze` data container (Polars-based)
  - `transforms/` — coordinate/gaze transformations
  - `plotting/`, `measure/`, `synthetic/`, `stimulus/`
- **Version**: dynamic via `setuptools-git-versioning` from git tags; `_version.py` is generated and excluded from linting/pre-commit
- **Data**: Polars is the primary DataFrame library; pandas/numpy also supported

## Environment

- **Python**: >=3.10 (CI tests 3.10–3.13)
- **Dev container**: Debian Bookworm, Python 3.12, R, Node.js 24, git-annex, DataLad (isolated at `/opt/datalad-env`)
- **Virtual env**: `.venv/` (created by `postCreate.sh`)
- **Package manager**: `uv` (preferred over pip)
- **Pre-commit**: installed and configured; `pylint` hook uses system pylint

## Gotchas

- `_version.py` is auto-generated — never edit; excluded from pre-commit and coverage
- `pylint` runs as `language: system` hook — must be installed in the active env
- `pydoclint` config is in `pyproject.toml` (`[tool.pydoclint]`)
- `codespell` skips `tests/files/*` and `.bib` files; custom ignore list: `bund,InstRead`
- `mypy` disables `override` error code globally; ignores missing imports for `scipy` and `deprecated`
- `toml-sort` auto-formats `pyproject.toml` — don't manually reorder sections
- Dataset YAML files in `src/pymovements/datasets/` are auto-generated; the pre-commit hook `write-datasets-yaml` regenerates them
- PRs are squash-merged; use Conventional Commits format: `<type>[optional scope]: <description>`
- `main` branch is protected — no direct pushes
