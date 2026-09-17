#!/usr/bin/env bash
# Source this from launchers; resolve config relative to this file, not the cwd.
_config_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(python3 - "$_config_dir" <<'PY'
import sys
sys.path.insert(0, sys.argv[1])
from config import repo_root
print(repo_root)
PY
)" || return 1
OPENTEACH_DIR="$repo_root/openteach"
FRANKA_DIR="$repo_root/franka-control"
PYTHON_BIN="$OPENTEACH_DIR/.conda-env/bin/python"
DEOXYS_EXAMPLES_DIR="$FRANKA_DIR/deoxys/examples"
if [[ ! -x "$PYTHON_BIN" ]]; then
    echo "Missing local environment. Run repo-configs/install.bash first." >&2
    return 1
fi
export PATH="$OPENTEACH_DIR/.conda-env/bin:$PATH"
unset _config_dir
