from typing import Any
from cog import BasePredictor, Input, Path
import torch
import requests
from PIL import Image
from transformers import AutoModelForCausalLM, LlamaTokenizer


class Predictor(BasePredictor):
    def predict(
        self,
        image: Path = Input(description="Input image"),
        query: str = Input(description="Query for the given image", default="Describe this image"),
    ) -> str:

        tokenizer = LlamaTokenizer.from_pretrained('lmsys/vicuna-7b-v1.5')
        model = AutoModelForCausalLM.from_pretrained(
            '/src/model_data/',
            torch_dtype=torch.bfloat16,
            low_cpu_mem_usage=True,
            trust_remote_code=True
        ).to('cuda').eval()

        # chat example

        q = query
        i = Image.open(image).convert('RGB')
        inputs = model.build_conversation_input_ids(tokenizer, query=q, history=[], images=[i])  # chat mode
        inputs = {
            'input_ids': inputs['input_ids'].unsqueeze(0).to('cuda'),
            'token_type_ids': inputs['token_type_ids'].unsqueeze(0).to('cuda'),
            'attention_mask': inputs['attention_mask'].unsqueeze(0).to('cuda'),
            'images': [[inputs['images'][0].to('cuda').to(torch.bfloat16)]],
        }
        gen_kwargs = {"max_length": 2048, "do_sample": False}

        with torch.no_grad():
            outputs = model.generate(**inputs, **gen_kwargs)
            outputs = outputs[:, inputs['input_ids'].shape[1]:]
            return tokenizer.decode(outputs[0])

