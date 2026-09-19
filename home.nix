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
  # The Lua below is the config as written, not a translation. herdr
  # owns workspaces, tabs, panes and scrollback; WezTerm is the
  # renderer and keeps only Cmd chords so the ctrl+alt cluster and the
  # ctrl+q prefix reach herdr untouched.
  ####################################################################
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      -- WezTerm: thin, fast renderer. herdr owns workspaces, tabs, panes, scrollback.
      -- Reload: Cmd+Shift+R. Validate from a shell: wezterm show-keys
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = wezterm.config_builder()

      local home = os.getenv 'HOME'

      -- Launch straight into the persistent herdr session. Cmd+Shift+N gives a plain
      -- zsh window if herdr is ever broken.
      config.default_prog = { home .. '/.local/bin/herdr' }
      config.set_environment_variables = { TERM_PROGRAM_HOST = 'wezterm' }

      -- Window: no WezTerm tab bar (herdr draws its own), thin padding, native fullscreen.
      config.enable_tab_bar = false
      config.window_decorations = 'RESIZE'
      config.window_padding = { left = 6, right = 6, top = 6, bottom = 4 }
      config.native_macos_fullscreen_mode = true
      config.window_close_confirmation = 'NeverPrompt' -- closing a window only detaches herdr
      config.initial_cols = 220
      config.initial_rows = 60

      -- Speed and quiet.
      config.front_end = 'WebGpu'
      config.max_fps = 120
      config.animation_fps = 1
      config.cursor_blink_rate = 0
      config.audible_bell = 'Disabled'
      config.check_for_updates = false
      config.scrollback_lines = 2000 -- herdr keeps the real per-pane scrollback

      -- Look: matches herdr's catppuccin theme. MesloLGS NF is what iTerm/p10k already use.
      config.color_scheme = 'Catppuccin Mocha'
      config.font = wezterm.font_with_fallback { 'MesloLGS NF', 'JetBrains Mono', 'Menlo' }
      config.font_size = 13.0
      config.line_height = 1.05

      -- Terminal features herdr and agents rely on.
      config.enable_kitty_graphics = true -- herdr pane images
      config.send_composed_key_when_left_alt_is_pressed = false -- left Option = Alt/Meta (Option+Enter newline in Claude Code)
      config.send_composed_key_when_right_alt_is_pressed = true -- right Option still types special characters
      config.bypass_mouse_reporting_modifiers = 'SHIFT' -- Shift+drag = WezTerm-level selection (herdr owns the mouse otherwise)

      -- Keys: herdr uses ctrl+alt chords and the ctrl+q prefix; WezTerm keeps only Cmd chords.
      config.disable_default_key_bindings = true
      config.keys = {
        -- clipboard
        { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },
        -- windows (each window is another client on the same herdr session)
        { key = 'n', mods = 'CMD', action = act.SpawnWindow },
        { key = 'n', mods = 'CMD|SHIFT', action = act.SpawnCommandInNewWindow { args = { '/bin/zsh', '-l' } } },
        { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = false } },
        { key = 'q', mods = 'CMD', action = act.QuitApplication },
        { key = 'h', mods = 'CMD', action = act.HideApplication },
        { key = 'm', mods = 'CMD', action = act.Hide },
        { key = 'f', mods = 'CMD|CTRL', action = act.ToggleFullScreen },
        -- text size
        { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
        { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
        { key = '0', mods = 'CMD', action = act.ResetFontSize },
        -- WezTerm utilities
        { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
        { key = 'r', mods = 'CMD|SHIFT', action = act.ReloadConfiguration },
        { key = 'l', mods = 'CMD|SHIFT', action = act.ShowDebugOverlay },
        -- OpenPlan: open the plan hub from anywhere in the terminal
        {
          key = 'o',
          mods = 'CMD|SHIFT',
          action = wezterm.action_callback(function()
            wezterm.run_child_process { '/usr/bin/open', '-a', 'OpenPlan' }
          end),
        },
        -- Claude Code multiline input: Shift+Enter as CSI-u (same sequence /terminal-setup installs for iTerm2)
        { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b[13;2u' },
      }

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
