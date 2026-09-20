#!/usr/bin/env bash
# Apply the custom icons in ../icons to their apps.
#
# Run with sudo. macOS App Management stops an unprivileged process
# creating files inside a bundle in /Applications, which is why Rez
# fails with afpAccessDenied when this is run as your own user.
#
#   sudo ./scripts/set-app-icons.sh
#
# Re-run after `brew upgrade` replaces an app, or after ./nsync.sh
# recreates WezTerm.app.
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

set_icon "$REPO/icons/brave-browser.icns" "/Applications/Brave Browser.app"
set_icon "$REPO/icons/calibre.icns"       "/Applications/calibre.app"
set_icon "$REPO/icons/wezterm.icns"       "${SUDO_USER:+/Users/$SUDO_USER}/Applications/Home Manager Apps/WezTerm.app"

/usr/bin/killall Dock 2>/dev/null
echo "Dock restarted."
