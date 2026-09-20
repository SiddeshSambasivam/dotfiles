{ pkgs, ... }:

let
  username = "siddeshsambasivam";
in
{
  ####################################################################
  # Platform
  ####################################################################
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Every `system.defaults` option requires this. Preferences are
  # per-user, so nix-darwin writes them as this user via
  # `launchctl asuser`.
  system.primaryUser = username;

  # Read `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;

  # home-manager reads home.homeDirectory from here. Without it the
  # value is null and evaluation fails on a type error.
  users.users.${username}.home = "/Users/${username}";

  # Determinate Nix owns the daemon and nix.conf.
  nix.enable = false;

  environment.systemPackages = [
    pkgs.vim
    # Containers. Podman has no daemon; on macOS it drives a Linux VM,
    # created with `podman machine init`.
    pkgs.podman
    # The VM provider. nixpkgs' podman on darwin ships only the podman
    # binary, so `podman machine init` fails without this.
    pkgs.vfkit
    # `podman compose` delegates to an external compose implementation
    # and picks this one up from PATH. The Compose plugin is more
    # compatible with an existing docker-compose.yml than
    # podman-compose is.
    pkgs.docker-compose
  ];

  ####################################################################
  # AeroSpace: tiling window manager.
  #
  # AeroSpace arranges windows inside whichever macOS Space is active.
  # It does not handle navigation between Spaces; the symbolic hotkeys
  # further down do that.
  ####################################################################
  services.aerospace = {
    enable = true;
    settings = {
      config-version = 2;

      # Undo an accidental cmd-alt-h, which would otherwise leave an
      # app hidden with no obvious way back.
      automatically-unhide-macos-hidden-apps = true;

      # AeroSpace's own workspaces stay unused, so every window lives
      # on workspace 1.
      #
      # AeroSpace hides an inactive workspace by moving its windows
      # off-screen. A window left on a second workspace therefore
      # looks like a window that disappeared. With one workspace it
      # never moves anything off-screen.

      gaps = {
        inner.horizontal = 6;
        inner.vertical = 6;
        outer.top = 6;
        outer.bottom = 6;
        outer.left = 6;
        outer.right = 6;
      };

      mode.main.binding = {
        # Nothing is bound on cmd- here. macOS claims cmd-h and cmd-l
        # for Space navigation and intercepts symbolic hotkeys before
        # any application sees them, so a cmd- binding would be dead.

        # ---- Window placement ----
        # AeroSpace tiles rather than snaps, so `move` reorders a
        # window within the split. With two windows side by side,
        # `move left` puts this one on the left half. With a single
        # window there is nothing to swap with and it does nothing.
        ctrl-alt-left = "move left";
        ctrl-alt-right = "move right";
        ctrl-alt-up = "move up";
        ctrl-alt-down = "move down";
        ctrl-alt-shift-enter = "fullscreen";

        # Split orientation. `tiles horizontal` gives left and right
        # halves, `tiles vertical` gives top and bottom.
        ctrl-alt-shift-left = "layout tiles horizontal";
        ctrl-alt-shift-up = "layout tiles vertical";
        ctrl-alt-shift-right = "layout accordion";

        # ---- Focus, and resize the split ----
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";
        alt-f = "fullscreen";

        alt-shift-semicolon = "mode service";

        # ---- App launchers ----
        # These use letters rather than arrows, which leaves
        # ctrl+alt+h/j/k/l free for the terminal multiplexer.
        ctrl-alt-b = "exec-and-forget open -a 'Brave Browser'";
        ctrl-alt-c = "exec-and-forget open -a Cursor";
        ctrl-alt-t = "exec-and-forget open -a WezTerm";
        ctrl-alt-s = "exec-and-forget open -a Slack";
      };

      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];
        r = [ "flatten-workspace-tree" "mode main" ];
        f = [ "layout floating tiling" "mode main" ];
        backspace = [ "close-all-windows-but-current" "mode main" ];
      };

      # Apps that misbehave when tiled.
      on-window-detected = [
        { "if".app-id = "com.apple.systempreferences"; run = "layout floating"; }
        { "if".app-id = "com.apple.finder"; run = "layout floating"; }
        { "if".app-id = "com.bitwarden.desktop"; run = "layout floating"; }
      ];
    };
  };

  ####################################################################
  # Homebrew: GUI applications.
  #
  # An app that updates itself belongs here rather than in nixpkgs.
  # The nix store is read-only, so a self-updating app either fails to
  # update or writes elsewhere and gets reverted on the next
  # darwin-rebuild. Homebrew expects apps to update themselves.
  #
  # This module does not install Homebrew. It drives the one already
  # at /opt/homebrew. See the bootstrap section in README.
  ####################################################################
  homebrew = {
    enable = true;

    onActivation = {
      # "check" runs `brew bundle cleanup` and aborts activation with
      # exit 2 if anything installed is missing from the lists below.
      # It removes nothing, so it reports drift rather than acting on
      # it. "uninstall" removes the undeclared ones instead, and "none"
      # is purely additive.
      cleanup = "check";
      autoUpdate = false;
      upgrade = false;
    };

    # Third-party taps. Each one is required by something below:
    # ngrok/ngrok for the ngrok cask, my-monkeys/tap for
    # opensuperwhisper, peak/tap for s5cmd.
    taps = [
      "ngrok/ngrok"
      "my-monkeys/tap"
      "peak/tap"
    ];

    # Formulae nixpkgs does not cover: local dev services, autotools,
    # and pyenv, which owns its own directory of Python versions.
    brews = [
      "autoconf-archive"
      "automake"
      "cookiecutter"
      "libpq"
      "postgresql@14"
      "postgresql@15"
      "pyenv"
      "rabbitmq"
      "redis"
      "tesseract"
      "unbound"

      # Build dependency of pyenv that brew bundle does not infer.
      "pkgconf"

      # git worktree manager
      "treehouse"

      # S3 CLI, from peak/tap.
      "peak/tap/s5cmd"
    ];

    # Mac App Store apps cannot be listed here. macOS owns them as
    # root:wheel and protects them, so brew can neither adopt nor
    # overwrite one. Declaring them needs homebrew.masApps and the
    # `mas` CLI, or a reinstall from the cask.
    casks = [
      # Daily drivers
      "brave-browser"
      "obsidian"
      "bitwarden"
      "cursor"
      "slack"

      # Terminals. WezTerm comes from nixpkgs (see home.nix), not a
      # cask: the cask is two years stale and WezTerm has no built-in
      # updater that the read-only nix store would conflict with.
      "iterm2"

      # tailscale-app is the menu-bar app with the system
      # NetworkExtension. The `tailscale` formula is only the CLI and
      # does not replace it.
      "tailscale-app"

      # Comms
      "discord"
      "zoom"

      # Utilities
      "calibre"        # ebook library management
      "keyboardcleantool"
      "microsoft-excel"
      "medis"          # redis GUI
      "localsend"
      "wispr-flow"
      "opensuperwhisper"

      # Dev
      "ngrok"
      "podman-desktop"
    ];
  };

  networking.computerName = "sid's macbook";
  networking.hostName = "sids-macbook";
  networking.localHostName = "sids-macbook";

  ####################################################################
  # system.defaults: options nix-darwin types for you.
  #
  # Every key below exists in
  #   $NIXDARWIN/modules/system/defaults/<domain>.nix
  # Typed means nix checks the value and sometimes translates it, so
  # writing `NewWindowTarget = "Recents"` makes nix write "PfAF".
  ####################################################################
  system.defaults = {

    # Written to the global domain (`defaults read -g`).
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      NSTableViewDefaultSizeMode = 2;              # 1 small, 2 medium, 3 large
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      _HIHideMenuBar = false;
      "com.apple.keyboard.fnState" = false;        # false = media keys, true = F-keys
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.5;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.sound.beep.volume" = 1.0;
    };

    dock = {
      autohide = false;
      orientation = "left";
      tilesize = 31;
      magnification = true;
      largesize = 50;
      mineffect = "genie";
      minimize-to-application = true;
      launchanim = true;
      show-process-indicators = true;
      show-recents = false;
      mru-spaces = false;                          # don't reorder Spaces by recent use
      wvous-br-corner = 14;                        # bottom-right hot corner = Quick Note

      persistent-apps = [
        "/Applications/Brave Browser.app"
        # home-manager copies its apps here rather than /Applications.
        "/Users/${username}/Applications/Home Manager Apps/WezTerm.app"
        "/Applications/Cursor.app"
        "/Applications/Obsidian.app"
        "/Applications/Slack.app"
        "/Applications/Claude.app"
        "/Applications/calibre.app"
      ];
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";                # icnv, Nlsv, clmv, Flwv
      NewWindowTarget = "Recents";
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    # Written to both com.apple.AppleMultitouchTrackpad and the
    # Bluetooth trackpad domain, so internal and external agree.
    trackpad = {
      Clicking = false;                             # tap to click off
      Dragging = false;
      DragLock = false;
      TrackpadThreeFingerDrag = false;
      TrackpadRightClick = true;
      TrackpadCornerSecondaryClick = 0;
      ActuateDetents = true;
      ForceSuppressed = false;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRotate = true;
      TrackpadThreeFingerTapGesture = 0;            # off (enum 0 or 2)
      TrackpadTwoFingerDoubleTapGesture = true;     # smart zoom (bool, unlike its neighbours)
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
    };

    menuExtraClock = {
      IsAnalog = false;
      ShowAMPM = true;
      ShowDayOfWeek = true;
      ShowDate = 0;                                 # 0 when space allows, 1 always, 2 never
      FlashDateSeparators = false;
    };

    WindowManager = {
      GloballyEnabled = false;                      # Stage Manager off
      AutoHide = false;
      AppWindowGroupingBehavior = true;             # true = show all windows at once
      EnableStandardClickToShowDesktop = false;
      HideDesktop = true;
      StandardHideDesktopIcons = false;
      StandardHideWidgets = false;
      StageManagerHideWidgets = false;
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
    };

    ####################################################################
    # CustomUserPreferences: untyped fallback.
    #
    # Anything with no typed option goes here. Nix does not check these
    # values, so each one must match the type macOS already stores.
    # Read the type with:  defaults read-type <domain> <key>
    #
    # Each top-level key becomes one `defaults write <domain> <key>`,
    # which replaces that key's whole value rather than merging into it.
    ####################################################################
    CustomUserPreferences = {

      #################################################################
      # Keyboard shortcuts.
      #
      # This domain holds only the overrides, not all of Apple's
      # defaults, so the entries below are the complete delta. The
      # write replaces the entire dictionary, so removing an entry
      # here restores that shortcut to stock rather than leaving it
      # alone.
      #
      # parameters = [ ascii keyCode modifierMask ]
      # modifierMask is a bitfield:
      #   shift 131072 | ctrl 262144 | alt 524288 | cmd 1048576
      #   so shift+cmd = 1179648, ctrl+alt = 786432
      #
      # The id to name mapping for a given macOS version lives in:
      #   plutil -p /System/Library/ExtensionKit/Extensions/\
      #     KeyboardSettings.appex/Contents/Resources/en.lproj/\
      #     DefaultShortcutsTable.xml
      #################################################################
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
        # Space navigation.
        #
        # Nix cannot create the Spaces themselves. They are added by
        # hand in Mission Control, with no API and no defaults key, so
        # a new machine needs them created before these shortcuts have
        # anywhere to go.
        "79" = { enabled = true; value = { parameters = [ 104 4 1048576 ]; type = "standard"; }; };    # cmd+h        previous Space
        "80" = { enabled = true; value = { parameters = [ 104 4 1179648 ]; type = "standard"; }; };    # shift+cmd+h  drag window to previous Space
        "81" = { enabled = true; value = { parameters = [ 108 37 1048576 ]; type = "standard"; }; };   # cmd+l        next Space
        "82" = { enabled = true; value = { parameters = [ 108 37 1179648 ]; type = "standard"; }; };   # shift+cmd+l  drag window to next Space

        # Mission Control. It lists windows a tiling manager has parked
        # off-screen alongside the visible ones, so it shows more than
        # what is on screen.
        "32" = { enabled = true; value = { parameters = [ 106 38 1048576 ]; type = "standard"; }; };   # cmd+j        Mission Control
        "34" = { enabled = true; value = { parameters = [ 106 38 1179648 ]; type = "standard"; }; };   # shift+cmd+j  Mission Control, shift variant
        "98" = { enabled = true; value = { parameters = [ 47 44 1179648 ]; type = "standard"; }; };    # shift+cmd+/  Help menu

        # Spotlight.
        "64" = { enabled = true; value = { parameters = [ 32 49 1048576 ]; type = "standard"; }; };    # cmd+Space     Spotlight
        "65" = { enabled = true; value = { parameters = [ 32 49 1572864 ]; type = "standard"; }; };    # alt+cmd+Space Finder search

        # Off, so the chords stay free.
        "60" = { enabled = false; value = { parameters = [ 32 49 262144 ]; type = "standard"; }; };    # previous input source
        "61" = { enabled = false; value = { parameters = [ 32 49 786432 ]; type = "standard"; }; };    # next input source
        "118" = { enabled = false; value = { parameters = [ 65535 18 262144 ]; type = "standard"; }; }; # switch to Space 1
        "164" = { enabled = false; value = { parameters = [ 65535 65535 0 ]; type = "standard"; }; };

        # Accessibility zoom and contrast, all off.
        "15" = { enabled = false; };
        "16" = { enabled = false; };
        "17" = { enabled = false; };
        "18" = { enabled = false; };
        "19" = { enabled = false; };
        "20" = { enabled = false; };
        "21" = { enabled = false; };
        "22" = { enabled = false; };
        "23" = { enabled = false; };
        "24" = { enabled = false; };
        "25" = { enabled = false; };
        "26" = { enabled = false; };
      };

      # Global-domain keys with no typed nix-darwin option. The domain
      # is spelled "NSGlobalDomain" here, not "-g".
      NSGlobalDomain = {
        AppleMenuBarVisibleInFullscreen = false;
        AppleMiniaturizeOnDoubleClick = false;
        AppleReduceDesktopTinting = false;
        AppleAntiAliasingThreshold = 4;
        "com.apple.sound.beep.flash" = false;
        AppleLocale = "en_US@rg=sgzzzz";
        AppleLanguages = [ "en-US" "en-SG" ];
      };

      "com.apple.screencapture".showsClicks = true;
    };
  };

  ####################################################################
  # nix-darwin writes the preference plists but never tells the window
  # server to re-read them, so hotkey changes wait for a logout without
  # this. Activation runs as root, so it drops back to the user the
  # same way nix-darwin's own `defaults write` lines do.
  #
  # This has to be postActivation. nix-darwin 26.05 removed
  # postUserActivation.
  ####################################################################
  system.activationScripts.postActivation.text = ''
    echo >&2 "reloading keyboard shortcuts..."
    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true

    ####################################################################
    # Custom app icons.
    #
    # Reapplied on every switch because the bundles carrying them get
    # replaced: home-manager's copyApps recreates WezTerm.app, and
    # `brew upgrade` replaces the rest.
    #
    # Uses Rez rather than NSWorkspace, which needs a GUI session that
    # activation does not have. Rez ships with Xcode, so this is
    # skipped when Xcode is absent.
    #
    # Running as root also sidesteps macOS App Management, which
    # blocks unprivileged writes into /Applications.
    ####################################################################
    if /usr/bin/xcrun --find Rez >/dev/null 2>&1; then
      echo >&2 "applying custom app icons..."

      # Every step is non-fatal. The activate script runs under
      # `set -e`, so a single non-zero exit here would abort the whole
      # switch before the generation is updated. Rez and SetFile both
      # emit errors on protected bundles even when the write lands.
      # Every step is non-fatal. The activate script runs under
      # `set -e`, so one non-zero exit here would abort the switch
      # before the generation is updated.
      #
      # Runs as root, which is what gets past macOS App Management:
      # an unprivileged process cannot create files inside a bundle in
      # /Applications, and Rez fails with afpAccessDenied.
      setAppIcon() {
        icon="$1"; app="$2"
        [ -e "$app" ] || return 0
        t=$(mktemp -d) || return 0
        cp "$icon" "$t/i.icns" 2>/dev/null || { rm -rf "$t"; return 0; }
        /usr/bin/sips -i "$t/i.icns" >/dev/null 2>&1 || true
        /usr/bin/xcrun DeRez -only icns "$t/i.icns" > "$t/i.rsrc" 2>/dev/null || true

        if [ -s "$t/i.rsrc" ]; then
          rm -f "$app/Icon"$'\r' 2>/dev/null || true
          /usr/bin/xcrun Rez -append "$t/i.rsrc" -o "$app/Icon"$'\r' 2>/dev/null || true
        fi

        # Only claim a custom icon if the resource actually landed.
        # Setting the bit without it shows a blank icon.
        if [ -s "$app/Icon"$'\r/..namedfork/rsrc' ]; then
          /usr/bin/xcrun SetFile -a C "$app" 2>/dev/null || true
          /usr/bin/xcrun SetFile -a V "$app/Icon"$'\r' 2>/dev/null || true
        else
          /usr/bin/xcrun SetFile -a c "$app" 2>/dev/null || true
        fi
        rm -rf "$t" || true
      }

      setAppIcon ${./icons/brave-browser.icns} "/Applications/Brave Browser.app" || true
      setAppIcon ${./icons/calibre.icns}       "/Applications/calibre.app" || true
      setAppIcon ${./icons/wezterm.icns}       "/Users/${username}/Applications/Home Manager Apps/WezTerm.app" || true
    fi
  '';
}
