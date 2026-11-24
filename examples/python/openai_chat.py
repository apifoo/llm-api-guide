# pip install openai
# 用 OpenAI SDK 调任何模型（Claude、GPT、Gemini、DeepSeek……都走 Chat Completions）
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["APIFOO_API_KEY"], base_url="https://api.foo/v1")

resp = client.chat.completions.create(
    model="claude-sonnet-5-5",  # 换成模型广场 https://api.foo/pricing 上的任意模型名
    messages=[{"role": "user", "content": "用一句话介绍你自己"}],
)
print(resp.choices[0].message.content)
