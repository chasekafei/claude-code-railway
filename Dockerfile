FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    tmux \
    wget \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    # ── Playwright Chromium system dependencies (Chrome for Testing) ──
    && apt-get install -y \
      libnss3 libnspr4 libatk-bridge2.0-0 libatk1.0-0 \
      libcups2 libdrm2 libdbus-1-3 libxkbcommon0 \
      libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
      libgbm1 libpango-1.0-0 libcairo2 libasound2 \
      libatspi2.0-0 libx11-xcb1 libxcb1 libxext6 \
      libxshmfence1 libglib2.0-0 libgtk-3-0 \
      fonts-wqy-zenhei xfonts-utils xfonts-scalable \
      xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g cc-connect
RUN npm install -g @playwright/cli

RUN mkdir -p /workspace

# ── Place browser cache on the persistent volume ──
ENV PLAYWRIGHT_BROWSERS_PATH=/workspace/.playwright-browsers

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
