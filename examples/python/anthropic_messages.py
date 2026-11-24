# pip install anthropic
# Claude 模型也可以用 Anthropic 原生接口（支持提示缓存、思考等原生参数）
import os
import anthropic

client = anthropic.Anthropic(api_key=os.environ["APIFOO_API_KEY"], base_url="https://api.foo")

msg = client.messages.create(
    model="claude-sonnet-5-5",
    max_tokens=512,
    messages=[{"role": "user", "content": "用一句话介绍你自己"}],
)
print(msg.content[0].text)
