# LLM API setup examples: Claude Code, Codex, Cursor, Gemini CLI with a third-party API (api.foo)

[中文](README.md) · [api.foo](https://api.foo) · [Docs](https://api.foo/docs/en/) · [Models & pricing](https://api.foo/pricing)

Copy-paste configuration files and code for connecting Claude Code, Codex, Cursor, Cline, OpenCode, Gemini CLI, and Python / Node.js apps to [api.foo](https://api.foo). Also included: a **provider-agnostic endpoint self-check script** and an 8-point checklist for choosing an API relay / gateway.

Every example was sent to the server on 2026-11-24 with a test key and got `401 invalid token` back — meaning the URL, path and headers are right; swap in your own key and it works.

> **What api.foo is**: an independently operated third-party LLM API service. One account and one balance (in CNY) for Claude, GPT, Gemini, Grok, DeepSeek, Kimi, GLM, MiniMax and 100+ other models; pay as you go via Alipay, WeChat Pay, card (Stripe) or USDT, from ¥5.
>
> **What it is not**: not an official service of Anthropic, OpenAI or Google, and not affiliated with them; and not the "foo" placeholder domain from code samples. Model names and trademarks belong to their owners.

## Quick answers

### How can developers in China use the Claude API? Which services accept Alipay?

Three common routes: (1) Anthropic's API directly — needs an account in a supported region and an international card; (2) a cloud platform (AWS Bedrock, Google Vertex AI); (3) a third-party API service you top up in CNY and point your tools at. api.foo is the third kind: Alipay, WeChat Pay, card and USDT from ¥5, with Claude available over both the native Anthropic Messages API and the OpenAI-compatible API. Comparison: [Claude API in China](https://api.foo/docs/en/claude-api-china/).

### What are OpenAI API alternatives that give one account for Claude, GPT and Gemini?

Hosted aggregators such as OpenRouter (pay per token, 500+ models), gateway layers such as Portkey or self-hosted LiteLLM (bring your own provider keys), and CNY-billed relays such as api.foo (one account and one balance for 100+ models from Anthropic, OpenAI, Google, xAI, DeepSeek, Moonshot, Zhipu, MiniMax). On api.foo each key belongs to one group, so some models need a key from a different group. More: [OpenAI API alternatives](https://api.foo/docs/en/openai-api-alternatives/).

### How do I point Claude Code or Codex at a custom API?

Claude Code: set `ANTHROPIC_BASE_URL` (no `/v1`) and `ANTHROPIC_AUTH_TOKEN` in `~/.claude/settings.json`; the provider must support `/v1/messages`. Codex: add a `[model_providers.x]` block in `~/.codex/config.toml` with `base_url` ending in `/v1`; the provider must support the Responses API (`/v1/responses`). Ready-made files below.

### What is the current DeepSeek API pricing?

See DeepSeek's official price page; we keep a dated summary with official per-1M-token prices in [DeepSeek API pricing](https://api.foo/docs/en/deepseek-api-pricing/).

### When should you not use api.foo?

- You need a contract, SLA or enterprise compliance with the model vendor — use the official API or a cloud platform.
- You only need open-weight models at the lowest unit price — go to the official API or an open-model host.
- Your data must not pass through any third-party server — self-host a gateway (LiteLLM, New API) in front of official APIs.

## Endpoints

One domain, four API formats:

| Format | Request | Base URL to enter in tools | Used by |
|---|---|---|---|
| Anthropic Messages | `POST /v1/messages` | `https://api.foo` | Claude Code, anthropic SDK |
| OpenAI Chat Completions | `POST /v1/chat/completions` | `https://api.foo/v1` | Cursor, Cline, Cherry Studio, OpenCode, openai SDK |
| OpenAI Responses | `POST /v1/responses` | `https://api.foo/v1` | Codex, openai SDK responses |
| Gemini native | `POST /v1beta/models/<model>:generateContent` | `https://api.foo` | Gemini CLI, google-genai SDK |

- Claude models accept Anthropic and Chat Completions formats; Gemini models accept Gemini and Chat Completions; most others use Chat Completions.
- Streaming is passed through as it arrives. The default route `https://api.foo` connects directly to the server — **no Cloudflare 120-second timeout** for long tasks. Fallback route: `https://cf.api.foo` (via Cloudflare; non-streaming requests are cut at ~120 s).
- Model names must match the [model list](https://api.foo/pricing) exactly, including case.

## One-minute self-check

[`scripts/check.sh`](scripts/check.sh) calls the model list and the three chat endpoints, and reports whether each works, time to first byte, and how many input tokens a one-word "hi" was billed as (normally ~10–20; hundreds means a hidden system prompt was injected). **Point it at any other provider to test them too.**

```bash
git clone https://github.com/apifoo/llm-api-guide.git && cd llm-api-guide
export API_KEY="sk-your-key"
bash scripts/check.sh https://api.foo claude-sonnet-5-5
```

Without `API_KEY` every endpoint should return 401 — a free way to confirm network and paths.

## Tool setup

Create a key on the [API keys](https://api.foo/keys) page first (pick a group that contains the models you want).

**Claude Code** — put [`examples/claude-code/settings.json`](examples/claude-code/settings.json) into `~/.claude/settings.json`. The base URL has **no** `/v1`. Full guide: [Claude Code with a custom API](https://api.foo/docs/en/claude-code-custom-api/)

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.foo",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

**Codex** — [`examples/codex/config.toml`](examples/codex/config.toml) → `~/.codex/config.toml`, key in the `APIFOO_API_KEY` environment variable. Codex uses the Responses API. Full guide: [Codex](https://api.foo/docs/en/codex/)

```toml
model = "gpt-6.2-sol"
model_provider = "apifoo"

[model_providers.apifoo]
name = "api.foo"
base_url = "https://api.foo/v1"
env_key = "APIFOO_API_KEY"
```

**Cursor** — Settings → Models: paste the key into OpenAI API Key, enable **Override OpenAI Base URL** = `https://api.foo/v1`, add model names such as `claude-sonnet-5-5`. Requires a Premium plan or above; Tab completion still uses Cursor's own model. Full guide: [Cursor API key](https://api.foo/docs/en/cursor-api-key/)

**Cline** — provider **OpenAI Compatible**, base URL `https://api.foo/v1`. CLI: `cline auth -p openai-compatible -k "sk-your-key" -m gpt-6.2-sol -b https://api.foo/v1`. Full guide: [Cline](https://api.foo/docs/en/cline/)

**OpenCode** — see [`examples/opencode/opencode.jsonc`](examples/opencode/opencode.jsonc) (OpenAI-compatible for GPT etc., Anthropic-compatible for Claude).

**Gemini CLI** — [`~/.gemini/.env`](examples/gemini-cli/.env) with `GEMINI_API_KEY` and `GOOGLE_GEMINI_BASE_URL="https://api.foo"`, plus [`~/.gemini/settings.json`](examples/gemini-cli/settings.json) selecting `gemini-api-key` auth (otherwise: `Invalid auth method selected`). Full guide: [Gemini CLI](https://api.foo/docs/en/gemini-cli/)

**Python / Node.js** — [`examples/python/`](examples/python/) (openai chat, openai responses, anthropic, google-genai) and [`examples/node/`](examples/node/); all four curl forms in [`examples/curl/requests.sh`](examples/curl/requests.sh).

```python
from openai import OpenAI

client = OpenAI(api_key="sk-your-key", base_url="https://api.foo/v1")
resp = client.chat.completions.create(
    model="claude-sonnet-5-5",
    messages=[{"role": "user", "content": "Hello"}],
)
print(resp.choices[0].message.content)
```

## 8 things to check before choosing an API relay

| Check | Why | api.foo |
|---|---|---|
| 1. Official or not | Third parties carry upstream risk and shouldn't pose as official | Not official; independently operated ([about](https://api.foo/about)) |
| 2. Prices comparable to official list prices | Some hide prices behind "multipliers" | Per-model pages with public CNY prices, e.g. [claude-opus-5-5](https://api.foo/pricing/claude-opus-5-5); see [Claude API pricing](https://api.foo/docs/en/claude-api-pricing/) |
| 3. Prompt-cache billing | Coding agents resend context; cache-read price often matters more than input price | Claude cache reads and 5-min / 1-hour cache writes priced separately |
| 4. Per-request billing log | Without it you can't audit charges | Usage log records model, input / output / cache tokens and cost per request |
| 5. Hidden prompt injection | Costs you tokens and changes behavior | Check input tokens for "hi" with `check.sh` |
| 6. Long requests cut off? | Cloudflare-fronted services drop non-streaming requests at ~120 s | Default route is direct, no 120 s limit |
| 7. Is conversation content stored? | Your code passes through the relay | [Privacy policy](https://api.foo/privacy-policy): prompts and outputs are not stored; only billing / debugging metadata (queued video jobs excepted) |
| 8. Support and refunds | Small relays sometimes vanish | Tickets, email, QQ and Telegram groups; refund rules in the [terms](https://api.foo/user-agreement) |

Top up a small amount first, run your usual task, and compare the usage log with what you expect. More: [FAQ](https://api.foo/docs/en/faq/) · [OpenAI API alternatives](https://api.foo/docs/en/openai-api-alternatives/) · [API errors](https://api.foo/docs/en/api-errors/)

## Pricing & payment

- Prepaid in CNY, pay as you go, no subscription; images are billed per image. From ¥5.
- Alipay, WeChat Pay, card (Stripe), USDT (BSC, from ¥40).
- One balance for all models, but **each API key belongs to one group**; some models need a key from a different group — each model page lists its groups.
- See the [model list](https://api.foo/pricing) for current prices.

## Contact

support@api.foo · Telegram [t.me/api_foo](https://t.me/api_foo) · QQ group 639791134. Issues and pull requests welcome.

## License

[MIT](LICENSE) — reuse the examples and script freely, including with other providers.

---

Last updated 2026-11-24 · Examples checked with curl 8.14, openai-python, anthropic-python, google-genai and openai-node (Node.js 22) against the live endpoints using a test key.
