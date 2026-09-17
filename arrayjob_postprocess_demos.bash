#!/bin/bash
#SBATCH --job-name=viz_unthread4
#SBATCH -p kira-lab
#SBATCH -A kira-lab
#SBATCH -c 20
#SBATCH --mem=48G
#SBATCH --qos=short
#SBATCH --array=0-24
#SBATCH -o slurm_logs/viz_unthread4_%A_%a.out
#SBATCH -e slurm_logs/viz_unthread4_%A_%a.err
#SBATCH -x irona,calculon
set -euox pipefail

source "${SLURM_SUBMIT_DIR:-$(dirname -- "${BASH_SOURCE[0]}")}/repo-configs/paths.bash"
unset LD_PRELOAD
which ffmpeg
cd -- "$OPENTEACH_DIR"

echo "Running demo unthread4_${SLURM_ARRAY_TASK_ID}"
"$PYTHON_BIN" visualize_demo.py --demo_num "$data_root/unthread4/demonstration_unthread4_${SLURM_ARRAY_TASK_ID}"
