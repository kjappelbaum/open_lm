#!/bin/bash
#SBATCH --partition=a40x
#SBATCH --job-name=openlmtest
#SBATCH --nodes 1
#SBATCH --gpus 1
#SBATCH --account=chemnlp
#SBATCH --open-mode=append
#SBATCH --exclusive

module load openmpi
module load cuda/12.1

conda activate openllm

export MASTER_ADDR=$(hostname)
export MASTER_PORT=12802
export NCCL_PROTO=simple
export FI_EFA_FORK_SAFE=1
export FI_LOG_LEVEL=1
export FI_EFA_USE_DEVICE_RDMA=1
export NCCL_DEBUG=info

export PYTHONFAULTHANDLER=1

export CUDA_LAUNCH_BLOCKING=0
export OMPI_MCA_mtl_base_verbose=1
export FI_EFA_ENABLE_SHM_TRANSFER=0
export FI_PROVIDER=efa
export FI_EFA_TX_MIN_CREDITS=64
export NCCL_TREE_THRESHOLD=0

cd /admin/home-kjablonk/open_lm
export PYTHONPATH="$PYTHONPATH:/admin/home-kjablonk/open_lm"

BATCHSIZE=10
LR=1e-3
MODEL="open_lm_11m"
WD=0.1

EXP_NAME="openlm-test"

echo "node-list: $SLURM_JOB_NODELIST"

#  one epoch is --train-num-samples tokens

srun --comment nextgends --cpu_bind=v --accel-bind=gn python -m open_lm.main \
    --train-num-samples 25000000000 \
    --workers 2 \
    --train-data "pipe:aws s3 cp s3://llched-raw/open_lm_run{0..7}/shard_*.tar -" \
    --dataset-resampled \
    --precision amp_bfloat16 \
    --global-batch-size $BATCHSIZE \
    --grad-checkpointing \
    --log-every-n-steps 20 \
    --grad-clip-norm 1 \
    --lr $LR \
    --warmup 2000 \
    --model $MODEL \
    --wd $WD \
    --beta2 0.95 \
    --epochs 64 \
    --report-to wandb \
    --wandb-project-name lm1 \
    --name $EXP_NAME \
    --logs /admin/home-kjablonk/openlm_test \
    --resume latest \
    --data-key 'json' \
    --lr-cooldown-end 3e-5
# --fsdp \
# --fsdp-limit-all-gathers \
# --fsdp-amp \
