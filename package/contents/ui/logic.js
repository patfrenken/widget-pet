.pragma library

// ---------------------------------------------------------------------------
// Widget Pet – Spiellogik (reines JavaScript, ohne QML-Abhängigkeiten)
// ---------------------------------------------------------------------------

var MIN = 60 * 1000;
var HOUR = 60 * MIN;
var DAY = 24 * HOUR;

var EGG_MS = 2 * HOUR;              // Brutzeit
var BABY_END = EGG_MS + 14 * DAY;   // 2 Wochen Kleinkind
var TEEN_END = EGG_MS + 35 * DAY;   // 3 Wochen Teenager
var LIFE_MIN = 80 * DAY;            // Lebensende ~ 11,5–12,5 Wochen
var LIFE_BONUS = 8 * DAY;
var SENIOR_SPAN = 7 * DAY;
var CRITICAL_LIMIT = 48 * HOUR;     // so lange darf Gesundheit bei 0 sein
var OFFLINE_GAP = 5 * MIN;          // ab dieser Lücke gilt „PC war aus“
var MAX_STEP = 10 * MIN;
var MAX_POOP = 4;

var STAGE_LABEL = {
    egg: "Ei", baby: "Kleinkind", teen: "Teenager",
    adult: "Erwachsen", senior: "Senior", dead: "Sternenreise"
};

// Körperformen & Accessoires werden von PetCanvas.qml gezeichnet.
var SPECIES = {
    mochi:   { stage: "baby",  label: "Mochi",   body: "round",    extra: "",            size: 0.60, sat: 0.55, desc: "Rund, weich und neugierig." },
    tropf:   { stage: "baby",  label: "Tröpfi",  body: "drop",     extra: "sprout",      size: 0.60, sat: 0.55, desc: "Ein kleiner Tropfen mit Keimling." },
    funkel:  { stage: "teen",  label: "Funkel",  body: "round",    extra: "star",        size: 0.74, sat: 0.62, desc: "Gesund und fröhlich – mit Sternantenne." },
    knuff:   { stage: "teen",  label: "Knuff",   body: "squircle", extra: "cat",         size: 0.76, sat: 0.50, desc: "Fit, aber etwas gelangweilt." },
    wusel:   { stage: "teen",  label: "Wusel",   body: "fluffy",   extra: "tuft",        size: 0.74, sat: 0.60, desc: "Verspielt, aber nicht ganz fit." },
    mopp:    { stage: "teen",  label: "Mopp",    body: "drop",     extra: "droopy",      size: 0.70, sat: 0.30, desc: "Ein bisschen vernachlässigt." },
    lumi:    { stage: "adult", label: "Lumi",    body: "round",    extra: "halo,wings",  size: 0.80, sat: 0.60, desc: "Strahlend – rundum gut umsorgt." },
    kiko:    { stage: "adult", label: "Kiko",    body: "round",    extra: "crown,wings", size: 0.80, sat: 0.66, desc: "Die perfekte Pflege. Royal!" },
    brumm:   { stage: "adult", label: "Brumm",   body: "squircle", extra: "horns",       size: 0.90, sat: 0.45, desc: "Kräftig und gelassen, braucht mehr Spaß." },
    flausch: { stage: "adult", label: "Flausch", body: "cloud",    extra: "bunny",       size: 0.88, sat: 0.55, desc: "Wolkig verspielt, Gesundheit war wackelig." },
    grummel: { stage: "adult", label: "Grummel", body: "fluffy",   extra: "sprout,brows",size: 0.84, sat: 0.22, desc: "Grummelig – das Leben war hart." }
};

var FOODS = [
    { id: "rice",  label: "Reisbällchen", price: 0,  hunger: 18, health: 0,  fun: 0,  note: "gratis" },
    { id: "apple", label: "Apfelschnitze", price: 3, hunger: 14, health: 6,  fun: 2,  note: "gesund" },
    { id: "cake",  label: "Törtchen",     price: 5,  hunger: 10, health: -4, fun: 16, note: "macht froh" },
    { id: "bento", label: "Bento-Box",    price: 9,  hunger: 40, health: 9,  fun: 6,  note: "ausgewogen" },
    { id: "feast", label: "Festmahl",     price: 20, hunger: 65, health: 16, fun: 18, note: "luxuriös" }
];

