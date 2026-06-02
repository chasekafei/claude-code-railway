# Claude Code on Railway（中文）

> [English](./README.md)

在 [Railway](https://railway.com) 上运行 [Claude Code](https://www.anthropic.com/claude-code)，通过 [cc-connect](https://github.com/chenhg5/cc-connect) 接入 Telegram Bot。支持 DeepSeek 及其他兼容 Anthropic 协议的 API。

## 架构

```
Telegram (手机) ──→ Railway 容器 ──→ cc-connect (常驻进程)
                                      │
                                      └──→ Claude Code CLI
                                            │
                                            ├── /workspace (Volume, 代码 + 配置)
                                            └── Git ↔ GitHub
```

- **cc-connect** 作为常驻进程，通过 Telegram Long Polling 接收消息，拉起 Claude Code CLI 执行任务，流式返回结果
- **Railway Volume** 挂载到 `/workspace`，代码、Claude 配置、cc-connect 配置、SSH 密钥在容器重建后依然保留
- **代码** 直接放在 Volume 上，`git clone` 一次常驻，走 Git 同步 GitHub

## 快速开始

1. Fork 本仓库
2. Railway 后台：New Project → Deploy from GitHub → 选择你 fork 的仓库
3. 为 Service 添加 Volume，挂载路径填 `/workspace`
4. 按 [.env.example](./.env.example) 设置环境变量，**TG_BOT_TOKEN**、**ANTHROPIC_AUTH_TOKEN**、**GH_TOKEN** 必填
5. 部署完成后，在 Telegram 给你的 Bot 发消息即可使用

## 环境变量

### 必填

| 变量 | 说明 |
|---|---|
| `TG_BOT_TOKEN` | Telegram Bot Token，找 [@BotFather](https://t.me/BotFather) 创建 |
| `TG_ALLOW_FROM` | 允许访问的 Telegram 用户 ID（`*`=不限制，建议设为自己的 ID 保证安全） |
| `ANTHROPIC_API_KEY` | API Key，与 `ANTHROPIC_AUTH_TOKEN` 二选一（DeepSeek / Anthropic） |

### API 配置（DeepSeek）

| 变量 | 值 |
|---|---|
| `ANTHROPIC_BASE_URL` | `https://api.deepseek.com/anthropic` |
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` |

使用 Anthropic 原生 API 则无需设置以上变量，只填 `ANTHROPIC_API_KEY`（或 `ANTHROPIC_AUTH_TOKEN`）即可。

### GitHub

| 变量 | 说明 |
|---|---|
| `GH_TOKEN` | GitHub Personal Access Token（需要 `repo` 权限） |
| `GIT_USER_NAME` | 可选，Git commit 用户名 |
| `GIT_USER_EMAIL` | 可选，Git commit 邮箱 |

启动时自动通过 `GH_TOKEN` 配置 Git 认证。也可以 SSH 进容器手动 `ssh-keygen`（密钥存在 Volume 上不会丢失），然后把公钥加到你 GitHub 账号。

### 其他

| 变量 | 默认值 | 说明 |
|---|---|---|
| `CLAUDE_MODE` | `acceptEdits` | `acceptEdits`（编辑需确认）/ `yolo`（全自动） |
| `CC_CONNECT_LANGUAGE` | `zh` | cc-connect 界面语言 |
| `CC_CONNECT_PROJECT` | `workspace` | cc-connect 项目名称 |

## 更新版本

Claude Code 和 cc-connect 通过 npm 安装，未钉版本号。在 Railway 控制台点 **Redeploy** 即可拉取最新版本。

## 许可证

MIT
