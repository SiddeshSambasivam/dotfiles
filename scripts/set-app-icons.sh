#!/usr/bin/env bash
# Apply the custom icons in ../icons to their apps.
#
# Only covers apps under ~/Applications. Anything in /Applications is
# protected by macOS App Management, which blocks creating files
# inside the bundle even as root: Rez fails with afpAccessDenied and
# SetFile with -5000. Finder is the only thing that can set those,
# because it holds the App Management entitlement. Do it by hand:
# open the .icns in Preview, cmd-A cmd-C, then cmd-I on the app,
# click the icon top-left, cmd-V.
#
# Called from nsync.sh after the switch, because home-manager's
# copyApps recreates WezTerm.app partway through activation and would
# otherwise discard the icon.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CR=$'\r'

if ! /usr/bin/xcrun --find Rez >/dev/null 2>&1; then
  echo "Rez not found; Xcode is required." >&2
  exit 1
fi

set_icon() {
  local icon="$1" app="$2" name
  name="$(basename "$app")"

  if [ ! -e "$app" ]; then
    printf '  %-34s skipped, not installed\n' "$name"
    return 0
  fi
  if [ ! -f "$icon" ]; then
    printf '  %-34s skipped, no icon file\n' "$name"
    return 0
  fi

  # A running app's bundle is locked, and so is anything in
  # /Applications. Check before touching the existing icon, because
  # deleting one we then cannot replace leaves a blank icon.
  if ! touch "$app/.icon-probe" 2>/dev/null; then
    printf '  %-34s skipped, bundle not writable (app running?)\n' "$name"
    return 0
  fi
  rm -f "$app/.icon-probe"

  local t
  t="$(mktemp -d)" || return 0

  cp "$icon" "$t/i.icns"
  /usr/bin/sips -i "$t/i.icns" >/dev/null 2>&1
  /usr/bin/xcrun DeRez -only icns "$t/i.icns" > "$t/i.rsrc" 2>/dev/null

  if [ -s "$t/i.rsrc" ]; then
    rm -f "$app/Icon$CR" 2>/dev/null
    /usr/bin/xcrun Rez -append "$t/i.rsrc" -o "$app/Icon$CR" 2>/dev/null
  fi

  # Only claim a custom icon once the resource fork is actually there.
  # Setting the bit without it shows a blank icon.
  local fork="$app/Icon$CR/..namedfork/rsrc" size=0
  [ -e "$fork" ] && size="$(/usr/bin/stat -f%z "$fork" 2>/dev/null || echo 0)"

  if [ "$size" -gt 0 ]; then
    /usr/bin/xcrun SetFile -a C "$app" 2>/dev/null
    /usr/bin/xcrun SetFile -a V "$app/Icon$CR" 2>/dev/null
    printf '  %-34s applied (%s bytes)\n' "$name" "$size"
  else
    /usr/bin/xcrun SetFile -a c "$app" 2>/dev/null
    rm -f "$app/Icon$CR" 2>/dev/null
    printf '  %-34s FAILED, reverted to stock\n' "$name"
  fi

  rm -rf "$t"
}

HOMEAPPS="${SUDO_USER:+/Users/$SUDO_USER}/Applications"

set_icon "$REPO/icons/wezterm.icns"       "$HOMEAPPS/Home Manager Apps/WezTerm.app"
set_icon "$REPO/icons/brave-browser.icns" "$HOMEAPPS/Brave Browser.app"
set_icon "$REPO/icons/calibre.icns"       "$HOMEAPPS/calibre.app"

/usr/bin/killall Dock 2>/dev/null
echo "Dock restarted."
