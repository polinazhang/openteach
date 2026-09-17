"""Parent containing the openteach and franka-control checkouts."""
from pathlib import Path

# Derive the default from this file so moving both checkouts needs no edits.
# Set this to an absolute parent directory only for a nonstandard layout.
repo_root = str(Path(__file__).resolve().parents[2])
