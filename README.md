# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![nix-darwin](https://img.shields.io/badge/nix--darwin-26.05-5277C3?logo=nixos&logoColor=white)
![home-manager](https://img.shields.io/badge/home--manager-26.05-5277C3?logo=nixos&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-casks-FBB040?logo=homebrew&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-0.12-57A143?logo=neovim&logoColor=white)
![WezTerm](https://img.shields.io/badge/WezTerm-4E49EE?logo=wezterm&logoColor=white)

My Mac, declared with nix-darwin, home-manager and Homebrew casks. A work in progress that changes as my preferences do.

I use frontier models for day-to-day development. On personal projects I'd rather write the code myself, since fully agentic development doesn't feel as fulfilling. There, Neovim's inline autocomplete comes from qwen2.5-coder:14b, running locally in Ollama.

```
flake.nix     inputs and the darwinConfiguration
darwin.nix    system prefs, keyboard shortcuts, Homebrew casks, dock
home.nix      shell, CLI tools, language servers and apps
pkgs/         apps that neither nixpkgs nor Homebrew has
zsh/          shell config, read into ~/.zshrc
nvim/         Neovim config and lazy-lock.json, linked to ~/.config/nvim
wezterm.lua   WezTerm config, linked to ~/.config/wezterm
claude/       Claude Code instructions, linked to ~/.claude/CLAUDE.md
nsync.sh      apply the config
```

## Use

```bash
./nsync.sh
```

It locks the flake as you, switches as root, then sets app icons, pulls the Ollama model for nvim's ghost text and adds rust-analyzer through rustup. Run `darwin-rebuild build --flake .` to check a change without applying it, and `sudo darwin-rebuild rollback` to undo one.

## New Mac

1. Install Determinate Nix and Homebrew, and clone this repo to `~/dotfiles`.
2. Run the first switch by name, since `darwin-rebuild` isn't on PATH yet:

   ```bash
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#sids-macbook
   ```

3. Run `./nsync.sh`. The Ollama model is about 9 GB.
4. Open nvim once. lazy.nvim installs the plugins at the commits in `lazy-lock.json`.

## Manual steps

- Grant Accessibility to Rectangle and Raycast, and Input Monitoring to Raycast. Both come from nixpkgs, so a nixpkgs bump changes their path and resets these grants.
- Add Raycast's app hotkeys in Settings, Extensions (Hyper+b Brave, Hyper+c Claude, Hyper+t WezTerm, Hyper+s Slack). Raycast keeps them encrypted, out of reach of `defaults`.
- Create three or four Spaces in Mission Control, for the Cmd-h and Cmd-l Space shortcuts.
- Run `podman machine init && podman machine start`.
- Install App Store apps.
- If C builds fail to link, point `xcode-select` at a toolchain whose linker matches the macOS SDK. nvim's treesitter parsers need it.
- A launch agent removed from `darwin.nix` keeps running. Remove it with `launchctl bootout gui/$(id -u)/<label>` and delete its plist from `~/Library/LaunchAgents`.

pyenv, nvm, rustup, Claude Code and self-updating GUI apps stay out of nix on purpose. The GUI apps are Homebrew casks.
