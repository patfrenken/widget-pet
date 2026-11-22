#!/usr/bin/env bash
# Removes the widget. Your pet stays in ~/.config/plasma-org.kde.plasma.desktop-appletsrc
# until you remove the widget from your desktop.
set -euo pipefail
kpackagetool6 -t Plasma/Applet -r io.github.patfrenken.widgetpet
echo "Widget Pet has been uninstalled."
