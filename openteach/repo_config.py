"""Load the checkout's central configuration without relying on the cwd."""
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

_config_path = Path(__file__).resolve().parents[1] / "repo-configs" / "config.py"
_spec = spec_from_file_location("_openteach_repo_config", _config_path)
_config = module_from_spec(_spec)
_spec.loader.exec_module(_config)
repo_root = _config.repo_root

