import time
from typing import Any
from cog import BasePredictor, Input, Path
import torch
import requests
from PIL import Image
from transformers import AutoModelForCausalLM, LlamaTokenizer


class Predictor(BasePredictor):
    def setup(self):
        self.tokenizer = LlamaTokenizer.from_pretrained('lmsys/vicuna-7b-v1.5')
        self.model = AutoModelForCausalLM.from_pretrained(
            '/src/model_data/',
            torch_dtype=torch.bfloat16,
            low_cpu_mem_usage=True,
            trust_remote_code=True
        ).to('cuda').eval()
    def predict(
        self,
        image: Path = Input(description="Input image"),
        query: str = Input(description="Query for the given image", default="Describe this image"),
    ) -> str:
        start_time = time.time()
        q = query
        i = Image.open(image).convert('RGB')
        inputs = self.model.build_conversation_input_ids(self.tokenizer, query=q, history=[], images=[i])  # chat mode
        inputs = {
            'input_ids': inputs['input_ids'].unsqueeze(0).to('cuda'),
            'token_type_ids': inputs['token_type_ids'].unsqueeze(0).to('cuda'),
            'attention_mask': inputs['attention_mask'].unsqueeze(0).to('cuda'),
            'images': [[inputs['images'][0].to('cuda').to(torch.bfloat16)]],
        }
        gen_kwargs = {"max_length": 2048, "do_sample": False}
        print(f"Time taken before generating: {time.time() - start_time}")
        with torch.no_grad():
            outputs = self.model.generate(**inputs, **gen_kwargs)
            outputs = outputs[:, inputs['input_ids'].shape[1]:]
            print(f"Time taken for generation: {time.time() - start_time}")
            return self.tokenizer.decode(outputs[0])
