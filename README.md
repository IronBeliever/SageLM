<h1 align="center">SageLM<img src="Figs/logo-sage.png" alt="小图标" width="35"/>: A Multi-aspect and Explainable Large Language Model for Speech Judgement</h1>
<!-- SageLM: A Multi-aspect and Explainable Large Language Model for Speech Judgement -->
<h4 align="center"> Yuan Ge, Junxiang Zhang, Xiaoqian Liu, Bei Li, Xiangnan Ma, Chenglong Wang, Kaiyang Ye, Yangfan Du, Linfeng Zhang, Yuxin Huang, Tong Xiao, Zhengtao Yu, Jingbo Zhu</h4>

<p align="center">
  📄 <a href="https://arxiv.org/abs/2508.20916">Paper</a> | 
  🤗 <a href="https://huggingface.co/LGB666/SageLM">Model</a> | 
  🤗 <a href="https://huggingface.co/datasets/LGB666/SageLM_testset_audio">Dataset</a>
</p>


## News💡

- [2025.08] We release our paper. If you have any questions about our project, please send email to geyuanqaq@gmail.com
- ~~Code, test dataset, and model will be released in a few days.~~
- [2025.08.30] Code, test dataset, and model parameters have been publicly released.
- The training dataset will be released after the paper is accepted.
- [2025.11] SageLM is accepted by AAAI 2026 poster!🎉🎉🎉



## Quick Installation ⚙️

```
conda create -n sagelm python=3.10
conda activate sagelm
cd ./LLaMA-Factory
pip install -e .
```



## Usage 🛠

### Data Preparation

In order to use SageLM, you should first create a JSON file for your dataset in `./LLaMA-Factory/data`. Each entry should have the following format:

```
{
	"instruction": "...",  // prompt
	"input": "",  // leave empty
	"output": "...",  // label (used during training, leave empty during inference)
	"audios": [
		"",  // audio response 1
		""   // audio response 2
	]
}
```



We use the following prompt template for SageLM training and inference:

```
Below are two responses for a given task. The task is defined by the Instruction. Evaluate in terms of **{eval_dim}** and indicate a better response using 1, 2 or Tie.

### Instruction:
{question}

### Response 1:
<audio>

### Response 2:
<audio>

```

where `{eval_dim}` represents the evaluation dimension , `{question}` represents the user query, and \<audio\> serves as a placeholder for audio responses.



Next, register your dataset in `./LLaMA-Factory/data/dataset_info.json`. For example:

```
"test_semantic": {
    "file_name": "test_semantic.json",
    "columns": {
        "prompt": "instruction",
        "query": "input",
        "response": "output",
        "audios": "audios"
    }
}
```



### Model Inference

```
cd ./LLaMA-Factory
bash ./LLaMA-Factory/scripts/my_infer/infer.sh
```

Notice: SageLM currently supports only **English** and evaluated audio (audio 1 & audio 2) is **truncated to 60 s**.

