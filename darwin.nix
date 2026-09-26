{ pkgs, lib, ... }:

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

  # Raycast ships under a proprietary licence. Allowing it by name
  # rather than flipping allowUnfree keeps every other package honest.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "raycast" ];

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
      # Daily drivers.
      #
      # brave-browser and calibre install into ~/Applications rather
      # than /Applications. macOS App Management protects /Applications
      # and blocks writing a custom icon into a bundle there, even as
      # root. ~/Applications is unprotected, so scripts/set-app-icons.sh
      # can set their icons on every switch.
      { name = "brave-browser"; args = { appdir = "~/Applications"; }; }
      # Comet is Perplexity's browser. Self-updating, so a cask.
      "comet"
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
      { name = "calibre"; args = { appdir = "~/Applications"; }; }  # ebook library
      "keyboardcleantool"
      "microsoft-excel"
      "medis"          # redis GUI
      "localsend"
      "wispr-flow"

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
        "/Users/${username}/Applications/Brave Browser.app"
        # home-manager copies its apps here rather than /Applications.
        "/Users/${username}/Applications/Home Manager Apps/WezTerm.app"
        "/Applications/Cursor.app"
        "/Applications/Obsidian.app"
        "/Applications/Slack.app"
        "/Applications/Claude.app"
        "/Users/${username}/Applications/calibre.app"
        "/Applications/Comet.app"
        "/Applications/Wispr Flow.app"
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

        # Spotlight. 64 is off because Raycast takes cmd+Space, and
        # macOS intercepts a symbolic hotkey before any app sees it.
        # 65 opens a Finder search window rather than Spotlight, so it
        # does not collide and stays on.
        "64" = { enabled = false; value = { parameters = [ 32 49 1048576 ]; type = "standard"; }; };   # cmd+Space     Spotlight
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

      # Raycast. The domain holds 61 keys, but only these are
      # settings. The rest is window-position cache, analytics
      # identity, AI model blobs, migration flags and install
      # history, none of which should follow you to a second machine.
      #
      # Not here because it cannot be: the per-application hotkeys,
      # hyper+b for Brave and friends. Those live in
      # raycast-enc.sqlite, which is encrypted. See README.
      #
      # Raycast rewrites this file from memory when it quits, so a
      # switch made while it is running gets clobbered. Quit it first,
      # or relaunch after.
      "com.raycast.macos" = {
        # Root search. "Command-49" is cmd+Space: 49 is the Space key
        # code, the same one the symbolic hotkeys use.
        raycastGlobalHotkey = "Command-49";

        # Caps Lock becomes Hyper. 57 is the Caps Lock key code.
        # includeShiftKey is off, so Hyper is ctrl+alt+cmd rather than
        # ctrl+alt+shift+cmd. Raycast needs Input Monitoring for this.
        raycast_hyperKey_state = {
          enabled = true;
          includeShiftKey = false;
          keyCode = 57;
        };
        useHyperKeyIcon = true;

        # Appearance and behaviour.
        raycastPreferredWindowMode = "compact";
        raycastShouldFollowSystemAppearance = true;
        raycastUI_preferredTextSize = "medium";
        navigationCommandStyleIdentifierKey = "vim";
        fileSearch_fileSearchScope = "kMDQueryScopeComputer";
        screenshots_dataSourceEnabled = true;
        faviconProvider = "apple";
        "NSStatusItem VisibleCC raycastIcon" = false;

        # Suppress the first-run flow. Drop this group if you would
        # rather walk through onboarding on a new machine.
        onboardingCompleted = true;
        store_termsAccepted = true;
        raycastAiHasSeenQuickAI = true;
        showGettingStartedLink = false;
      };

      # Rectangle. Like the symbolic hotkeys, this domain stores only
      # what differs from stock, so the list below is the whole delta.
      #
      # A shortcut is { keyCode, modifierFlags }. modifierFlags is the
      # same bitfield AppKit uses:
      #   shift 131072 | ctrl 262144 | alt 524288 | cmd 1048576
      # Key codes are the usual macOS virtual ones: 36 Return, 45 N,
      # 11 B.
      "com.knollsoft.Rectangle" = {
        # Sparkle cannot update an app in the read-only nix store, so
        # leave its check off. Version bumps come from nixpkgs.
        SUEnableAutomaticChecks = false;

        # Accept chords macOS would otherwise reject as reserved.
        allowAnyShortcut = true;

        # The alternate default set: ctrl+alt for halves and corners
        # rather than ctrl+alt+cmd.
        alternateDefaultShortcuts = true;

        gapSize = 5.0;
        footprintAnimationDurationMultiplier = 0.0;
        hapticFeedbackOnSnap = 2;
        hideMenubarIcon = false;
        launchOnLogin = true;
        moveCursorAcrossDisplays = 1;
        subsequentExecutionMode = 1;

        # Custom chords.
        almostMaximize = { keyCode = 36; modifierFlags = 917504; };   # ctrl+alt+shift+Return
        reflowTodo = { keyCode = 45; modifierFlags = 786432; };       # ctrl+alt+N
        toggleTodo = { keyCode = 11; modifierFlags = 786432; };       # ctrl+alt+B
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

  '';
}
