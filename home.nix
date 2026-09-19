{ pkgs, lib, username, ... }:

{
  home.username = username;

  # Read the home-manager release notes before changing.
  home.stateVersion = "26.05";

  ####################################################################
  # CLI tools.
  #
  # Language toolchains that come with their own version manager are
  # not here. See the version manager section further down.
  ####################################################################
  home.packages = with pkgs; [
    # dev loop
    act
    gh
    git-lfs
    lazygit
    lazydocker
    ripgrep
    tree
    watch
    wget
    mosh
    zellij

    # build toolchain
    ccache
    cmake
    ninja
    nasm

    # infra
    opentofu
    flyctl

    # docs and diagrams
    d2
    graphviz
    pandoc
    hugo
    poppler-utils

    # media
    ffmpeg

    # archives
    p7zip

    # system
    btop
    coreutils

    # Go needs no version manager. Since 1.21 the toolchain downloads
    # whatever a go.mod asks for, so one version covers every project.
    go

    # uv is a single static binary, so nix can install it while uv
    # manages the Python interpreters.
    uv

    neovim
  ];

  ####################################################################
  # Shell
  ####################################################################
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # From nixpkgs rather than a hand-cloned ~/.oh-my-zsh.
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";          # powerlevel10k loads as a plugin below
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      dl = ''watch -n 2 'podman ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.State}}"' '';
      nsync = "$HOME/dotfiles/nsync.sh";
      scc = "bash sync.sh";
      aws = "/usr/local/bin/aws";
    };

    # Runs for non-interactive shells too, so scripts see cargo.
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';

    initContent = lib.mkMerge [
      # Has to come before anything that writes to the console.
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
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
        export DOCKER_HOST="unix://''${TMPDIR%/}/podman/podman-machine-default-api.sock"

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
      ''
    ];
  };

  ####################################################################
  # WezTerm
  #
  # From nixpkgs rather than a cask: the cask is pinned at 20240203
  # and WezTerm has no built-in updater to fight, so the store copy
  # is both newer and safe to manage declaratively.
  #
  # Autocomplete and syntax highlighting are not configured here.
  # A terminal emulator draws glyphs; those are shell features and
  # live in programs.zsh above.
  ####################################################################
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      -- Font. MesloLGS NF is a Nerd Font, which powerlevel10k needs
      -- for its glyphs. The fallbacks cover anything it lacks.
      config.font = wezterm.font_with_fallback { 'MesloLGS NF', 'JetBrains Mono', 'Menlo' }
      config.font_size = 13.0
      config.line_height = 1.05

      -- Colours, carried over from the iTerm profile.
      config.colors = {
        background = '#101216',
        foreground = '#c1c2c3',
        cursor_bg = '#c9d1d9',
        cursor_border = '#c9d1d9',
        cursor_fg = '#101216',
      }

      config.default_cursor_style = 'SteadyBlock'

      -- Window
      config.window_padding = { left = 6, right = 6, top = 6, bottom = 4 }
      config.window_decorations = 'RESIZE'
      config.scrollback_lines = 50000
      config.audible_bell = 'Disabled'
      config.check_for_updates = false

      -- Tabs, shown only when there is more than one.
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = false

      -- macOS fullscreen. Native mode gives the window its own macOS
      -- Space, which hides it from AeroSpace entirely. false keeps
      -- fullscreen as an ordinary window that AeroSpace can still tile.
      config.native_macos_fullscreen_mode = false

      -- Left Option sends Alt/Meta so readline word-motions work.
      -- Right Option still types special characters.
      config.send_composed_key_when_left_alt_is_pressed = false
      config.send_composed_key_when_right_alt_is_pressed = true

      return config
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Siddesh Sambasivam";
      user.email = "siddeshsambasivam.official@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.home-manager.enable = true;
}
