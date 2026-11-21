#!/usr/bin/env bash
# Installiert oder aktualisiert Widget Pet für den aktuellen Benutzer (Plasma 6).
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v kpackagetool6 >/dev/null; then
    echo "kpackagetool6 nicht gefunden – ist KDE Plasma 6 installiert?" >&2
    exit 1
fi

# Vorabversion mit alter ID entfernen
kpackagetool6 -t Plasma/Applet -r org.paddy.widgetpet >/dev/null 2>&1 && echo "Alte Vorabversion entfernt." || true

if kpackagetool6 -t Plasma/Applet -u package 2>/dev/null; then
    echo "Widget Pet wurde aktualisiert."
    echo "Damit die neue Version geladen wird: systemctl --user restart plasma-plasmashell"
else
    kpackagetool6 -t Plasma/Applet -i package
    echo "Widget Pet ist installiert."
    echo "Rechtsklick auf den Desktop → „Widgets hinzufügen…“ → nach „Widget Pet“ suchen und auf den Desktop ziehen."
fi
