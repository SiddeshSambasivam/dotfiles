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
      local act = wezterm.action
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

      -- Window. TITLE keeps the macOS title bar and traffic lights;
      -- RESIZE alone removes them.
      config.window_padding = { left = 6, right = 6, top = 6, bottom = 4 }
      config.window_decorations = 'TITLE | RESIZE'
      config.scrollback_lines = 50000
      config.audible_bell = 'Disabled'
      config.check_for_updates = false

      -- Tab bar always visible, so tabs and panes are discoverable
      -- rather than appearing only once a second tab exists.
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = false
      config.tab_bar_at_bottom = false
      config.show_new_tab_button_in_tab_bar = true

      -- The native-looking tab bar. false gives the retro one drawn
      -- in terminal cells, which looks out of place under a real
      -- macOS title bar.
      config.use_fancy_tab_bar = true
      config.tab_max_width = 32
      config.window_frame = {
        font = wezterm.font { family = 'MesloLGS NF', weight = 'Regular' },
        font_size = 12.0,
        active_titlebar_bg = '#101216',
        inactive_titlebar_bg = '#101216',
      }
      config.colors.tab_bar = {
        background = '#101216',
        active_tab = { bg_color = '#1c1f26', fg_color = '#c9d1d9' },
        inactive_tab = { bg_color = '#101216', fg_color = '#6b7280' },
        inactive_tab_hover = { bg_color = '#1c1f26', fg_color = '#c1c2c3' },
        new_tab = { bg_color = '#101216', fg_color = '#6b7280' },
        new_tab_hover = { bg_color = '#1c1f26', fg_color = '#c1c2c3' },
      }

      -- Native macOS fullscreen, on the standard cmd-ctrl-f chord.
      --
      -- The trade: a natively fullscreen window gets its own macOS
      -- Space and is invisible to AeroSpace until you leave
      -- fullscreen. AeroSpace's own `alt-f` fills the screen without
      -- that, if a window needs to stay tiled.
      config.native_macos_fullscreen_mode = true

      -- Left Option sends Alt/Meta so readline word-motions work.
      -- Right Option still types special characters.
      config.send_composed_key_when_left_alt_is_pressed = false
      config.send_composed_key_when_right_alt_is_pressed = true

      -- Panes. WezTerm's stock split bindings are ctrl+alt+shift+quote
      -- and ctrl+alt+shift+5, which nobody discovers. These follow the
      -- iTerm convention instead.
      --
      -- cmd-h and cmd-l are deliberately unused: macOS owns those for
      -- Space navigation and would intercept them first.
      config.keys = {
        { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = false } },

        { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
        { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },
        { key = 'LeftArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Left' },
        { key = 'RightArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Right' },
        { key = 'UpArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Up' },
        { key = 'DownArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Down' },

        { key = 'z', mods = 'CMD|SHIFT', action = act.TogglePaneZoomState },

        -- Rename the active tab. WezTerm ships no binding for this.
        -- Submitting an empty line clears the override and hands the
        -- title back to automatic naming.
        {
          key = 'e',
          mods = 'CMD|SHIFT',
          action = act.PromptInputLine {
            description = 'New tab title',
            action = wezterm.action_callback(function(window, _, line)
              if line ~= nil then
                window:active_tab():set_title(line)
              end
            end),
          },
        },

        -- Fullscreen on the standard macOS chord. WezTerm's default
        -- is alt+Enter, which is also how some TUIs take a newline,
        -- so that one is handed back to the running program.
        { key = 'f', mods = 'CMD|CTRL', action = act.ToggleFullScreen },
        { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
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
