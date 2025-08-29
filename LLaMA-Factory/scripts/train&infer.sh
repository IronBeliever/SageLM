# 准备命令
conda activate /obs/conda_envs/llamaf
conda activate /obs/conda_envs/llamaf_modified
cd /obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/
python -c "import sys; print('\n'.join(sys.path))"
export PYTHONPATH=/obs/conda_envs/llamaf/lib/python3.10:/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/src:/obs/conda_envs/llamaf/lib/python3.10/site-packages:$PYTHONPATH
export PYTHONPATH=/obs/conda_envs/llamaf_modified/lib/python3.10:/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/src:/obs/conda_envs/llamaf_modified/lib/python3.10/site-packages:$PYTHONPATH

export PYTHONPATH=/obs/conda_envs/llamaf/lib/python3.10:/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/src:/obs/conda_envs/llamaf/lib/python3.10/site-packages:/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612:/obs/conda_envs/llamaf/lib/python310.zip:/obs/conda_envs/llamaf/lib/python3.10/lib-dynload
#### debug qwen2.5-omni
export PYTHONDONTWRITEBYTECODE=1
CUDA_VISIBLE_DEVICES=3,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_3B_scoring_1_aspect_debug.yaml
CUDA_VISIBLE_DEVICES=3,5,6,7 python scripts/vllm_infer.py \
    --model_name_or_path /obs/SLM-saves/qwen2.5_omni-3B/scoring_1_aspect_rationale-3epoch-debug-merged \
    --save_name "judge-eval/demo.jsonl" \
    --template "qwen2_omni" \
    --dataset "judge_dataset_scoring_1_aspect_rationale-test-debug"\
####

# A100 Train

CUDA_VISIBLE_DEVICES=2,3,4,5 llamafactory-cli train examples/judge/qwen2_audio_instruct_62k.yaml > logs/demo_train.log 2>&1
CUDA_VISIBLE_DEVICES=2,3,4,5 llamafactory-cli train examples/judge/qwen2.5_omni_3B_62k.yaml > logs/qwen2.5_omni_3B_62k_with_rational.log 2>&1
llamafactory-cli train examples/judge/qwen2.5_omni_3B_compare_1_aspect.yaml > logs/qwen2.5_omni_3B_compare_1_aspect-2.log 2>&1
CUDA_VISIBLE_DEVICES=6,7 llamafactory-cli train examples/judge/qwen2.5_omni_3B_compare_4_aspect.yaml > logs/qwen2.5_omni_3B_compare_4_aspect.log 2>&1
CUDA_VISIBLE_DEVICES=0,1,2,3 llamafactory-cli train examples/judge/qwen2.5_omni_3B_scoring_1_aspect.yaml > logs/qwen2.5_omni_3B_scoring_1_aspect.log 2>&1
llamafactory-cli train examples/judge/qwen2.5_omni_3B_scoring_4_aspect.yaml > logs/qwen2.5_omni_3B_scoring_4_aspect.log 2>&1

# runing
CUDA_VISIBLE_DEVICES=4,5,2,3 llamafactory-cli train examples/judge/qwen2_audio_compare_1_aspect.yaml > logs/qwen2_audio_compare_1_aspect.log 2>&1
# audio-instruct 7B
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2_audio_compare_1_aspect.yaml 2>&1 | tee logs/qwen2_audio_7b_compare_1_aspect.log
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2_audio_compare_1_aspect.yaml 2>&1 | tee logs/qwen2_audio_7b_compare_1_aspect_resumed.log
CUDA_VISIBLE_DEVICES=4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml > logs/qwen2.5_omni_7B_compare_1_aspect.log 2>&1
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml 2>&1 | tee logs/qwen2.5_omni_7B_compare_1_aspect_resumed.log 
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml 2>&1 | tee logs/qwen2.5_omni_7B_compare_1_aspect_resumed.log
# stage 2 训练
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_7B_stage2.yaml 2>&1 | tee logs/stage2.log
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_3B_stage2.yaml 2>&1 | tee logs/3b_stage2.log
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 llamafactory-cli train examples/judge/qwen2.5_omni_3B_stage2_reduce_lr.yaml 2>&1 | tee logs/3b_stage2_reduce_lr.log
# 51 shixun 训练
CUDA_VISIBLE_DEVICES=2,3 llamafactory-cli train examples/judge/qwen2.5_omni_3B_shixun.yaml 2>&1 | tee logs/3b_shixun.log
# merged_stage1_stage2 omni 3B
CUDA_VISIBLE_DEVICES=4,5,6,7 llamafactory-cli train examples/judge/omni_3B_merged_stage1_stage2.yaml 2>&1 | tee logs/qwen2_omni_3b_merged_stage1_stage2_obs1.log
# merged_stage1_stage2 omni 3B filtered_long_4096
CUDA_VISIBLE_DEVICES=4,5,6,7 llamafactory-cli train examples/judge/omni_3B_merged_stage1_stage2_filtered_long_4096.yaml 2>&1 | tee logs/qwen2_omni_3b_merged_stage1_stage2_filtered_long_4096.log

