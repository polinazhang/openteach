#!/bin/bash
set -euo pipefail

NUC_IP="${1:-172.16.0.3}"
MODE="${2:-eval}"

OPENTEACH_PY="/home/jeremiah/miniforge3/envs/openteach/bin/python"
OPENPI_ROOT="/home/ripl/openpi"
OPENPI_PY="$OPENPI_ROOT/.venv/bin/python"
INFERENCE_SCRIPT="$OPENPI_ROOT/examples/franka_real/inference_server.py"
ROBOT_COMM_SCRIPT="$OPENPI_ROOT/examples/franka_real/robot_communicator.py"
ROBOT_COMM_ARGS=""
if [[ "$MODE" == "test" ]]; then
    ROBOT_COMM_ARGS="--test"
fi

wait_for_inference_server() {
    local timeout_sec="${OPENPI_SERVER_STARTUP_TIMEOUT_SEC:-180}"
    local waited=0

    while (( waited < timeout_sec )); do
        if "$OPENPI_PY" - <<'PY'
import sys
import urllib.request

try:
    with urllib.request.urlopen("http://127.0.0.1:8000/health", timeout=1.0) as resp:
        sys.exit(0 if resp.status == 200 else 1)
except Exception:
    sys.exit(1)
PY
        then
            return 0
        fi
        sleep 1
        (( waited += 1 ))
    done

    return 1
}

send_cmd() {
    xdotool key --clearmodifiers ctrl+u
    sleep 0.1
    xdotool type --clearmodifiers --delay 1 "$1"
    sleep 0.25
    xdotool key --clearmodifiers Return
    sleep 0.6
}

# Window 1: 2x2 split for non-interactive processes.
# Pane A: camera, Pane B: arm, Pane C: gripper, Pane D: inference server.
terminator &
sleep 1.2

# Pane A
send_cmd "cd /home/ripl/openteach && $OPENTEACH_PY robot_camera.py --config-name=camera"

# Pane B
xdotool key --clearmodifiers ctrl+shift+o
sleep 0.3
send_cmd "ssh -o ConnectTimeout=5 ripl@$NUC_IP 'cd ~/deoxys_control/deoxys && ./auto_scripts/auto_arm.sh config/charmander.yml --eval'"

# Pane C
xdotool key --clearmodifiers ctrl+shift+e
sleep 0.3
send_cmd "ssh -o ConnectTimeout=5 ripl@$NUC_IP 'cd ~/deoxys_control/deoxys && ./auto_scripts/auto_gripper.sh config/charmander.yml'"

# Pane D
xdotool key --clearmodifiers alt+Left
sleep 0.3
xdotool key --clearmodifiers ctrl+shift+e
sleep 0.3
send_cmd "cd $OPENPI_ROOT && source $OPENPI_ROOT/.venv/bin/activate && TORCHDYNAMO_DISABLE=1 python $INFERENCE_SCRIPT"

# Wait for the server to become responsive before launching the communicator.
if ! wait_for_inference_server; then
    echo "Inference server did not become ready on http://127.0.0.1:8000/health within ${OPENPI_SERVER_STARTUP_TIMEOUT_SEC:-180}s" >&2
fi

# Window 2: dedicated communicator terminal (interactive; waits for user input between episodes).
terminator &
sleep 1.0
send_cmd "cd $OPENPI_ROOT && $OPENTEACH_PY $ROBOT_COMM_SCRIPT $ROBOT_COMM_ARGS"

exit 0
