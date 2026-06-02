# Claude Code on Railway

> [中文版](./README.zh-CN.md)

Run [Claude Code](https://www.anthropic.com/claude-code) on [Railway](https://railway.com), accessed via Telegram Bot through [cc-connect](https://github.com/chenhg5/cc-connect). Works with DeepSeek and any Anthropic-compatible API.

## Architecture

```
Telegram (phone) ──→ Railway container ──→ cc-connect (daemon)
                                            │
                                            └──→ Claude Code CLI
                                                  │
                                                  ├── /workspace (Volume, code + config)
                                                  └── Git ↔ GitHub
```

- **cc-connect** runs as a daemon, receives messages via Telegram Long Polling, spawns Claude Code CLI, and streams replies back
- **Railway Volume** mounted at `/workspace` persists code, Claude config, cc-connect config, and SSH keys across redeploys
- **Code** lives on the Volume — `git clone` once, stays forever

## Quick Start

1. Fork this repo
2. In Railway: New Project → Deploy from GitHub → select your fork
3. Add a Volume for the Service, mount path `/workspace`
4. Set environment variables (see [.env.example](./.env.example)) — at minimum **TG_BOT_TOKEN**, **ANTHROPIC_AUTH_TOKEN**, and **GH_TOKEN**
5. Deploy, then send a message to your Bot on Telegram

## Environment Variables

### Required

| Variable | Description |
|---|---|
| `TG_BOT_TOKEN` | Telegram Bot Token from [@BotFather](https://t.me/BotFather) |
| `TG_ALLOW_FROM` | Allowed Telegram user IDs (`*` = anyone; set your own ID for security) |
| `ANTHROPIC_API_KEY` | API Key — use this **or** `ANTHROPIC_AUTH_TOKEN` (DeepSeek or Anthropic) |

### API Configuration (DeepSeek)

| Variable | Value |
|---|---|
| `ANTHROPIC_BASE_URL` | `https://api.deepseek.com/anthropic` |
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` |

If using the native Anthropic API, omit the variables above — only `ANTHROPIC_API_KEY` (or `ANTHROPIC_AUTH_TOKEN`) is needed.

### GitHub

| Variable | Description |
|---|---|
| `GH_TOKEN` | GitHub Personal Access Token (needs `repo` scope) |
| `GIT_USER_NAME` | Optional, Git commit author name |
| `GIT_USER_EMAIL` | Optional, Git commit author email |

Git auth is auto-configured from `GH_TOKEN` on startup. Alternatively, SSH into the container, run `ssh-keygen` (keys persist on the Volume), and add the public key to GitHub.

### Optional

| Variable | Default | Description |
|---|---|---|
| `CLAUDE_MODE` | `acceptEdits` | `acceptEdits` (confirm edits) or `yolo` (auto-edit) |
| `CC_CONNECT_LANGUAGE` | `zh` | cc-connect UI language |
| `CC_CONNECT_PROJECT` | `workspace` | cc-connect project name |

## Updating

Claude Code and cc-connect are installed via npm without pinned versions. Click **Redeploy** in Railway to pull the latest versions.

## License

MIT
