{ config, pkgs, lib, username, ... }:

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
    awscli2

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

    # nvim-treesitter compiles its parsers with this.
    tree-sitter

    # Language servers, for nvim's completion and diagnostics.
    # nvim/lua/plugins/lsp.lua enables each one only when its binary is
    # here. rust-analyzer comes from rustup instead, with the toolchain.
    bash-language-server
    gopls
    lua-language-server
    nil
    pyright
    typescript-language-server

    # Window manager. Its shortcuts and gap size are declared in
    # darwin.nix. Carries the same store-path grant reset as Raycast
    # below, for Accessibility.
    rectangle

    # Menu-bar switch that stops the Mac from sleeping. Neither
    # nixpkgs nor Homebrew has it, so ./pkgs/caffeinate.nix unpacks
    # the release zip. LSUIElement, so it never shows in the Dock.
    (callPackage ./pkgs/caffeinate.nix { })

    # Launcher, replacing Spotlight. Lands in
    # ~/Applications/Home Manager Apps/Raycast.app.
    #
    # Unfree, so darwin.nix allows it by name.
    #
    # The catch, and it is a real one: the bundle is a symlink into a
    # version-hashed store path, and macOS ties Accessibility and
    # Input Monitoring to an exact path. Every nixpkgs bump resets
    # both grants, and the Hyper Key stops working until they are
    # granted again.
    raycast
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

  # Out of the store, like nvim below, so an edit applies on save:
  # WezTerm reloads its config when the file changes.
  xdg.configFile."wezterm/wezterm.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm.lua";
    force = true;
  };

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

  # Linked out of the store, same as CLAUDE.md below, so editing a file
  # under ./nvim takes effect on the next nvim launch with no switch.
  # init.lua and lua/ are linked separately, leaving ~/.config/nvim a
  # real directory for anything else a plugin writes there.
  #
  # force replaces whatever already sits at the target, including a
  # hand-made link, which a plain collision would abort the switch on.
  xdg.configFile."nvim/init.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim/init.lua";
    force = true;
  };
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim/lua";
    force = true;
  };

  ####################################################################
  # Claude Code
  #
  # Global instructions for every Claude Code session. Linked out of
  # the store rather than copied into it: a store copy is read-only,
  # and Claude Code writes to this file when asked to remember
  # something. The out-of-store link points at the working tree, so
  # those edits land in this repo as a diff to commit.
  ####################################################################
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/claude/CLAUDE.md";

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
