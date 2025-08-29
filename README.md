<h1 align="center">SageLM<img src="Figs/logo-sage.png" alt="小图标" width="35"/>: A Multi-aspect and Explainable Large Language Model for Speech Judgement</h1>
<!-- SageLM: A Multi-aspect and Explainable Large Language Model for Speech Judgement -->
<h4 align="center"> Yuan Ge, Junxiang Zhang, Xiaoqian Liu, Bei Li, Xiangnan Ma, Chenglong Wang, Kaiyang Ye, Yangfan Du, Linfeng Zhang, Yuxin Huang, Tong Xiao, Zhengtao Yu, Jingbo Zhu</h4>



​                                                           📄 [Paper](https://arxiv.org/abs/2508.20916) |  🤗[Model ](https://huggingface.co/LGB666/SageLM) | 🤗[Dataset](https://huggingface.co/LGB666/SageLM_testset_audio)

## News💡

- [2025.08] We release our paper. If you have any questions about our project, please send email to geyuanqaq@gmail.com
- Code, test dataset, and model will be released in a few days.
- The training dataset will be released after the paper is accepted.

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



We have released our test dataset at https://huggingface.co/LGB666/SageLM_testset_audio. After downloading, please move and rename the directory to `./Audio` and follow the steps above to register datasets.



### Model Inference

```
cd ./LLaMA-Factory
bash ./LLaMA-Factory/scripts/my_infer/infer.sh
```



### Evaluation

Given a user query and two response audios, SageLM produces outputs in the following format:

```
{Comparision_result(1 | 2 | Tie)}
{Rationale}
```

We used **Accuracy** and **Agreement** as quantitative metrics to evaluate the performance of SageLM.

- **Accuracy:** the proportion of predictions that exactly match the ground-truth labels.

- **Agreement:** assign a score of 1.0 when the prediction matches the ground-truth; if they differ, a score of 0.5 is assigned if either is *Tie*; and otherwise, 0.

We provide our evaluation scripts in `./LLaMA-Factory/scripts/my_infer` to reproduce the main results in our paper.



## Training of SageLM Model 📜

We trained our model using [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory). 

To train your own model, you need to register your dataset in `./LLaMA-Factory/data/dataset_info.json`. Then, specify the dataset and other training parameters in the YAML configuration file. We provide an example configuration file at `examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml`. Start training using the following commands:

```
cd ./LLaMA-Factory
llamafactory-cli train examples/judge/qwen2.5_omni_7B_compare_1_aspect.yaml
```



