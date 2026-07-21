#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/pymovements

# Initialize workspace venv
uv venv .venv
source .venv/bin/activate

# Lightning-fast installation using pre-cached wheels from /root/.cache/uv
uv pip install -e ".[dev,docs]"

if [ -f .pre-commit-config.yaml ]; then
  pre-commit install || true
fi

python -c "import pymovements; print('pymovements import OK')"
pytest --collect-only -q || true

node --version
npm --version
python --version
R --version