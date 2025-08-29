#!/bin/bash
MODEL_PATH="/data/geyuan/Judge_SLM/SLM_saves/qwen2.5_omni-7B/stage2-merged"    ## TODO: replace with your own model path
SAVE_ROOT="/data/geyuan/Judge_SLM/LLaMA-Factory-0612/judge-eval/test"    ## TODO: select a folder to save results
DATASET="GLM_kimi-Audio_trunc60s"    ## TODO: replace with your own dataset name
TEMPLATE="qwen2_omni"

# SEEDS=(42 123 1234)
SEEDS=(42)

export CUDA_VISIBLE_DEVICES=2,3


for seed in "${SEEDS[@]}"; do
    SAVE_PATH="${SAVE_ROOT}/seed-${seed}.jsonl"

    echo "Running inference: step=${step}, seed=${seed}"

    python scripts/vllm_infer.py \
        --model_name_or_path "$MODEL_PATH" \
        --save_name "$SAVE_PATH" \
        --template "$TEMPLATE" \
        --dataset "$DATASET" \
        --seed "$seed"

done


echo "All inference completed."
