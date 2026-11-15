#!/usr/bin/env bash
# Übernimmt die mitgelieferte Git-Historie (widget-pet.bundle) in diesen Ordner.
set -euo pipefail
cd "$(dirname "$0")"
if [ -d .git ]; then echo "Hier gibt es schon ein Git-Repository."; exit 0; fi
git init -q -b main
git fetch -q widget-pet.bundle main
git reset -q --mixed FETCH_HEAD
git log --oneline
echo "Fertig – die Historie ist da. widget-pet.bundle kannst du jetzt löschen."
