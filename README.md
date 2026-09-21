# dotfiles

My Mac as a config file. nix-darwin does the work.

```
flake.nix     inputs and the darwinConfiguration
darwin.nix    system prefs, keyboard shortcuts, Homebrew casks
zshrc         shell config, symlinked to ~/.zshrc
nsync.sh      rebuild and activate
```

## Day to day

Want to check something compiles without touching the machine? Build it:

```bash
darwin-rebuild build --flake ~/dotfiles
```

Happy with it? Apply it:

```bash
./nsync.sh
```

That script does two things in a specific order, and the order matters. It runs
`nix flake lock` as you, then `sudo darwin-rebuild switch`. If you let `sudo`
evaluate the flake instead, nix writes `flake.lock` as root and then every
normal `nix` command in this repo starts failing with `Permission denied`. If
you ever hit that:

```bash
sudo chown "$(id -un):staff" ~/dotfiles/flake.lock
```

Broke something? `sudo darwin-rebuild rollback`. Want to know which commit is
actually running?

```bash
cat /run/current-system/darwin-version.json
```

## Setting up a new Mac

1. Install Determinate Nix.
2. Install Homebrew. This config says which casks it wants, but it won't install
   brew for you.
3. Clone this repo to `~/dotfiles`.
4. Run the first activation the long way:

   ```bash
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#sids-macbook
   ```

   Two reasons it's spelled out like that. `darwin-rebuild` isn't on your `PATH`
   until something has been activated once, and a fresh Mac has a different
   `LocalHostName`, so you have to name the config explicitly.

5. `ln -s ~/dotfiles/zshrc ~/.zshrc`
6. From then on it's just `./nsync.sh`.

Then go do the manual bits below, because the machine isn't really set up
without them.

## Stuff nix can't do for you

**Clean up user launch agents yourself.** The activate script prunes stale
agents from `/Library/LaunchAgents` but never from `~/Library/LaunchAgents`,
so a service you remove from `darwin.nix` leaves its plist behind and keeps
running. Drop it by hand:

```bash
launchctl bootout gui/$(id -u)/<label>
rm -f ~/Library/LaunchAgents/<label>.plist
```

**Give Rectangle accessibility access.** It can't move a single window until
you do. Launch it once and it asks, or do it yourself: System Settings,
Privacy & Security, Accessibility, add `/Applications/Rectangle.app`. Its
shortcuts are Rectangle's own defaults, so change them in its preferences,
not here.

**Finish setting up Raycast.** It replaces Spotlight, and `cmd+space` is
already freed for it in `darwin.nix`. Two things it keeps in an encrypted
SQLite store rather than in a `defaults` domain, so nix can't touch them:

- *Settings, Extensions, Applications*: add a hotkey per app. Currently
  `hyper+b` Brave, `hyper+c` Claude, `hyper+t` WezTerm, `hyper+s` Slack.
  These are the only Raycast settings nix can't reach; everything else in
  `com.raycast.macos`, Hyper Key included, is declared in `darwin.nix`.

Raycast and Rectangle both come from nixpkgs, so they live at store paths
with a version hash in them, and macOS ties Accessibility and Input
Monitoring to an exact path. Bump nixpkgs and those grants reset: Rectangle
stops moving windows and the Hyper Key goes dead until you re-add both.
Same tax AeroSpace charged.

Raycast also rewrites its own preferences when it quits, so a switch made
while it's running gets clobbered. Quit it first, or relaunch it after.

**Make the macOS Spaces.** `cmd+h` and `cmd+l` jump between Spaces, but there's
no API and no `defaults` key for creating them. Open Mission Control, add three
or four desktops by hand, otherwise those shortcuts have nowhere to go.

**Start the podman VM.** No daemon on macOS, it runs a Linux VM instead:

```bash
podman machine init --cpus 4 --memory 8192 --disk-size 100 && podman machine start
```

**Install anything from the App Store.** Brew can't touch those. macOS owns them
as `root:wheel` and protects them, so `brew install --cask` can't adopt or
overwrite one.

## Stuff I keep out of nix on purpose

**pyenv, nvm, rustup.** Each one owns a directory full of toolchains and live
project state. Nix installs tools, it doesn't try to replace these. `uv` is the
exception, since it's a single static binary, so nix installs `uv` and `uv`
handles the Python versions.

**GUI apps that update themselves.** Those go in `homebrew.casks`. The nix store
is read-only, so an app with its own updater either fails to update or writes
somewhere else and gets reverted on the next `darwin-rebuild`. Brew expects apps
to update themselves, so it just tracks the version and stays out of the way.

**Claude Code.** It updates itself into `~/.local/share/claude/versions/`.
Pinning it in nix means you're permanently a few versions behind and fighting
the updater.

## Finding the right option

`system.defaults.<domain>.<key>` are the typed nix-darwin options. Nix checks
the value and sometimes translates it, which is why you write
`NewWindowTarget = "Recents"` and `PfAF` lands on disk. The typed domains are
just the files in this directory:

```bash
ls $(nix flake prefetch --json 'github:nix-darwin/nix-darwin/nix-darwin-26.05' | jq -r .storePath)/modules/system/defaults/
```

If your key isn't in there, it goes in `CustomUserPreferences`, which has no
type checking at all. Check what type macOS already stores or you'll silently
change it:

```bash
defaults read-type com.apple.dock tilesize     # float, not integer
defaults read-type com.apple.dock autohide     # boolean
```

Don't know the key for something you can only toggle in System Settings? Dump
everything, flip the switch, diff:

```bash
defaults read > /tmp/before.txt
# go flip the setting in the UI
defaults read > /tmp/after.txt && diff /tmp/before.txt /tmp/after.txt
```

Takes about a second and tells you both the domain and the key.

## Checking before you switch

`darwin-rebuild build` leaves you a `result` symlink, and the `activate` script
inside it has every single `defaults write` the switch will run, plists and all.
Pull those out, diff them against `defaults export` of the live domain, and
you've proved the config matches the machine before anything changes.

## Keyboard shortcuts

`com.apple.symbolichotkeys` only stores your overrides, not Apple's whole
default set, so the block in `darwin.nix` is the complete diff from stock. The
write replaces the entire dictionary instead of merging into it. That means
deleting an entry doesn't leave that shortcut alone, it puts it back to the
default.

The id to name mapping isn't documented anywhere official and the lists floating
around online contradict each other. The real one for your macOS version is
sitting on your disk:

```bash
plutil -p /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/en.lproj/DefaultShortcutsTable.xml
```

One last gotcha: nix-darwin writes the plists but never tells the window server
to re-read them, so `darwin.nix` calls `activateSettings -u` from
`postActivation`. Without that, shortcut changes sit there doing nothing until
you log out.
