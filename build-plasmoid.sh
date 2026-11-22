#!/usr/bin/env bash
# Builds widget-pet-<version>.plasmoid from package/ (version taken from metadata.json).
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
assert any(n.endswith("contents/ui/main.qml") for n in names), "main.qml missing"
print(f"{sys.argv[1]}: {len(names)} files, ID {meta['Id']}, version {meta['Version']}")
PY
