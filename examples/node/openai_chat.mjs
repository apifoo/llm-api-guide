// npm install openai
import OpenAI from "openai";

const client = new OpenAI({ apiKey: process.env.APIFOO_API_KEY, baseURL: "https://api.foo/v1" });

const resp = await client.chat.completions.create({
  model: "claude-sonnet-5-5",
  messages: [{ role: "user", content: "用一句话介绍你自己" }],
});
console.log(resp.choices[0].message.content);
