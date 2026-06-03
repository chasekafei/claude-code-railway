#!/bin/bash
set -e

# ── Persist config directories on the Volume ──
mkdir -p /workspace/.claude
mkdir -p /workspace/.cc-connect
mkdir -p /workspace/.ssh

# ── Generate cc-connect config from Railway env vars ──
cat > /workspace/.cc-connect/config.toml << EOF
language = "${CC_CONNECT_LANGUAGE:-zh}"

[[projects]]
  name = "${CC_CONNECT_PROJECT:-workspace}"

  [projects.agent]
    type = "claudecode"
    [projects.agent.options]
      work_dir = "/workspace"
      mode = "${CLAUDE_MODE:-acceptEdits}"

  [[projects.platforms]]
    type = "telegram"
    [projects.platforms.options]
      token = "${TG_BOT_TOKEN}"
      allow_from = "${TG_ALLOW_FROM:-*}"
EOF

# ── Symlink persisted dirs into $HOME ──
rm -rf /root/.claude /root/.cc-connect /root/.ssh
ln -sf /workspace/.claude /root/.claude
ln -sf /workspace/.cc-connect /root/.cc-connect
ln -sf /workspace/.ssh /root/.ssh
chmod 700 /workspace/.ssh

# ── GitHub auth via Personal Access Token ──
if [ -n "$GH_TOKEN" ]; then
    echo "$GH_TOKEN" | gh auth login --with-token 2>/dev/null || true
    gh auth setup-git 2>/dev/null || true
    echo "[entrypoint] GitHub CLI authenticated via GH_TOKEN"
fi

# ── Git identity ──
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# ── Playwright CLI skills (persisted on volume, installed once) ──
PLAYWRIGHT_SKILL_DIR=/workspace/.claude/skills/playwright-cli
if [ ! -d "$PLAYWRIGHT_SKILL_DIR" ]; then
    echo "[entrypoint] Installing playwright-cli skills..."
    CLIENT=claude playwright-cli install --skills
fi

# ── Pre-download Chromium to volume if not already cached ──
PLAYWRIGHT_BROWSER_DIR=/workspace/.playwright-browsers
if [ ! -f "$PLAYWRIGHT_BROWSER_DIR/.browser-cached" ]; then
    echo "[entrypoint] Downloading Chromium for Playwright..."
    npx -y playwright-core install chromium 2>&1 || true
    touch "$PLAYWRIGHT_BROWSER_DIR/.browser-cached"
    echo "[entrypoint] Chromium cached to volume"
fi

echo "[entrypoint] cc-connect config written, starting daemon..."
exec cc-connect
