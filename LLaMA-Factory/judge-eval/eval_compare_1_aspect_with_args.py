'''
    对比 模型推理的结果 与 真实答案
'''
import json
import csv
import fire

# reference_path = "/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/data/judge_dataset_compare_1_aspect_rationale-test_manual_checked.json"

# prediction_path = "/obs/users/liuxiaoqian/Judge_SLM/LLaMA-Factory-0612/judge-eval/omni_7B_compare_1_aspect_rationale.jsonl"

def evaluate(reference_path, prediction_path):
    # 读取真实标签
    print(reference_path)
    with open(reference_path, 'r', encoding='utf-8') as f:
        ground_truth_data = json.load(f)

    # 读取模型推理结果
    predict_data = []
    with open(prediction_path, 'r', encoding='utf-8') as f:
        for line in f:
            predict_data.append(json.loads(line))

    assert len(ground_truth_data) == len(predict_data), f"{len(ground_truth_data)}, {len(predict_data)}"

    results = []
    Helpfulness = 0
    Truthfulness = 0
    Instruction_following = 0
    Honesty = 0

    Helpfulness_agreement = 0
    Truthfulness_agreement = 0
    Instruction_following_agreement = 0
    Honesty_agreement = 0

    def result_score(result):
        if result == '1':
            return 1
        elif result == '2':
            return -1
        elif result == "T":
            return 0
        
        else:
            print('Wrong format of {}'.format(result))

    def agreement_score(result_1, result_2):
        r1 = result_score(result_1)
        r2 = result_score(result_2)
        if r1 == r2:
            return 1
        elif r1 * r2 == 0:
            return 0.5
        elif r1 * r2 == -1:
            return 0
            
    incomplete = 0

    for idx, (gt, pred) in enumerate(zip(ground_truth_data, predict_data)):
        gt_output = gt.get('output', '')
        pred_output = pred.get('predict', '')

        labels_gt = gt_output[0]
        labels_pred = pred_output[0]

        if idx%4 == 0:
            match_0 = int(labels_gt == labels_pred)
            Helpfulness += match_0
            Helpfulness_agreement += agreement_score(labels_gt, labels_pred)
        elif idx%4 == 1:
            match_3 = int(labels_gt == labels_pred)
            Honesty += match_3
            Honesty_agreement += agreement_score(labels_gt, labels_pred)
        elif idx%4 == 2:    
            match_2 = int(labels_gt == labels_pred)
            Instruction_following += match_2
            Instruction_following_agreement += agreement_score(labels_gt, labels_pred)
        elif idx%4 == 3:
            match_1 = int(labels_gt == labels_pred)
            Truthfulness_agreement += agreement_score(labels_gt, labels_pred)
            Truthfulness += match_1

    Helpfulness = f"{Helpfulness * 400 / len(predict_data):.2f}%"
    Truthfulness = f"{Truthfulness * 400 / len(predict_data):.2f}%"
    Instruction_following = f"{Instruction_following * 400 / len(predict_data):.2f}%"
    Honesty = f"{Honesty * 400 / len(predict_data):.2f}%"
    # incomplete = f"{incomplete * 400 / len(predict_data):.2f}%"

    Helpfulness_agreement = f"{Helpfulness_agreement * 400 / len(predict_data):.2f}%"
    Truthfulness_agreement = f"{Truthfulness_agreement * 400 / len(predict_data):.2f}%"
    Instruction_following_agreement = f"{Instruction_following_agreement * 400 / len(predict_data):.2f}%"
    Honesty_agreement = f"{Honesty_agreement * 400 / len(predict_data):.2f}%"

    print("Result of {}".format(prediction_path.split('/')[-1][:-6]))
    print("Helpfulness\tTruthfulness\tInstruction_following:\tHonesty:\t")
    print(f"Accuracy:\t{Helpfulness}\t{Truthfulness}\t{Instruction_following}\t{Honesty}")
    print(f"Agreement:\t{Helpfulness_agreement}\t{Truthfulness_agreement}\t{Instruction_following_agreement}\t{Honesty_agreement}")
    # print(f"Imcomplate:\t{incomplete}")

    # print("result saved")

if __name__ == '__main__':
    fire.Fire(evaluate)