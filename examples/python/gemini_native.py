# pip install google-genai
# Gemini 模型可以用 Google 官方 SDK 的原生接口
import os
from google import genai
from google.genai import types

client = genai.Client(
    api_key=os.environ["APIFOO_API_KEY"],
    http_options=types.HttpOptions(base_url="https://api.foo"),
)
resp = client.models.generate_content(model="gemini-3.5-flash", contents="用一句话介绍你自己")
print(resp.text)
