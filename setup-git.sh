#!/usr/bin/env bash
# Übernimmt die mitgelieferte Git-Historie (widget-pet.bundle) in diesen Ordner.
# Funktioniert beim ersten Mal und für spätere Updates.
set -euo pipefail
cd "$(dirname "$0")"
[ -d .git ] || git init -q -b main
git fetch -q widget-pet.bundle main
git reset -q --mixed FETCH_HEAD
git log --oneline | head -5
git status --short
echo "Fertig – die Historie ist auf dem neuesten Stand."
