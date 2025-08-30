import json
import csv
import fire
import re
from os.path import basename

def evaluate(reference_path, prediction_path):
    print(reference_path)
    with open(reference_path, 'r', encoding='utf-8') as f:
        ground_truth_data = json.load(f)

    predict_data = []
    with open(prediction_path, 'r', encoding='utf-8') as f:
        for line in f:
            predict_data.append(json.loads(line))

    assert len(ground_truth_data) == len(predict_data), f"{len(ground_truth_data)}, {len(predict_data)}"

    results = []
    Emotion = 0
    Gender = 0
    Character = 0
    Mixed = 0
    Implicit = 0

    Emotion_TTS, Gender_TTS, Character_TTS, Emotion_QA, Gender_QA, Character_QA = 0,0,0,0,0,0
    Emotion_count, Gender_count, Character_count, Mixed_count, Implicit_count = 0, 0, 0, 0, 0

    Emotion_TTS_count, Gender_TTS_count, Character_TTS_count, \
    Emotion_QA_count, Gender_QA_count, Character_QA_count = 0,0,0,0,0,0

    Emotion_agreement = 0
    Gender_agreement = 0
    Character_agreement = 0
    Mixed_agreement = 0
    Implicit_agreement = 0

    Emotion_TTS_agreement = 0
    Gender_TTS_agreement = 0
    Character_TTS_agreement = 0
    Emotion_QA_agreement = 0
    Gender_QA_agreement = 0
    Character_QA_agreement = 0

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

        dim = re.search(r'Evaluate in terms of \*\*(.*)\*\*', gt['instruction'], re.DOTALL).group(1)

        if dim == 'emotion instruction following':
            if 'Implicit-Emotion' in gt['audios'][0]:
                Implicit_count += 1
                # print(gt['audios'][0], labels_gt, labels_pred)
                match_5 = int(labels_gt == labels_pred)
                Implicit += match_5
                Implicit_agreement += agreement_score(labels_gt, labels_pred)
            else:
                Emotion_count += 1
                match_0 = int(labels_gt == labels_pred)
                Emotion += match_0
                Emotion_agreement += agreement_score(labels_gt, labels_pred)

                instruction_id1 = basename(gt['audios'][0]).split('-')[1]
                response_id1 = basename(gt['audios'][0]).split('-')[2]
                instruction_id2 = basename(gt['audios'][1]).split('-')[1]
                response_id2 = basename(gt['audios'][1]).split('-')[2]
                assert instruction_id1 == instruction_id2
                if response_id1 == response_id2:  # TTS
                    Emotion_TTS_count += 1
                    match_0 = int(labels_gt == labels_pred)
                    Emotion_TTS += match_0
                    Emotion_TTS_agreement += agreement_score(labels_gt, labels_pred)
                else:
                    Emotion_QA_count += 1
                    match_0 = int(labels_gt == labels_pred)
                    Emotion_QA += match_0
                    Emotion_QA_agreement += agreement_score(labels_gt, labels_pred)

        elif dim == 'gender instruction following':
            Gender_count += 1
            match_1 = int(labels_gt == labels_pred)
            Gender += match_1
            Gender_agreement += agreement_score(labels_gt, labels_pred)

            instruction_id1 = basename(gt['audios'][0]).split('-')[1]
            response_id1 = basename(gt['audios'][0]).split('-')[2]
            instruction_id2 = basename(gt['audios'][1]).split('-')[1]
            response_id2 = basename(gt['audios'][1]).split('-')[2]
            assert instruction_id1 == instruction_id2
            if response_id1 == response_id2:  # TTS
                Gender_TTS_count += 1
                match_0 = int(labels_gt == labels_pred)
                Gender_TTS += match_0
                Gender_TTS_agreement += agreement_score(labels_gt, labels_pred)
            else:
                Gender_QA_count += 1
                match_0 = int(labels_gt == labels_pred)
                Gender_QA += match_0
                Gender_QA_agreement += agreement_score(labels_gt, labels_pred) 

        elif dim == 'character instruction following':  
            Character_count += 1  
            match_2 = int(labels_gt == labels_pred)
            Character += match_2
            Character_agreement += agreement_score(labels_gt, labels_pred)

            instruction_id1 = basename(gt['audios'][0]).split('-')[1]
            response_id1 = basename(gt['audios'][0]).split('-')[2]
            instruction_id2 = basename(gt['audios'][1]).split('-')[1]
            response_id2 = basename(gt['audios'][1]).split('-')[2]
            assert instruction_id1 == instruction_id2
            if response_id1 == response_id2:  # TTS
                Character_TTS_count += 1
                match_0 = int(labels_gt == labels_pred)
                Character_TTS += match_0
                Character_TTS_agreement += agreement_score(labels_gt, labels_pred)
            else:
                Character_QA_count += 1
                match_0 = int(labels_gt == labels_pred)
                Character_QA += match_0
                Character_QA_agreement += agreement_score(labels_gt, labels_pred)

        elif dim == 'gender instruction following and emotion instruction following':
            Mixed_count += 1
            match_3 = int(labels_gt == labels_pred)
            Mixed += match_3
            Mixed_agreement += agreement_score(labels_gt, labels_pred)

    # print(f"emotion count: {Emotion_count}, implicit count: {Implicit_count}")
    Emotion = f"{Emotion * 100 / Emotion_count:.2f}%"
    Gender = f"{Gender * 100 / Gender_count:.2f}%"
    Character = f"{Character * 100 / Character_count:.2f}%"
    Mixed = f"{Mixed * 100 / Mixed_count:.2f}%"
    Implicit = f"{Implicit * 100 / Implicit_count:.2f}%"

    
    # incomplete = f"{incomplete * 400 / len(predict_data):.2f}%"

    Emotion_agreement = f"{Emotion_agreement * 100 / Emotion_count:.2f}%"
    Gender_agreement = f"{Gender_agreement * 100 / Gender_count:.2f}%"
    Character_agreement = f"{Character_agreement * 100 / Character_count:.2f}%"
    Mixed_agreement = f"{Mixed_agreement * 100 / Mixed_count:.2f}%"
    Implicit_agreement = f"{Implicit_agreement * 100 / Implicit_count:.2f}%"

    print("Result of {}".format(prediction_path.split('/')[-1][:-6]))
    print("Emotion\tGender\tCharacter:\tImplicit_Emotion:\tMixed:\t")
    print(f"Accuracy:\t{Emotion}\t{Gender}\t{Character}\t{Implicit}\t{Mixed}")
    print(f"Agreement:\t{Emotion_agreement}\t{Gender_agreement}\t{Character_agreement}\t{Implicit_agreement}\t{Mixed_agreement}")
    # print(f"Imcomplate:\t{incomplete}")

    Emotion_TTS_acc = f"{Emotion_TTS * 100 / Emotion_TTS_count:.2f}%" if Emotion_TTS_count else "N/A"
    Emotion_QA_acc = f"{Emotion_QA * 100 / Emotion_QA_count:.2f}%" if Emotion_QA_count else "N/A"
    Gender_TTS_acc = f"{Gender_TTS * 100 / Gender_TTS_count:.2f}%" if Gender_TTS_count else "N/A"
    Gender_QA_acc = f"{Gender_QA * 100 / Gender_QA_count:.2f}%" if Gender_QA_count else "N/A"
    Character_TTS_acc = f"{Character_TTS * 100 / Character_TTS_count:.2f}%" if Character_TTS_count else "N/A"
    Character_QA_acc = f"{Character_QA * 100 / Character_QA_count:.2f}%" if Character_QA_count else "N/A"

    Emotion_TTS_agree = f"{Emotion_TTS_agreement * 100 / Emotion_TTS_count:.2f}%" if Emotion_TTS_count else "N/A"
    Emotion_QA_agree = f"{Emotion_QA_agreement * 100 / Emotion_QA_count:.2f}%" if Emotion_QA_count else "N/A"
    Gender_TTS_agree = f"{Gender_TTS_agreement * 100 / Gender_TTS_count:.2f}%" if Gender_TTS_count else "N/A"
    Gender_QA_agree = f"{Gender_QA_agreement * 100 / Gender_QA_count:.2f}%" if Gender_QA_count else "N/A"
    Character_TTS_agree = f"{Character_TTS_agreement * 100 / Character_TTS_count:.2f}%" if Character_TTS_count else "N/A"
    Character_QA_agree = f"{Character_QA_agreement * 100 / Character_QA_count:.2f}%" if Character_QA_count else "N/A"

    print("\n--- Detailed TTS/QA Split ---")
    print("Type\tEmotion_TTS\tEmotion_QA\tGender_TTS\tGender_QA\tCharacter_TTS\tCharacter_QA\tImplicit_Emotion")
    print("Accuracy:\t" +
          f"{Emotion_TTS_acc}\t{Emotion_QA_acc}\t{Gender_TTS_acc}\t{Gender_QA_acc}\t{Character_TTS_acc}\t{Character_QA_acc}\t{Implicit}")
    print("Agreement:\t" +
          f"{Emotion_TTS_agree}\t{Emotion_QA_agree}\t{Gender_TTS_agree}\t{Gender_QA_agree}\t{Character_TTS_agree}\t{Character_QA_agree}\t{Implicit_agreement}")

if __name__ == '__main__':
    fire.Fire(evaluate)