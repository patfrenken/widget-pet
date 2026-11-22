// Prüft, dass jeder Text im Code eine englische Übersetzung hat:  node tools/check-translations.js
const fs = require("fs"), path = require("path");
const ui = path.join(__dirname, "..", "package", "contents", "ui");
const load = f => { const m = { exports: {} }; new Function("module", fs.readFileSync(path.join(ui, f), "utf8").replace(".pragma library", ""))(m); return m.exports; };
const S = load("strings.js");
const keys = new Set();
const files = fs.readdirSync(ui).filter(f => f.endsWith(".qml")).map(f => path.join(ui, f))
    .concat(fs.readdirSync(path.join(ui, "games")).filter(f => f.endsWith(".qml")).map(f => path.join(ui, "games", f)));
for (const f of files)
    for (const m of fs.readFileSync(f, "utf8").matchAll(/(?:\.|\b)t\(\s*"((?:[^"\\]|\\.)*)"/g)) keys.add(m[1].replace(/\\n/g, "\n"));
const js = fs.readFileSync(path.join(ui, "logic.js"), "utf8");
for (const m of js.matchAll(/\b(?:label|desc|note|go|at|back):\s*"((?:[^"\\]|\\.)*)"/g)) keys.add(m[1]);
for (const m of js.matchAll(/\b(?:fail|done)\("((?:[^"\\]|\\.)*)"/g)) keys.add(m[1]);
for (const block of [/var STAGE_LABEL = \{([\s\S]*?)\};/, /var msgs = \{([\s\S]*?)\};/])
    for (const m of js.match(block)[1].matchAll(/:\s*"([^"]*)"/g)) keys.add(m[1]);
keys.delete("");
const missing = [...keys].filter(k => !Object.prototype.hasOwnProperty.call(S.EN, k));
const unused = Object.keys(S.EN).filter(k => !keys.has(k));
const badPh = [...keys].filter(k => S.EN[k] && (k.match(/%\d/g) || []).sort().join() !== (S.EN[k].match(/%\d/g) || []).sort().join());
console.log(`${keys.size} Texte, ${missing.length} ohne Übersetzung, ${badPh.length} mit falschen Platzhaltern, ${unused.length} unbenutzt`);
missing.forEach(k => console.log("  FEHLT: " + k));
badPh.forEach(k => console.log("  PLATZHALTER: " + k));
unused.forEach(k => console.log("  UNBENUTZT: " + k));
process.exit(missing.length || badPh.length ? 1 : 0);
