# dotfiles

1. Install Determinate Nix.
2. `git clone https://github.com/SiddeshSambasivam/dotfiles ~/dotfiles && cd ~/dotfiles`
3. First activation only, because `darwin-rebuild` is not on PATH yet:

   ```bash
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#sids-macbook
   ```
4. Everything after that: `./nsync.sh`
