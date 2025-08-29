
# 固定的 reference_path
REFERENCE_PATH="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/data/judge_dataset_stage2_test_manual_checked_truncated_filtered_implicit.json"

# prediction 文件所在目录
PREDICTION_DIR="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/omni_3B_merge_stage1_stage2_filtered_4096/acoustic"

# 遍历 prediction_dir 下所有 .jsonl 文件
for prediction_path in "$PREDICTION_DIR"/*.jsonl; do
    echo "Running: $prediction_path"
    python /obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/eval_stage2_acoustic_with_args.py \
        --reference_path "$REFERENCE_PATH" \
        --prediction_path "$prediction_path"
done

# # 固定的 reference_path
# REFERENCE_PATH="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/data/yky-test-stage2-1.json"

# # prediction 文件所在目录
# PREDICTION_DIR="/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/stage2-baseline"

# # 遍历 prediction_dir 下所有 .jsonl 文件
# for prediction_path in "$PREDICTION_DIR"/*.jsonl; do
#     echo "Running: $prediction_path"
#     python /obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/scripts/direct-inference-with-prompt/eval_stage2.py \
#         --reference_path "$REFERENCE_PATH" \
#         --prediction_path "$prediction_path"
# done