We currently only support batch inference with JSON datasets, but inference can also be performed using the [Qwen2.5-Omni](https://github.com/QwenLM/Qwen2.5-Omni) official code.



### Evaluation

We have released our test dataset at https://huggingface.co/LGB666/SageLM_testset_audio. After downloading, please move and rename the directory to match the audio paths in the corresponding dataset JSON file.

We also released our evaluation scripts to reproduce the main results in our paper.



To evaluate the model's udging performance on **semantic** dimensions, run:

```
bash ./LLaMA-Factory/scripts/eval.sh
```

Note that each response pair in prediction and ground-truth files should be splited into four semantic dimensions, in the order of `helpfulness, honesty, instruction_following, truthfulness`. The data order should be consistent between the prediction and the ground-truth files.



To evaluate the model's judging performance on **acoustic** dimensions, run:

```
bash ./LLaMA-Factory/scripts/eval_stage2.sh
```



The acoustic evaluation should be performed on one of the following dimensions: `emotion instruction following, gender instruction following, character instruction following, gender instruction following and emotion instruction following`. The data order should also be consistent between the prediction and the ground-truth.



## Training of SageLM Model 📜

We trained our model using [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory). 

To train your own model, you need to register your dataset in `./LLaMA-Factory/data/dataset_info.json`. Then, specify the dataset and other training parameters in the YAML configuration file. We provide an example configuration file at `examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml`. Start training using the following commands:

```
cd ./LLaMA-Factory
llamafactory-cli train examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml
```



## 🔊 End-to-End Speech Evaluation vs. Cascade ASR → LLM: A Case Study

Traditional cascade approaches first use **Whisper for ASR**, then pass the transcript to a text-based LLM for **response comparison**.
However, ASR can introduce **cascaded errors**, which may lead GPT to **incorrectly favor one response over another**.

SageLM is trained **end-to-end on audio** and does *not* rely on ASR transcripts, making it robust to **pronunciation variations, disfluencies, and unclear articulation**. Here we show several real cases to demonstrate these effects.

Note that in these cases we focus solely on **semantic dimensions** (Helpfulness, Honesty, Truthfulness, Instruction Following). Thus, **disfluencies or unclear articulation in the audio should not affect the semantic comparison**.



### Case 1

**❓Question:**  

> **Come up with healthy and easy dinner ideas for weeknights.**

**🔊Response 1 (Qwen2.5-Omni)**  

<audio controls>
  <source src="./demo_audio/16/Qwen2.5-omni-Audio.wav" type="audio/wav">
</audio>
**🔊Response 2 (Kimi-Audio)**  

<audio controls>
  <source src="./demo_audio/16/Kimi-Audio.wav" type="audio/wav">
</audio>
📊 **Comparison Results (1 = Response 1 better, 2 = Response 2 better, T = Tie)**

| **Method**                          | **Helpfulness** | **Honesty** | **Truthfulness** | **Instruction Following** |
| ----------------------------------- | --------------- | ----------- | ---------------- | ------------------------- |
| **GPT (Whisper-large-v3 + GPT-4o)** | **1**           | **1**       | **1**            | **1**                     |
| **SageLM**                          | **2**           | **T**       | **2**            | **T**                     |
| **Human Evaluation**                | **2**           | **T**       | **2**            | **T**                     |

### Case 2

**❓Question:**  

> **For a quick and efficient office workout, suggest a short routine.**

**🔊Response 1 (Qwen2.5-Omni)**  

<audio controls>
  <source src="./demo_audio/18/Qwen2.5-omni-Audio.wav" type="audio/wav">
</audio>

**🔊Response 2 (Kimi-Audio)**  

<audio controls>
  <source src="./demo_audio/18/Kimi-Audio.wav" type="audio/wav">
</audio>

📊 **Comparison Results**

| **Method**           | **Helpfulness** | **Honesty** | **Truthfulness** | **Instruction Following** |
| -------------------- | --------------- | ----------- | ---------------- | ------------------------- |
| **GPT**              | **1**           | **1**       | **T**            | **1**                     |
| **SageLM**           | **2**           | **2**       | **2**            | **T**                     |
| **Human Evaluation** | **2**           | **T**       | **T**            | **T**                     |

### Case 3

**❓Question:**  

> **How can I create a budget and stick to it for better financial health?**

**🔊Response 1 (Qwen2.5-Omni)**  

<audio controls>
  <source src="./demo_audio/53/Qwen2.5-omni-Audio.wav" type="audio/wav">
</audio>

**🔊Response 2 (Kimi-Audio)**  

<audio controls>
  <source src="./demo_audio/53/Kimi-Audio.wav" type="audio/wav">
</audio>

📊 **Comparison Results**

| **Method**           | **Helpfulness** | **Honesty** | **Truthfulness** | **Instruction Following** |
| -------------------- | --------------- | ----------- | ---------------- | ------------------------- |
| **GPT**              | **1**           | **T**       | **1**            | **1**                     |
| **SageLM**           | **T**           | **T**       | **T**            | **T**                     |
| **Human Evaluation** | **T**           | **T**       | **T**            | **T**                     |



## Citation 

If you find our paper useful, please consider citing:
```bibtex
@article{ge2025sagelm,
  title={SageLM: A Multi-aspect and Explainable Large Language Model for Speech Judgement},
  author={Ge, Yuan and Zhang, Junxiang and Liu, Xiaoqian and Li, Bei and Ma, Xiangnan and Wang, Chenglong and Ye, Kaiyang and Du, Yangfan and Zhang, Linfeng and Huang, Yuxin and others},
  journal={arXiv preprint arXiv:2508.20916},
  year={2025}
}
```
