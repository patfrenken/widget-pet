import QtQuick
import "logic.js" as Logic

// Zustand des Pets: laden, speichern, ticken, Aktionen ausführen.
Item {
    id: model

    required property var config            // Plasmoid.configuration
    property var s: null
    property var ancestry: []
    property int rev: 0

    signal notify(string text, string kind)  // kind: info | evolve | warn | death
    signal fed(string foodId)
    signal hopRequested()

    readonly property int timeScale: Math.max(1, config.timeScale || 1)
    readonly property bool ready: s !== null
    readonly property bool asleep: { rev; return ready && Logic.isAsleep(s, config.sleepStart, config.sleepEnd); }
    readonly property bool dead: { rev; return ready && s.dead; }
    readonly property bool isEgg: { rev; return !ready || s.stage === "egg"; }
    readonly property string stage: { rev; return ready ? Logic.displayStage(s) : "egg"; }
    readonly property string stageLabel: { rev; return ready ? Logic.stageLabel(s) : ""; }
    readonly property string species: { rev; return isEgg ? "egg" : Logic.currentSpecies(s); }
    readonly property string speciesLabel: species !== "egg" && Logic.SPECIES[species] ? Logic.SPECIES[species].label : qsTr("Ei")
    readonly property string mood: { rev; return ready ? Logic.mood(s, asleep) : "egg"; }
    readonly property string need: { rev; return ready ? Logic.attention(s, asleep) : ""; }
    readonly property string name: { rev; return ready ? s.name : ""; }
    readonly property real hue: { rev; return ready ? s.hue : 200; }
    readonly property string eggPattern: { rev; return ready ? s.eggPattern : "dots"; }
    readonly property real hatch: { rev; return ready ? Logic.hatchProgress(s) : 0; }
    readonly property real hunger: { rev; return ready ? s.hunger : 0; }
    readonly property real fun: { rev; return ready ? s.fun : 0; }
    readonly property real health: { rev; return ready ? s.health : 0; }
    readonly property int coins: { rev; return ready ? s.coins : 0; }
    readonly property int poop: { rev; return ready ? s.poop : 0; }
    readonly property bool sick: { rev; return ready && s.sick; }
    readonly property bool senior: { rev; return ready && Logic.isSenior(s); }
    readonly property int ageDays: { rev; return ready ? Logic.ageDays(s) : 0; }
    readonly property int generation: { rev; return ready ? s.gen : 1; }

    function opts() {
        return { timeScale: timeScale, sleepStart: config.sleepStart, sleepEnd: config.sleepEnd };
    }

    function load() {
        var now = Date.now();
        var st = null;
        try { st = config.petState ? JSON.parse(config.petState) : null; } catch (e) { st = null; }
        s = Logic.normalize(st, now);
        try { ancestry = config.ancestry ? JSON.parse(config.ancestry) : []; } catch (e2) { ancestry = []; }
        tick();
    }

    function save() {
        if (!ready) return;
        config.petState = JSON.stringify(s);
    }

    function saveAncestry() {
        config.ancestry = JSON.stringify(ancestry);
    }

    function tick() {
        if (!ready) return;
        var events = Logic.tick(s, Date.now(), opts());
        for (var i = 0; i < events.length; i++) handleEvent(events[i]);
        rev++;
        save();
    }

    function handleEvent(ev) {
        var label = ev.species && Logic.SPECIES[ev.species] ? Logic.SPECIES[ev.species].label : "";
        if (ev.type === "hatch") notify(qsTr("Geschlüpft! Hallo, %1!").arg(s.name), "evolve");
        else if (ev.type === "evolve") notify(qsTr("%1 ist jetzt ein %2!").arg(s.name).arg(label), "evolve");
        else if (ev.type === "sick") notify(qsTr("%1 fühlt sich krank.").arg(s.name), "warn");
        else if (ev.type === "death") notify(ev.cause === "age" ? qsTr("%1 ist zu den Sternen gereist.").arg(s.name)
                                                               : qsTr("%1 hat es leider nicht geschafft …").arg(s.name), "death");
    }

    function finish(res) {
        rev++;
        save();
        if (res.msg) notify(res.msg, res.ok ? "info" : "warn");
        return res;
    }

    function feed(foodId) {
        tick();
        var res = Logic.feed(s, foodId, asleep);
        if (res.ok) fed(foodId);
        return finish(res);
    }
    function clean() { tick(); return finish(Logic.clean(s, asleep)); }
    function medicine() { tick(); return finish(Logic.medicine(s)); }
    function pat() {
        var res = Logic.pat(s, asleep);
        if (res.ok) hopRequested();
        return finish(res);
    }
    function gameUnlocked(gameId) { rev; return ready && Logic.gameUnlocked(s, gameId); }
    function bestScore(gameId) { rev; return ready ? (s.best[gameId] || 0) : 0; }

    function gameResult(gameId, score, coins, funBase) {
        tick();
        var r = Logic.gameResult(s, gameId, score, coins, funBase, Date.now());
        rev++;
        save();
        return r;
    }

    function retire(cause) {
        if (s.stage !== "egg") {
            if (!s.dead) { s.deathCause = cause; s.diedAt = s.clock; }
            var list = ancestry.slice();
            list.push(Logic.ancestryEntry(s));
            ancestry = list;
            saveAncestry();
        }
        s = Logic.createEgg(Date.now(), s);
        rev++;
        save();
        notify(qsTr("Ein neues Ei! Generation %1.").arg(s.gen), "evolve");
    }

    function newEgg() { retire(s.deathCause || "age"); }
    function restart() { retire("restart"); }

    onTimeScaleChanged: if (ready) tick()

    Timer {
        interval: model.timeScale > 1 ? 4000 : 30000
        running: model.ready
        repeat: true
        onTriggered: model.tick()
    }

    Component.onCompleted: load()
}
