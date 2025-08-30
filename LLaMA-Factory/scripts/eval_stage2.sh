REFERENCE_PATH="./LLaMA-Factory/data/test_acoustic.json"

PREDICTION_DIR=""  ## directory containing multiple model prediction results(.jsonl files) 

for prediction_path in "$PREDICTION_DIR"/*.jsonl; do
    echo "Running: $prediction_path"
    python ../judge-eval/eval_stage2_acoustic_with_args.py \  ## replace with your actual path
        --reference_path "$REFERENCE_PATH" \
        --prediction_path "$prediction_path"
done
