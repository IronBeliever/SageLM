REFERENCE_PATH="./LLaMA-Factory/data/test_semantic.json"  ## reference json file

PREDICTION_DIR=""  ## directory containing multiple model prediction results(.jsonl files) 

for prediction_path in "$PREDICTION_DIR"/*.jsonl; do
    echo "Running: $prediction_path"
    python ../judge-eval/eval_compare_1_aspect_with_args.py \  ## replace with your actual path
        --reference_path "$REFERENCE_PATH" \
        --prediction_path "$prediction_path"
done
