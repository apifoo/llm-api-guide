#!/usr/bin/env bash
# 大模型 API 接口自测脚本（任何 OpenAI / Anthropic 兼容的服务都能用）
# LLM API endpoint self-check (works with any OpenAI / Anthropic compatible provider)
#
# 用法 / Usage:
#   export API_KEY="sk-你的密钥"
#   bash scripts/check.sh https://api.foo claude-sonnet-5-5
#
#   第 1 个参数：服务地址（不带 /v1），默认 https://api.foo
#   第 2 个参数：要测的模型名，默认 claude-sonnet-5-5
#
# 它会依次请求 4 个常用接口，告诉你每个接口通不通、多久返回第一个字节，
# 以及一句很短的话被算成了多少输入 token（多出几百个，说明中间被加了看不见的提示词）。
# 只发很短的请求（max_tokens ≤ 16），一次自测通常花不到 1 分钱。
# 没设 API_KEY 也能跑：会得到 401，用来确认地址和路径写对了（不花钱）。

set -u
BASE="${1:-https://api.foo}"
BASE="${BASE%/}"
BASE="${BASE%/v1}"
MODEL="${2:-claude-sonnet-5-5}"
KEY="${API_KEY:-}"

if ! command -v curl >/dev/null 2>&1; then
  echo "需要 curl / curl is required"; exit 1
fi

say() { printf '%s\n' "$*"; }
line() { printf -- '------------------------------------------------------------\n'; }

hint() {
  case "$1" in
    200) say "  结果：通了 ✓ / OK" ;;
    401) say "  结果：401 —— 地址和路径对了，已经到了验证密钥这一步；密钥错了、没带或额度用完会是这个 / path OK, key rejected" ;;
    403) say "  结果：403 —— 余额不足，或密钥限制了模型 / IP / insufficient balance or key restriction" ;;
    404) say "  结果：404 —— 路径不对，检查地址是不是多写或少写了 /v1 / wrong path" ;;
    429) say "  结果：429 —— 请求太快或上游限流，等一会儿再试 / rate limited" ;;
    000) say "  结果：连不上 —— 检查网络、地址拼写 / connection failed" ;;
    5*)  say "  结果：$1 —— 服务端或上游出错，过几十秒重试 / upstream error" ;;
    *)   say "  结果：$1" ;;
  esac
}

tokens() {
  # 从返回里找输入 token 数（OpenAI: prompt_tokens / input_tokens，Anthropic: input_tokens）
  grep -o -E '"(prompt_tokens|input_tokens)"[[:space:]]*:[[:space:]]*[0-9]+' "$1" | head -1 | grep -o -E '[0-9]+$'
}

TMP="$(mktemp -t llmcheck.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

req() { # name method path [body] [extra headers...]
  local name="$1" method="$2" path="$3" body="${4:-}"; shift 4 || shift $#
  line
  say "$name"
  say "  $method $BASE$path"
  local args=(-sS -o "$TMP" -w '%{http_code} %{time_starttransfer}' -X "$method" --max-time 90 "$BASE$path"
              -H "content-type: application/json")
  for h in "$@"; do args+=(-H "$h"); done
  [ -n "$body" ] && args+=(-d "$body")
  local out code ttfb
  out="$(curl "${args[@]}" 2>/dev/null)"; [ -z "$out" ] && out="000 0"
  code="${out%% *}"; ttfb="${out#* }"
  hint "$code"
  say "  首字节耗时 / time to first byte：${ttfb}s"
  if [ "$code" = "200" ]; then
    local t; t="$(tokens "$TMP")"
    [ -n "$t" ] && say "  输入 token / input tokens：$t（一句「hi」正常只有十几个 / ~10-20 is normal for \"hi\"）"
  else
    say "  返回 / body：$(head -c 300 "$TMP")"
  fi
}

say "服务地址 / base：$BASE    模型 / model：$MODEL"
[ -z "$KEY" ] && say "（没设 API_KEY：下面应该都是 401，用来确认路径 / API_KEY not set, expect 401）"

req "1. 模型列表 / model list" GET "/v1/models" "" \
  "Authorization: Bearer $KEY"

req "2. OpenAI Chat Completions（Cursor、Cline、Cherry Studio、openai SDK 用这个）" POST "/v1/chat/completions" \
  "{\"model\":\"$MODEL\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
  "Authorization: Bearer $KEY"

req "3. Anthropic Messages（Claude Code、anthropic SDK 用这个，只有 Claude 模型）" POST "/v1/messages" \
  "{\"model\":\"$MODEL\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
  "x-api-key: $KEY" "anthropic-version: 2023-06-01"

req "4. OpenAI Responses（Codex 用这个）" POST "/v1/responses" \
  "{\"model\":\"$MODEL\",\"max_output_tokens\":16,\"input\":\"hi\"}" \
  "Authorization: Bearer $KEY"

line
say "说明：某个接口报「模型不存在 / 无可用渠道」不一定是服务坏了——有的模型只支持其中几种接口，"
say "或者这把密钥所在的分组里没有这个模型。换一个模型名再试。"
say "Note: \"model not found\" on one endpoint can be normal: not every model supports every API format."
