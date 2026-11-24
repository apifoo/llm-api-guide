# 大模型 API 接入示例：Claude Code、Codex、Cursor、Gemini CLI 配置第三方 API（api.foo）

[English](README.en.md) · [官网 api.foo](https://api.foo) · [完整文档](https://api.foo/docs/) · [模型与价格](https://api.foo/pricing)

这个仓库放的是**能直接复制使用的配置文件和代码**：把 Claude Code、Codex、Cursor、Cline、OpenCode、Gemini CLI，以及 Python / Node.js 程序接到 [api.foo](https://api.foo) 上。另有一个**任何中转站都能用的接口自测脚本**，和挑 API 中转站时要核对的 8 件事。

所有示例都在 2026-11-24 用测试密钥请求过一遍，服务器都返回「401 无效的令牌」：这说明地址、路径、请求头都写对了，换上你自己的密钥就能用。

> **api.foo 是什么**：独立运营的第三方大模型 API 服务。一个账号、一份人民币余额，调用 Claude、GPT、Gemini、Grok、DeepSeek、Kimi、GLM、MiniMax 等 100 多个模型；按量计费，支付宝、微信、银行卡、USDT 都能充，¥5 起充。
>
> **它不是什么**：不是 Anthropic、OpenAI、Google 的官方服务，和它们没有隶属或合作关系；也不是程序员写示例时用的占位网址（foo 在编程里常当「某某」用）。文中的模型名称和商标归各自所有者。

## 目录

- [接口地址一览](#接口地址一览)
- [一分钟自测：地址和密钥对不对](#一分钟自测地址和密钥对不对)
- [各工具怎么配](#各工具怎么配)：[Claude Code](#claude-code) · [Codex](#codex) · [Cursor](#cursor) · [Cline](#cline) · [OpenCode](#opencode) · [Gemini CLI](#gemini-cli) · [Python / Node.js](#python--nodejs)
- [挑 API 中转站要核对的 8 件事](#挑-api-中转站要核对的-8-件事)
- [常见报错](#常见报错)
- [价格和付款](#价格和付款)

## 接口地址一览

四种接口格式用同一个域名 `https://api.foo`，只是路径不同：

| 接口格式 | 请求地址 | 软件里填的地址 | 谁在用 |
|---|---|---|---|
| Anthropic Messages | `POST /v1/messages` | `https://api.foo` | Claude Code、anthropic SDK |
| OpenAI Chat Completions | `POST /v1/chat/completions` | `https://api.foo/v1` | Cursor、Cline、Cherry Studio、OpenCode、openai SDK |
| OpenAI Responses | `POST /v1/responses` | `https://api.foo/v1` | Codex、openai SDK 的 responses 接口 |
| Gemini 原生 | `POST /v1beta/models/<模型>:generateContent` | `https://api.foo` | Gemini CLI、google-genai SDK |

- Claude 模型支持 Anthropic 和 Chat Completions 两种格式，Gemini 模型支持 Gemini 和 Chat Completions 两种，其余多数是 Chat Completions。
- 流式输出边收边转。默认线路 `https://api.foo` 直连服务器，**没有 Cloudflare 的 120 秒超时**，长任务直接用它；连不上时可以换中转线路 `https://cf.api.foo`（经 Cloudflare，非流式约 120 秒会断开）。
- 模型名要和[模型广场](https://api.foo/pricing)上的一字不差（含大小写）。

## 一分钟自测：地址和密钥对不对

[`scripts/check.sh`](scripts/check.sh) 依次请求模型列表和三种对话接口，告诉你每个接口通不通、首字节多久返回，以及一句「hi」被算成多少输入 token（正常十几个；多出几百个，说明中间被加了看不见的提示词）。**换个地址就能测别家中转站**。

```bash
git clone https://github.com/apifoo/llm-api-guide.git && cd llm-api-guide
export API_KEY="sk-你的密钥"
bash scripts/check.sh https://api.foo claude-sonnet-5-5
```

没设 `API_KEY` 也能跑：每个接口都应该返回 401，用来确认网络和路径没问题（不花钱）。设了真密钥，一次自测只发 4 个很短的请求。

## 各工具怎么配

下面每一节是最短可用的写法，完整步骤（安装、Windows 写法、报错）见对应的文档链接。先在 api.foo 控制台的 [API 密钥](https://api.foo/keys) 页建一把密钥（分组选有你要用的模型的那个）。

### Claude Code

把 [`examples/claude-code/settings.json`](examples/claude-code/settings.json) 的内容写进 `~/.claude/settings.json`（Windows：`C:\Users\你的用户名\.claude\settings.json`），把密钥换成你自己的：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.foo",
    "ANTHROPIC_AUTH_TOKEN": "sk-你的密钥",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

注意地址**不带** `/v1`，Claude Code 会自己加。保存后重开终端运行 `claude`。完整教程：[Claude Code 接第三方 API](https://api.foo/docs/claude-code-api/) · [安装教程](https://api.foo/docs/claude-code/)

### Codex

[`examples/codex/config.toml`](examples/codex/config.toml) 放到 `~/.codex/config.toml`，密钥放环境变量：

```toml
model = "gpt-6.2-sol"
model_provider = "apifoo"

[model_providers.apifoo]
name = "api.foo"
base_url = "https://api.foo/v1"
env_key = "APIFOO_API_KEY"
```

```bash
echo 'export APIFOO_API_KEY="sk-你的密钥"' >> ~/.zshrc && source ~/.zshrc
codex
```

Codex 走 OpenAI Responses 接口，所以只能用支持它的服务和模型。完整教程（桌面版、插件、profile、报错）：[Codex 接第三方 API](https://api.foo/docs/codex-api/)

### Cursor

Settings → Models：在 OpenAI API Key 填 api.foo 的密钥，打开 **Override OpenAI Base URL** 填 `https://api.foo/v1`，再用「Add model」加上模型名（如 `claude-sonnet-5-5`）。自定义 API 需要 Cursor Premium 及以上套餐，Tab 补全仍用 Cursor 自带模型。完整教程：[Cursor 自定义 API](https://api.foo/docs/cursor/)

### Cline

VS Code 插件：设置里 API Provider 选 **OpenAI Compatible**，Base URL 填 `https://api.foo/v1`，填密钥和模型名。命令行版一行配好（[`examples/cline/setup.sh`](examples/cline/setup.sh)）：

```bash
cline auth -p openai-compatible -k "sk-你的密钥" -m gpt-6.2-sol -b https://api.foo/v1
```

完整教程：[Cline 安装与配置](https://api.foo/docs/cline/)

### OpenCode

OpenCode 2 的配置文件 `~/.config/opencode/opencode.jsonc`，GPT 等模型走 OpenAI 兼容、Claude 走 Anthropic 兼容，见 [`examples/opencode/opencode.jsonc`](examples/opencode/opencode.jsonc)。完整教程：[OpenCode 安装与配置](https://api.foo/docs/opencode/)

### Gemini CLI

两个文件：[`~/.gemini/.env`](examples/gemini-cli/.env) 写地址和密钥，[`~/.gemini/settings.json`](examples/gemini-cli/settings.json) 把登录方式设成 API Key（不设会报 `Invalid auth method selected`）：

```bash
GEMINI_API_KEY="sk-你的密钥"
GOOGLE_GEMINI_BASE_URL="https://api.foo"
```

完整教程：[Gemini CLI 安装与使用](https://api.foo/docs/gemini-cli/)

### Python / Node.js

| 文件 | 用法 |
|---|---|
| [`examples/python/openai_chat.py`](examples/python/openai_chat.py) | OpenAI SDK，任何模型 |
| [`examples/python/anthropic_messages.py`](examples/python/anthropic_messages.py) | Anthropic SDK，Claude 模型（支持提示缓存等原生参数） |
| [`examples/python/openai_responses.py`](examples/python/openai_responses.py) | OpenAI Responses 接口 |
| [`examples/python/gemini_native.py`](examples/python/gemini_native.py) | google-genai SDK，Gemini 模型 |
| [`examples/node/openai_chat.mjs`](examples/node/openai_chat.mjs) | Node.js OpenAI SDK |
| [`examples/curl/requests.sh`](examples/curl/requests.sh) | 四种接口的 curl 写法 |

最短的 Python 写法：

```python
from openai import OpenAI

client = OpenAI(api_key="sk-你的密钥", base_url="https://api.foo/v1")
resp = client.chat.completions.create(
    model="claude-sonnet-5-5",
    messages=[{"role": "user", "content": "你好"}],
)
print(resp.choices[0].message.content)
```

## 挑 API 中转站要核对的 8 件事

不管用哪家，充大钱之前先核对这 8 件事。右边一栏是 api.foo 的情况和核对的地方，别家可以照着问。

| 要核对的事 | 为什么重要 | api.foo 的情况 |
|---|---|---|
| 1. 是不是官方 | 第三方服务要自己承担上游波动，不该冒充官方 | 不是官方，独立运营，[关于页](https://api.foo/about)写明 |
| 2. 价格能不能和官方价对上 | 有的站把单价藏在「倍率」里，算不清 | 每个模型单独一页，人民币单价公开，例如 [claude-opus-5-5](https://api.foo/pricing/claude-opus-5-5)；官方价对照见 [国产大模型 API 价格表](https://api.foo/docs/china-llm-api-pricing/)、[Claude 价格](https://api.foo/docs/claude-pricing/) |
| 3. 缓存怎么计费 | 编程工具大部分输入是重复上下文，缓存读取价往往比输入价更影响花费 | Claude 的缓存读取、5 分钟 / 1 小时缓存写入分开标价 |
| 4. 有没有逐条计费明细 | 没有明细就没法核对扣费 | 控制台「使用日志」每次请求记模型、输入 / 输出 / 缓存 token 和扣费 |
| 5. 会不会偷加提示词 | 偷加的提示词会让你多花钱、还影响效果 | 用上面的 `check.sh` 看一句「hi」的输入 token 数 |
| 6. 长任务会不会被掐断 | 经 Cloudflare 的服务非流式请求约 120 秒就断 | 默认线路直连，不受 120 秒限制 |
| 7. 保不保存对话内容 | 代码和资料会经过中转服务器 | [隐私政策](https://api.foo/privacy-policy)：不保存提示词和回答，只记计费和排障信息（视频等排队任务例外） |
| 8. 出了问题找谁、能不能退 | 小站常见突然失联 | 工单、邮箱、QQ 群、Telegram 群；[服务条款](https://api.foo/user-agreement)写明退款规则 |

先充 **¥5** 跑一遍你平时的任务，看使用日志里的模型名、token 数和扣费对不对得上，再决定要不要多充。更多判断方法：[API 中转站怎么选](https://api.foo/docs/api-relay/) · [api.foo 常见问题](https://api.foo/docs/faq/)

## 常见报错

| 报错 | 一般原因 | 怎么办 |
|---|---|---|
| 401 `无效的令牌` | 密钥错了、没带（环境变量是空的）、过期、被禁用，或这把密钥的额度上限用完了 | 到控制台「API 密钥」看状态和剩余额度 |
| 403 `用户额度不足` | 余额不够 | 充值，或调小 `max_tokens` |
| `无可用渠道`、`模型价格未配置` | 模型名和模型广场上的不完全一样，或这把密钥的分组里没有这个模型 | 到模型页复制模型名；换一把建在对的分组里的密钥 |
| 404 `Invalid URL` | 路径写错，常见是地址多写或少写了 `/v1` | 对照上面的「接口地址一览」 |
| 429 | 请求太快，或上游限流 | 降低并发，隔一会儿重试 |
| 5xx | 上游临时出错 | 几十秒后重试；一直出错把报错里的 request id 发给客服 |
| 524 | 用中转线路 `cf.api.foo` 时非流式请求超过约 120 秒 | 换回默认线路 `https://api.foo`，或打开流式 |

每种报错的排查步骤：[报错排查大全](https://api.foo/docs/errors/)

## 价格和付款

- **人民币预付、按量计费**，没有月费；生图按张计费。¥5 起充。
- 支付宝、微信、银行卡（Stripe）、USDT（BSC 网络，¥40 起）。
- 一个账号一份余额，所有模型共用；但**一把密钥属于一个分组**，不同模型可能要用不同分组的密钥，每个模型能在哪些分组用，模型页上写着。
- 价格以 [模型广场](https://api.foo/pricing) 为准，这里不抄具体数字，避免过时。
- 单笔满 ¥300 可开增值税普通发票，见 [常见问题](https://api.foo/docs/faq/)。

## 联系

- 控制台「我的工单」、邮箱 support@api.foo
- QQ 群 639791134、Telegram 群 [t.me/api_foo](https://t.me/api_foo)

发现示例过时或写错了，欢迎提 Issue 或 Pull Request。

## 许可

示例代码和脚本用 [MIT](LICENSE) 许可，可以随意复制、修改、用在你自己的项目里（包括接别家服务）。

---

最后更新：2026-11-24 · 示例实测：curl 8.14、openai-python、anthropic-python、google-genai、openai-node（Node.js 22），用测试密钥确认地址和请求头；各工具配置的实测版本见对应文档页。
