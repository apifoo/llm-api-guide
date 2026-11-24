#!/usr/bin/env bash
# 四种接口格式的 curl 写法。先：export APIFOO_API_KEY="sk-你的密钥"

# 1) OpenAI Chat Completions —— 任何模型
curl https://api.foo/v1/chat/completions \
  -H "Authorization: Bearer $APIFOO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-pro","messages":[{"role":"user","content":"你好"}]}'

# 2) Anthropic Messages —— Claude 模型
curl https://api.foo/v1/messages \
  -H "x-api-key: $APIFOO_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-5-5","max_tokens":256,"messages":[{"role":"user","content":"你好"}]}'

# 3) OpenAI Responses —— GPT 模型（Codex 用这个）
curl https://api.foo/v1/responses \
  -H "Authorization: Bearer $APIFOO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-6.2-sol","input":"你好"}'

# 4) Gemini 原生 —— Gemini 模型
curl "https://api.foo/v1beta/models/gemini-3.5-flash:generateContent" \
  -H "x-goog-api-key: $APIFOO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"你好"}]}]}'