var GAMES = [
    { id: "cuddle", label: "Kuscheln",       minStage: "baby",  desc: "Streichle dein Pet und finde die Kitzelstellen." },
    { id: "flap",   label: "Hüpfflug",       minStage: "teen",  desc: "Flattere durch die Wolkentürme." },
    { id: "cafe",   label: "Bubble-Tea-Bar", minStage: "adult", desc: "60 Sekunden Schicht – so viele Bestellungen wie möglich." }
];

var STAGE_ORDER = ["egg", "baby", "teen", "adult"];

// --------------------------------------------------------------------------- Helfer
function clamp(v, lo, hi) { return v < lo ? lo : (v > hi ? hi : v); }
function rnd(a, b) { return a + Math.random() * (b - a); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function dayKey(ms) { var d = new Date(ms); return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate(); }

var SYL_A = ["Mo", "Pu", "Ki", "Lu", "Na", "Bo", "Mi", "Fu", "Ri", "Yu", "Pi", "No", "Su", "Ka", "Ru", "Wu", "Te", "Ba"];
var SYL_B = ["chi", "mi", "ko", "ni", "bu", "ffel", "li", "po", "nu", "ki", "sel", "lo", "pi", "ra", "mo"];
function makeName() { return pick(SYL_A) + pick(SYL_B); }

function stageIndex(stage) { return STAGE_ORDER.indexOf(stage === "senior" ? "adult" : stage); }

function newStageStats() { return { hSum: 0, fSum: 0, t: 0, mistakes: 0 }; }

// --------------------------------------------------------------------------- Erzeugen
function createEgg(now, parent) {
    var hue = parent ? (parent.hue + rnd(-35, 35) + 360) % 360 : rnd(0, 360);
    var blessed = parent && (parent.species.adult === "lumi" || parent.species.adult === "kiko");
    return {
        v: 1,
        gen: parent ? parent.gen + 1 : 1,
        name: makeName(),
        hue: hue,
        eggPattern: pick(["dots", "stripes"]),
        blessed: !!blessed,
        stage: "egg",
        species: { baby: "", teen: "", adult: "" },
        ageMs: 0,
        warmMs: 0,
        hunger: 75, fun: 70, health: blessed ? 100 : 85,
        poop: 0, poopTimerMs: rnd(3, 5) * HOUR, digest: 0, poopNeglectMs: 0,
        sick: false, critMs: 0,
        coins: parent ? Math.floor(parent.coins * 0.5) + (blessed ? 15 : 5) : 10,
        lifespanMs: LIFE_MIN + LIFE_BONUS * 0.5,
        stageStats: newStageStats(),
        totalMistakes: 0,
        flags: { hungerZero: false, funZero: false },
        best: parent ? parent.best : { cuddle: 0, flap: 0, cafe: 0 },
        playLog: [],
        bonusDay: "",
        patBudget: 10, patRefillMs: 0,
        life: { games: 0, earned: 0, fed: 0 },
        bornAt: now,
        clock: now,
        lastTick: now,
        dead: false, deathCause: "", diedAt: 0
    };
}

function normalize(s, now) {
    if (!s || typeof s !== "object" || s.v !== 1) return createEgg(now, null);
    if (!s.best) s.best = { cuddle: 0, flap: 0, cafe: 0 };
    if (!s.playLog) s.playLog = [];
    if (!s.life) s.life = { games: 0, earned: 0, fed: 0 };
    return s;
}

// --------------------------------------------------------------------------- Abgeleitete Werte
function isSenior(s) { return s.stage === "adult" && s.ageMs >= s.lifespanMs - SENIOR_SPAN; }
function displayStage(s) { return s.dead ? "dead" : (isSenior(s) ? "senior" : s.stage); }
function stageLabel(s) { return STAGE_LABEL[displayStage(s)]; }

function currentSpecies(s) {
    if (s.stage === "egg") return "";
    return s.species[s.stage === "dead" ? "adult" : s.stage] || s.species.adult || s.species.teen || s.species.baby;
}

function isAsleep(s, sleepStart, sleepEnd) {
    if (s.dead || s.stage === "egg") return false;
    var h = new Date(s.clock).getHours();
    if (sleepStart === sleepEnd) return false;
    return sleepStart > sleepEnd ? (h >= sleepStart || h < sleepEnd) : (h >= sleepStart && h < sleepEnd);
}

function mood(s, asleep) {
    if (s.dead) return "dead";
    if (s.stage === "egg") return "egg";
    if (asleep) return "sleep";
    if (s.sick) return "sick";
    if (s.health <= 15) return "weak";
    if (s.hunger < 25) return "hungry";
    if (s.fun < 30) return "sad";
    if (s.fun >= 70 && s.hunger >= 50 && s.health >= 60) return "happy";
    return "neutral";
}

// Wichtigstes Bedürfnis für die Sprechblase
function attention(s, asleep) {
    if (s.dead || s.stage === "egg") return "";
    if (s.sick) return "sick";
    if (asleep) return "";
    if (s.hunger < 25) return "hungry";
    if (s.poop > 0) return "poop";
    if (s.fun < 30) return "bored";
    return "";
}

function ageDays(s) { return Math.max(0, Math.floor((s.ageMs - EGG_MS) / DAY)); }
function hatchProgress(s) { return clamp((s.ageMs + s.warmMs) / EGG_MS, 0, 1); }

function gameUnlocked(s, gameId) {
    if (s.dead || s.stage === "egg") return false;
    for (var i = 0; i < GAMES.length; i++)
        if (GAMES[i].id === gameId) return stageIndex(s.stage) >= stageIndex(GAMES[i].minStage);
    return false;
}

function quality(st) {
    if (st.t <= 0) return 0.5;
    var h = st.hSum / st.t, f = st.fSum / st.t;
    return clamp((h + f) / 200 - st.mistakes * 0.04, 0, 1);
}
function stageAverages(st) {
    if (st.t <= 0) return { h: 70, f: 70 };
    return { h: st.hSum / st.t - st.mistakes * 4, f: st.fSum / st.t - st.mistakes * 4 };
}

// --------------------------------------------------------------------------- Entwicklung
function evolve(s, events) {
    var a = stageAverages(s.stageStats);
    if (s.stage === "egg") {
        s.stage = "baby";
        s.species.baby = s.eggPattern === "dots" ? "mochi" : "tropf";
        events.push({ type: "hatch", species: s.species.baby });
    } else if (s.stage === "baby") {
        s.stage = "teen";
        if (a.h >= 60 && a.f >= 60) s.species.teen = "funkel";
        else if (a.h >= 60) s.species.teen = "knuff";
        else if (a.f >= 60) s.species.teen = "wusel";
        else s.species.teen = "mopp";
        events.push({ type: "evolve", species: s.species.teen });
    } else if (s.stage === "teen") {
        s.stage = "adult";
        var q = quality(s.stageStats);
        if (a.h >= 80 && a.f >= 80 && s.stageStats.mistakes === 0) s.species.adult = "kiko";
        else if (a.h >= 68 && a.f >= 68) s.species.adult = "lumi";
        else if (a.h >= 60) s.species.adult = "brumm";
        else if (a.f >= 60) s.species.adult = "flausch";
        else s.species.adult = "grummel";
        s.lifespanMs = LIFE_MIN + LIFE_BONUS * q;
        events.push({ type: "evolve", species: s.species.adult });
    }
    s.stageStats = newStageStats();
}

function die(s, cause, events) {
    s.dead = true;
    s.deathCause = cause;
    s.diedAt = s.clock;
    events.push({ type: "death", cause: cause });
}

function ancestryEntry(s) {
    return {
        gen: s.gen, name: s.name, hue: s.hue,
        forms: [s.species.baby, s.species.teen, s.species.adult],
        days: ageDays(s), cause: s.deathCause,
        bornAt: s.bornAt, diedAt: s.diedAt,
        mistakes: s.totalMistakes, games: s.life.games
    };
}

// --------------------------------------------------------------------------- Zeitschritt
function step(s, dt, offline, asleep, events) {
    var h = dt / HOUR;

    if (s.stage === "egg") {
        s.ageMs += dt;
        if (s.ageMs + s.warmMs >= EGG_MS) evolve(s, events);
        return;
    }

    var rH = s.stage === "baby" ? 4.2 : (s.stage === "teen" ? 3.6 : 3.0);
    var rF = s.stage === "baby" ? 3.0 : (s.stage === "teen" ? 2.7 : 2.3);
    if (isSenior(s)) { rH = 2.6; rF = 2.8; }
    var mult = (offline ? 0.4 : 1) * (asleep ? 0.3 : 1);

    var pH = s.hunger, pF = s.fun, pHealth = s.health;
    s.hunger = clamp(s.hunger - rH * h * mult, 0, 100);
    s.fun = clamp(s.fun - rF * h * mult, 0, 100);

    // Verdauung
    if (!asleep) {
        s.poopTimerMs -= dt * (offline ? 0.5 : 1);
        if (s.poopTimerMs <= 0) {
            s.poopTimerMs = rnd(3.5, 5.5) * HOUR;
            if (s.digest > 0 && s.poop < (offline ? 1 : MAX_POOP)) {
                s.poop += 1;
                s.digest = Math.max(0, s.digest - 1);
                events.push({ type: "poop" });
            }
        }
    }
    s.poopNeglectMs = s.poop > 0 ? s.poopNeglectMs + dt : 0;

    // Gesundheit
    var d = 0;
    if (s.hunger < 15) d -= 4; else if (s.hunger < 35) d -= 1.5;
    if (s.fun < 15) d -= 2; else if (s.fun < 35) d -= 0.5;
    d -= 1.2 * s.poop;
    if (s.sick) d -= 2.5;
    if (s.hunger >= 50 && s.fun >= 40 && s.poop === 0 && !s.sick) d += 1.5;
    if (d < 0) d *= offline ? 0.5 : 1;
    s.health = clamp(s.health + d * h * (asleep && d < 0 ? 0.5 : 1), 0, 100);

    if (offline) {
        // Offline nie in den kritischen Bereich rutschen
        s.hunger = Math.max(s.hunger, Math.min(pH, 20));
        s.fun = Math.max(s.fun, Math.min(pF, 20));
        s.health = Math.max(s.health, Math.min(pHealth, 30));
    } else if (!s.sick && (s.health < 35 || s.poop >= 3) && Math.random() < 0.12 * h) {
        s.sick = true;
        events.push({ type: "sick" });
    }

    // Pflegefehler
    if (!offline) {
        if (s.hunger <= 0 && !s.flags.hungerZero) { s.flags.hungerZero = true; mistake(s); }
        if (s.fun <= 0 && !s.flags.funZero) { s.flags.funZero = true; mistake(s); }
        if (s.poopNeglectMs > 3 * HOUR) { s.poopNeglectMs = 0; mistake(s); }
    }
    if (s.hunger > 30) s.flags.hungerZero = false;
    if (s.fun > 30) s.flags.funZero = false;

    // Kritischer Zustand
    if (s.health <= 0 && !offline) {
        s.critMs += dt;
        if (s.critMs >= CRITICAL_LIMIT) { die(s, "neglect", events); return; }
    } else {
        s.critMs = Math.max(0, s.critMs - dt * 0.5);
    }

    // Statistik für die Entwicklung
    s.stageStats.hSum += s.health * h;
    s.stageStats.fSum += s.fun * h;
    s.stageStats.t += h;

    // Streichel-Budget auffüllen
    s.patRefillMs += dt;
    if (s.patRefillMs >= HOUR) { s.patRefillMs = 0; s.patBudget = 10; }

    s.ageMs += dt;
    if (s.stage === "baby" && s.ageMs >= BABY_END) evolve(s, events);
    else if (s.stage === "teen" && s.ageMs >= TEEN_END) evolve(s, events);
    else if (s.stage === "adult" && s.ageMs >= s.lifespanMs) die(s, "age", events);
}

function mistake(s) { s.stageStats.mistakes += 1; s.totalMistakes += 1; }

// opts: { timeScale, sleepStart, sleepEnd }
function tick(s, now, opts) {
    var events = [];
    var realDt = now - s.lastTick;
    s.lastTick = now;
    if (s.dead || realDt <= 0) { if (opts.timeScale === 1) s.clock = now; return events; }
    var offline = realDt > OFFLINE_GAP;
    var scale = opts.timeScale || 1;
    var simDt = Math.min(realDt * scale, 200 * DAY);
    while (simDt > 0 && !s.dead) {
        var dt = Math.min(MAX_STEP, simDt);
        var asleep = isAsleep(s, opts.sleepStart, opts.sleepEnd);
        step(s, dt, offline, asleep, events);
        s.clock += dt;
        simDt -= dt;
    }
    if (scale === 1) s.clock = now;
    return events;
}

// --------------------------------------------------------------------------- Aktionen
function canAct(s, asleep) {
    if (s.dead) return "Dein Pet ist auf Sternenreise.";
    if (s.stage === "egg") return "Noch im Ei … streichle es, um es zu wärmen.";
    if (asleep) return "Psst … es schläft.";
    return "";
}

function feed(s, foodId, asleep) {
    var block = canAct(s, asleep);
    if (block) return { ok: false, msg: block };
    var f = null;
    for (var i = 0; i < FOODS.length; i++) if (FOODS[i].id === foodId) f = FOODS[i];
    if (!f) return { ok: false, msg: "" };
    if (s.coins < f.price) return { ok: false, msg: "Nicht genug Münzen." };
    if (s.hunger >= 95) {
        s.health = clamp(s.health - 3, 0, 100);
        s.fun = clamp(s.fun - 2, 0, 100);
        return { ok: true, msg: "Uff … pappsatt!" };
    }
    s.coins -= f.price;
    s.hunger = clamp(s.hunger + f.hunger, 0, 100);
    s.health = clamp(s.health + f.health, 0, 100);
    s.fun = clamp(s.fun + f.fun, 0, 100);
    s.digest = Math.min(3, s.digest + (f.hunger >= 30 ? 1 : 0.5));
    s.life.fed += 1;
    var msgs = { rice: "Mampf!", apple: "Knackig!", cake: "Süß! ♥", bento: "Lecker ausgewogen!", feast: "Ein Festmahl! ✦" };
    return { ok: true, msg: msgs[f.id] };
}

function clean(s, asleep) {
    if (s.dead || s.stage === "egg") return { ok: false, msg: canAct(s, false) };
    if (s.poop === 0) return { ok: false, msg: "Schon blitzblank." };
    s.poop = 0;
    s.poopNeglectMs = 0;
    s.fun = clamp(s.fun + 2, 0, 100);
    return { ok: true, msg: "Blitzblank! ✧" };
}

function medicine(s) {
    if (s.dead || s.stage === "egg") return { ok: false, msg: canAct(s, false) };
    if (!s.sick) {
        s.health = clamp(s.health - 2, 0, 100);
        return { ok: false, msg: "Es ist doch gar nicht krank." };
    }
    s.sick = false;
    s.health = clamp(s.health + 12, 0, 100);
    s.fun = clamp(s.fun - 5, 0, 100);
    return { ok: true, msg: "Bäh … aber es geht besser!" };
}

function pat(s, asleep) {
    if (s.dead) return { ok: false, msg: "" };
    if (s.stage === "egg") {
        if (s.warmMs < 30 * MIN) { s.warmMs += MIN; return { ok: true, msg: "Das Ei wird warm …" }; }
        return { ok: false, msg: "Kuschelig warm." };
    }
    if (asleep) return { ok: false, msg: "Zzz …" };
    if (s.patBudget > 0) { s.patBudget -= 1; s.fun = clamp(s.fun + 1, 0, 100); return { ok: true, msg: "" }; }
    return { ok: false, msg: "" };
}

// Ergebnis eines Minispiels verbuchen
function gameResult(s, gameId, score, coins, funBase, now) {
    var hourAgo = now - HOUR;
    s.playLog = s.playLog.filter(function (t) { return t > hourAgo; });
    var fatigue = [1, 0.85, 0.7, 0.55, 0.4, 0.3][Math.min(5, s.playLog.length)];
    s.playLog.push(now);
    var fun = Math.round(funBase * fatigue);
    var bonus = 0;
    var today = dayKey(now);
    if (s.bonusDay !== today) { s.bonusDay = today; bonus = 5; }
    s.fun = clamp(s.fun + fun, 0, 100);
    s.hunger = clamp(s.hunger - 4, 0, 100);
    s.coins += coins + bonus;
    s.life.games += 1;
    s.life.earned += coins + bonus;
    var record = score > (s.best[gameId] || 0);
    if (record) s.best[gameId] = score;
    return { fun: fun, coins: coins, bonus: bonus, record: record, tired: fatigue < 0.6 };
}

// --------------------------------------------------------------------------- Export für Node-Tests
if (typeof module !== "undefined") {
    module.exports = {
        HOUR: HOUR, DAY: DAY, EGG_MS: EGG_MS, SPECIES: SPECIES, FOODS: FOODS, GAMES: GAMES,
        createEgg: createEgg, normalize: normalize, tick: tick, feed: feed, clean: clean,
        medicine: medicine, pat: pat, gameResult: gameResult, mood: mood, attention: attention,
        isAsleep: isAsleep, displayStage: displayStage, stageLabel: stageLabel,
        currentSpecies: currentSpecies, ancestryEntry: ancestryEntry, gameUnlocked: gameUnlocked,
        ageDays: ageDays, hatchProgress: hatchProgress, isSenior: isSenior
    };
}
