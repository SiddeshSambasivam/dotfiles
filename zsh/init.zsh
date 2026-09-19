# Interactive shell setup, sourced from programs.zsh.initContent.
# See home.nix. Plain zsh: no nix escaping needed here.

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- Version managers ----
# Each of these owns a directory of installed toolchains and
# live project state, so nix installs neither the manager nor
# the toolchains.

# Python. 11 named virtualenvs and several .python-version
# pins depend on this.
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ---- Containers ----
# Docker-API clients (compose, testcontainers, SDKs) need this;
# podman itself does not. TMPDIR comes from the user UUID and
# survives reboots, so the path is safe to hardcode.
export DOCKER_HOST="unix://${TMPDIR%/}/podman/podman-machine-default-api.sock"

# ---- Tools that install outside nix ----
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"

# AI workflow helpers
[ -f "$HOME/.config/ai-workflow/shell.zsh" ] && source "$HOME/.config/ai-workflow/shell.zsh"

# ---- PATH precedence ----
# This has to be the last line that touches PATH.
#
# Two things would otherwise shadow the tools installed above.
# Homebrew's shellenv prepends /opt/homebrew/bin from
# ~/.zprofile, and `pyenv init` prepends its shims directory,
# which includes shims for uv and uvx.
#
# Putting the nix profile in front last means nix wins for
# everything it provides. pyenv keeps python, python3 and pip,
# because nix installs none of those.
export PATH="/etc/profiles/per-user/$USER/bin:$PATH"
