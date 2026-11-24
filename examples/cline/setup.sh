#!/usr/bin/env bash
# Cline 命令行：一行配好 OpenAI 兼容接口（VS Code 插件里在设置页选 OpenAI Compatible，填同样三项）
npm install -g cline --registry=https://registry.npmmirror.com
cline auth -p openai-compatible -k "$APIFOO_API_KEY" -m gpt-6.2-sol -b https://api.foo/v1
cline --json "say hi"
