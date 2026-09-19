{ pkgs, ... }:

let
  username = "siddeshsambasivam";
in
{
  ####################################################################
  # Platform
  ####################################################################
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required by every `system.defaults` option: they are written as this
  # user via `launchctl asuser`, because preferences are per-user.
  system.primaryUser = username;

  # Read `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;

  # Determinate Nix owns the daemon and nix.conf.
  nix.enable = false;

  environment.systemPackages = [
    pkgs.vim

    # Containers. Podman has no daemon; on macOS it drives a Linux VM.
    pkgs.podman
    # The VM provider. nixpkgs' podman on darwin ships only the podman
    # binary, so `podman machine init` fails without this.
    pkgs.vfkit
    # `podman compose` is a shim that delegates to an external compose
    # implementation. The real Compose plugin is far more compatible
    # with existing docker-compose.yml than podman-compose is.
    pkgs.docker-compose
  ];

  ####################################################################
  # Homebrew: GUI applications.
  #
  # The rule: if an app updates itself, it belongs here rather than in
  # nixpkgs. The nix store is read-only, so a self-updating app either
  # fails to update or gets reverted on the next darwin-rebuild.
  #
  # This module does NOT install Homebrew, it only drives the one
  # already at /opt/homebrew. See the bootstrap section in README.
  ####################################################################
  homebrew = {
    enable = true;

    onActivation = {
      # "none" is additive: brew installs what's declared and ignores
      # everything else.
      #
      # Not "check": that runs `brew bundle cleanup`, which counts the
      # 200+ undeclared formulae and aborts activation with exit 2.
      # Move to "check", then "uninstall", once the prune is done and
      # this file lists everything brew should own.
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };

    # ngrok's cask lives in its own tap rather than homebrew/cask.
    taps = [ "ngrok/ngrok" ];

    casks = [
      # Daily drivers
      "brave-browser"
      "obsidian"
      "bitwarden"
      "cursor"

      # Migrated off the Mac App Store. An App Store install is owned
      # by root:wheel and protected, so brew can neither adopt nor
      # overwrite it; the copy had to be deleted first. Xcode, Keynote,
      # Numbers, Pages and GarageBand are still App Store apps and
      # cannot be declared here for the same reason.
      "slack"

      # Terminal. iterm2 stays declared until ghostty has replaced it
      # in practice; drop it then.
      "ghostty"
      "iterm2"

      # Networking. tailscale-app is the menu-bar app with the system
      # NetworkExtension; the `tailscale` formula is only the CLI and
      # is not a substitute.
      "tailscale-app"

      # Utilities
      "calibre"        # kindle library management
      "medis"          # redis GUI
      "localsend"
      "wispr-flow"
      "opensuperwhisper"

      # Dev
      "ngrok"
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
  # you write `NewWindowTarget = "Recents"` and nix writes "PfAF".
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
        "/Applications/Cursor.app"
        "/Applications/Obsidian.app"
        "/Applications/Slack.app"
        "/Applications/Claude.app"
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
    # CustomUserPreferences: the escape hatch.
    #
    # Anything with no typed option goes here. There is no type
    # checking, so the value type must match what macOS already
    # stores. Check with:  defaults read-type <domain> <key>
    #
    # Each top-level key becomes one `defaults write <domain> <key>`,
    # which REPLACES that key's whole value. It does not merge.
    ####################################################################
    CustomUserPreferences = {

      #################################################################
      # Keyboard shortcuts.
      #
      # This domain stores only your overrides, not all of Apple's
      # defaults, so these 24 entries are the complete delta. Because
      # the write replaces the entire dictionary, dropping an entry
      # here silently restores that shortcut to stock.
      #
      # parameters = [ ascii keyCode modifierMask ]
      # modifierMask is a bitfield:
      #   shift 131072 | ctrl 262144 | alt 524288 | cmd 1048576
      #   so shift+cmd = 1179648, ctrl+alt = 786432
      #
      # id -> name for THIS macOS version comes from:
      #   plutil -p /System/Library/ExtensionKit/Extensions/\
      #     KeyboardSettings.appex/Contents/Resources/en.lproj/\
      #     DefaultShortcutsTable.xml
      #################################################################
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
        # Vim-style Spaces navigation. Overrides cmd+h "Hide", which is
        # the trade you already made.
        "79" = { enabled = true; value = { parameters = [ 104 4 1048576 ]; type = "standard"; }; };    # cmd+h        previous Space
        "80" = { enabled = true; value = { parameters = [ 104 4 1179648 ]; type = "standard"; }; };    # shift+cmd+h  drag window to previous Space
        "81" = { enabled = true; value = { parameters = [ 108 37 1048576 ]; type = "standard"; }; };   # cmd+l        next Space
        "82" = { enabled = true; value = { parameters = [ 108 37 1179648 ]; type = "standard"; }; };   # shift+cmd+l  drag window to next Space

        "32" = { enabled = true; value = { parameters = [ 106 38 1048576 ]; type = "standard"; }; };   # cmd+j        Mission Control
        "34" = { enabled = true; value = { parameters = [ 106 38 1179648 ]; type = "standard"; }; };   # shift+cmd+j  Mission Control, shift variant
        "98" = { enabled = true; value = { parameters = [ 47 44 1179648 ]; type = "standard"; }; };    # shift+cmd+/  Help menu

        # Off so the chords are free. 64 is cmd+Space, which Raycast holds.
        "64" = { enabled = false; value = { parameters = [ 32 49 1048576 ]; type = "standard"; }; };   # Spotlight search
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

      # Global-domain keys with no typed nix-darwin option.
      # Note the domain is spelled "NSGlobalDomain" here, not "-g".
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

      #################################################################
      # Third-party app shortcuts.
      # These blocks go away when AeroSpace replaces Rectangle and
      # Spotlight replaces Raycast.
      #################################################################
      "com.knollsoft.Rectangle" = {
        launchOnLogin = true;
        allowAnyShortcut = true;
        alternateDefaultShortcuts = true;
        moveCursorAcrossDisplays = 1;                # integer, not bool
        subsequentExecutionMode = 1;
        gapSize = 5.0;                               # float, not int
        hapticFeedbackOnSnap = 2;
        footprintAnimationDurationMultiplier = 0.0;  # float
        hideMenubarIcon = false;
        SUEnableAutomaticChecks = false;
        almostMaximize = { keyCode = 36; modifierFlags = 917504; };  # ctrl+alt+shift+Return
        toggleTodo = { keyCode = 11; modifierFlags = 786432; };      # ctrl+alt+b
        reflowTodo = { keyCode = 45; modifierFlags = 786432; };      # ctrl+alt+n
      };

      "com.raycast.macos" = {
        raycastGlobalHotkey = "Command-49";          # cmd+Space, freed by disabling hotkey 64
        raycastShouldFollowSystemAppearance = true;
      };
    };
  };

  ####################################################################
  # nix-darwin writes the plists but never tells the window server to
  # re-read them, so hotkey changes would wait for a logout. Activation
  # runs as root, so drop back to the user the same way nix-darwin's own
  # `defaults write` lines do.
  #
  # In 26.05 `postUserActivation` was removed; this must be postActivation.
  ####################################################################
  system.activationScripts.postActivation.text = ''
    echo >&2 "reloading keyboard shortcuts..."
    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
  '';
}
