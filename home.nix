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

      # Everything else lives in ./zsh/init.zsh as plain zsh, so it
      # gets editor support and needs no nix string escaping.
      (builtins.readFile ./zsh/init.zsh)
    ];
  };

  ####################################################################
  # WezTerm
  #
  # From nixpkgs rather than a cask: the cask is pinned at 20240203
  # and WezTerm has no built-in updater to fight, so the store copy
  # is both newer and safe to manage declaratively.
  #
  # The module installs the package but writes no config, because
  # `settings` and `extraConfig` are both empty. That leaves
  # ./wezterm.lua free to be linked verbatim below, with no generated
  # preamble wrapped around it.
  #
  # Autocomplete and syntax highlighting are not configured here.
  # A terminal emulator draws glyphs; those are shell features and
  # live in programs.zsh above.
  ####################################################################
  programs.wezterm.enable = true;

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;

  ####################################################################
  # Neovim
  #
  # Same arrangement as WezTerm: the module installs the package and
  # writes no config, because `initLua` is empty. That leaves
  # ./nvim/init.lua free to be linked verbatim.
  #
  # defaultEditor sets EDITOR, which was previously nano.
  ####################################################################
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;

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
