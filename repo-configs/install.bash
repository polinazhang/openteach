#!/usr/bin/env bash
set -euo pipefail
config_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(python3 - "$config_dir" <<'PY'
import sys
sys.path.insert(0, sys.argv[1])
from config import repo_root
print(repo_root)
PY
)"
openteach_dir="$repo_root/openteach"
franka_dir="$repo_root/franka-control"
env_dir="$openteach_dir/.conda-env"
[[ -f "$franka_dir/deoxys/setup.py" ]] || { echo 'Missing sibling franka-control checkout.' >&2; exit 1; }
if [[ -e "$env_dir" ]]; then
    echo 'The local environment already exists. Deactivate it and move or remove .conda-env before reinstalling.' >&2
    exit 1
fi
conda env create --prefix "$env_dir" --file "$config_dir/environment.yml"
export PYTHONNOUSERSITE=1
unset PYTHONPATH
"$env_dir/bin/python" "$franka_dir/replication/generate_python_protos.py"
"$env_dir/bin/python" -m pip install --no-build-isolation --no-deps -e "$openteach_dir" -e "$franka_dir/deoxys"
"$env_dir/bin/python" -m pip check
"$env_dir/bin/python" "$config_dir/smoke_test.py"
echo 'Installation and offline checks passed. From openteach, run: conda activate ./.conda-env'
