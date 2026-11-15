#!/usr/bin/env bash
# Entfernt das Widget. Der Spielstand bleibt in ~/.config/plasma-org.kde.plasma.desktop-appletsrc,
# solange das Widget nicht vom Desktop entfernt wurde.
set -euo pipefail
kpackagetool6 -t Plasma/Applet -r org.paddy.widgetpet
echo "Widget Pet wurde deinstalliert."
