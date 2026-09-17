# Local Franka setup

Keep `openteach/` and `franka-control/` beside each other. Both repositories load
`repo_root` from their own `repo-configs/config.py`; the default follows the files
when the parent directory moves. No original user checkout is needed.

From `openteach`, run `bash repo-configs/install.bash`, then
`conda activate ./.conda-env`. The installer deliberately refuses to overwrite an
existing environment. To reinstall, deactivate and move or remove `.conda-env`
first. After relocating the repositories, recreate the environment: conda prefixes
and editable installs contain installation paths and are not relocatable.

`environment.yml` was exported after installing and testing on Linux x86_64 with
Python 3.10. It contains the resolved conda and pip dependencies, without an
installation prefix or references to local editable packages. The installer adds
both editable packages using `repo_root`, generates Deoxys protobuf bindings from
local sources, and builds GeoFIK against conda's Eigen headers. Do not combine it
with the older dependency files in either repository.

Run `python repo-configs/smoke_test.py` to repeat offline verification. It checks
local package origins, Franka Hydra targets, GeoFIK forward/inverse kinematics,
protobuf round trips, entry points from another working directory, and synthetic
FFmpeg encoding. It does not open cameras, connect to the NUC, or move the robot.
RealSense imports require access to the system udev monitor, even for these checks.