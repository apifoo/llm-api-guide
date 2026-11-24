# pip install openai
# OpenAI Responses 接口（Codex 用的就是它）
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["APIFOO_API_KEY"], base_url="https://api.foo/v1")

resp = client.responses.create(model="gpt-6.2-sol", input="用一句话介绍你自己")
print(resp.output_text)
