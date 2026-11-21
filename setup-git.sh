#!/usr/bin/env bash
# Übernimmt die mitgelieferte Git-Historie (widget-pet.bundle) in diesen Ordner.
# Funktioniert beim ersten Mal und für spätere Updates. Nicht Teil des Repositories.
set -euo pipefail
cd "$(dirname "$0")"
[ -d .git ] || git init -q -b main
git fetch -q --force widget-pet.bundle main 'refs/tags/*:refs/tags/*'
git reset -q --mixed FETCH_HEAD
git log --oneline --decorate | head -8
git status --short
echo "Fertig – die Historie ist auf dem neuesten Stand."
