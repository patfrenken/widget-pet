#!/usr/bin/env bash
# Baut widget-pet-<version>.plasmoid aus dem Ordner package/ (Version aus metadata.json).
set -euo pipefail
cd "$(dirname "$0")"
VERSION=$(python3 -c 'import json; print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')
OUT="widget-pet-${VERSION}.plasmoid"
rm -f "$OUT"
(cd package && python3 -m zipfile -c "../$OUT" metadata.json contents)
python3 - "$OUT" <<'PY'
import sys, zipfile, json
z = zipfile.ZipFile(sys.argv[1])
names = z.namelist()
meta = json.loads(z.read("metadata.json"))["KPlugin"]
assert any(n.endswith("contents/ui/main.qml") for n in names), "main.qml fehlt"
print(f"{sys.argv[1]}: {len(names)} Dateien, ID {meta['Id']}, Version {meta['Version']}")
PY
