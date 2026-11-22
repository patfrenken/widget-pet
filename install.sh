#!/usr/bin/env bash
# Installs or updates Widget Pet for the current user (Plasma 6).
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v kpackagetool6 >/dev/null; then
    echo "kpackagetool6 not found – is KDE Plasma 6 installed?" >&2
    exit 1
fi

# Remove the pre-release version with the old ID
kpackagetool6 -t Plasma/Applet -r org.paddy.widgetpet >/dev/null 2>&1 && echo "Removed old pre-release version." || true

if kpackagetool6 -t Plasma/Applet -u package 2>/dev/null; then
    echo "Widget Pet has been updated."
    echo "To load the new version: systemctl --user restart plasma-plasmashell"
else
    kpackagetool6 -t Plasma/Applet -i package
    echo "Widget Pet is installed."
    echo "Right-click the desktop → Add Widgets… → search for \"Widget Pet\" and drag it onto the desktop."
fi