# Full mode: [Thinker] + [Original Talker] -> [Omni model]
CUDA_VISIBLE_DEVICES=6,7 python3 ./scripts/qwen_omni_merge.py save_full \
  --base_model_path="/obs/pretrained_models/Qwen/Qwen2.5-Omni-3B" \
  --saved_thinker_path="/obs/SLM-saves/qwen2.5_omni-3B/merged_stage1_stage2" \
  --save_path="/obs/SLM-saves/qwen2.5_omni-3B/merged_stage1_stage2_merged"


# Infer
CUDA_VISIBLE_DEVICES=0,1,2,3 python scripts/vllm_infer.py \
    --model_name_or_path /obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory/saves/qwen2_audio-7B-instruct/62k-with-rational-3epoch \
    --save_name "judge-eval/instruct_62k_with_rational_3epoch.jsonl" \
    --dataset "judge_dataset_with_rationale-test"\
    > logs/infer-qwen2_audio_instruct_62k_lable_only.log 2>&1


CUDA_VISIBLE_DEVICES=5,6 python scripts/vllm_infer.py \
    --model_name_or_path /obs/SLM-saves/qwen2.5_omni-3B/scoring_4_aspect_rationale-3epoch-merged \
    --save_name "judge-eval/omni_3B_scoring_4_aspect_rationale-3epoch.jsonl" \
    --template "qwen2_omni" \
    --dataset "judge_dataset_scoring_4_aspect_rationale-test"\
    > logs/infer_scoring_4_aspect.log 2>&1

CUDA_VISIBLE_DEVICES=5,6 python scripts/vllm_infer.py \
    --model_name_or_path /obs/SLM-saves/swift_output/v14-20250701-143340/checkpoint-12000 \
    --save_name "/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/omni_7B_compare_1_aspect_rationale" \
    --template "qwen2_omni" \
    --dataset "judge_dataset_scoring_1_aspect_rationale-test"\
    2>&1 | tee logs/infer_rl_test.log 

CUDA_VISIBLE_DEVICES=0,1,2,3 python scripts/vllm_infer.py \
    --model_name_or_path /obs/SLM-saves/qwen2.5_omni-7B/compare_1_aspect_rationale-3epoch-merged \
    --template "qwen2_omni" \
    --dataset "judge_dataset_compare_1_aspect_rationale_test_manual_checked"\
    --save_name "judge-eval/omni_7B_compare_1_aspect_rationale/seed-42.jsonl" \
    --seed 42


CUDA_VISIBLE_DEVICES=0,1 python scripts/vllm_infer.py \
    --model_name_or_path /obs/pretrained_models/Qwen/Qwen2-Audio-7B \
    --template "qwen2_audio" \
    --dataset "yky-test"\
    --save_name "judge-eval/infer_compare_1_aspect_Qwen2-Audio-7B_v1.jsonl" \
    > logs/infer_compare_1_aspect_manual_checked_Qwen2-Audio-7B_v2.log 2>&1

CUDA_VISIBLE_DEVICES=0,1 python scripts/vllm_infer.py \
    --model_name_or_path /obs/pretrained_models/Qwen/Qwen2.5-Omni-7B \
    --template "qwen2_omni" \
    --dataset "yky-test"\
    --save_name "judge-eval/infer_compare_1_aspect_Qwen2.5-Omni-7B_v3.jsonl" \
    > logs/infer_compare_1_aspect_manual_checked_Qwen2.5-Omni-7B_v3.log 2>&1

CUDA_VISIBLE_DEVICES=0,1 python scripts/vllm_infer.py \
    --model_name_or_path /obs/pretrained_models/Qwen/Qwen2.5-Omni-3B \
    --template "qwen2_omni" \
    --dataset "yky-test"\
    --seed 42 \
    --save_name "judge-eval/infer_compare_1_aspect_Qwen2.5-Omni-3B_v1.jsonl" \
    > logs/infer_compare_1_aspect_manual_checked_Qwen2.5-Omni-3B_v1.log 2>&1

CUDA_VISIBLE_DEVICES=0,1 python scripts/vllm_infer.py \
    --model_name_or_path /obs/pretrained_models/Qwen/Qwen2.5-Omni-3B \
    --template "qwen2_omni" \
    --dataset "yky-test"\
    --seed 123 \
    --save_name "judge-eval/infer_compare_1_aspect_Qwen2.5-Omni-3B_v2.jsonl" \
    > logs/infer_compare_1_aspect_manual_checked_Qwen2.5-Omni-3B_v2.log 2>&1

CUDA_VISIBLE_DEVICES=0,1 python scripts/vllm_infer.py \
    --model_name_or_path /obs/pretrained_models/Qwen/Qwen2.5-Omni-3B \
    --template "qwen2_omni" \
    --dataset "yky-test"\
    --seed 1234 \
    --save_name "judge-eval/infer_compare_1_aspect_Qwen2.5-Omni-3B_v3.jsonl" \
    > logs/infer_compare_1_aspect_manual_checked_Qwen2.5-Omni-3B_v3.log 2>&1
