
# 固定的 reference_path
REFERENCE_PATH="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/data/judge_dataset_compare_1_aspect_rationale-test_manual_checked.json"

# prediction 文件所在目录
PREDICTION_DIR="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/omni_3B_merge_stage1_stage2_filtered_4096"

# 遍历 prediction_dir 下所有 .jsonl 文件
for prediction_path in "$PREDICTION_DIR"/*.jsonl; do
    echo "Running: $prediction_path"
    python /obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/eval_compare_1_aspect_with_args.py \
        --reference_path "$REFERENCE_PATH" \
        --prediction_path "$prediction_path"
done
