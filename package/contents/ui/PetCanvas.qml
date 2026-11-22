import QtQuick
import "logic.js" as Logic

// Zeichnet ein Pet (oder Ei) als weichen Vektor-Blob.
// Körper und Gesicht sind getrennte Canvas – der Körper wird nur bei
// Art-/Farbwechsel neu gezeichnet, das Gesicht bei Ausdruckswechsel.
Item {
    id: root

    property string species: "mochi"      // Schlüssel aus Logic.SPECIES oder "egg"
    property real hue: 200
    property string eggPattern: "dots"
    property real crack: 0                 // 0..1 Risse im Ei
    property bool sick: false
    property bool senior: false
    property bool ghost: false
    property string expression: "neutral"

    Accessible.role: Accessible.Graphic
    Accessible.name: species === "egg" ? "egg" : (Logic.SPECIES[species] ? Logic.SPECIES[species].label : "")

    readonly property var spec: Logic.SPECIES[species] || { body: "round", extra: "", size: 0.7, sat: 0.5 }
    readonly property real side: Math.min(width, height)
    readonly property real unit: side * (species === "egg" ? 0.82 : spec.size)
    readonly property real bodyW: unit * 0.80
    readonly property real bodyH: unit * (spec.body === "squircle" ? 0.70 : 0.72)
    readonly property real cx: width / 2
    readonly property real baseY: height / 2 + side * 0.46
    readonly property real cy: baseY - bodyH / 2
    readonly property real eyeY: cy + bodyH * (spec.body === "drop" ? 0.08 : 0.0)
    readonly property real sat: (sick ? 0.18 : spec.sat) * (senior ? 0.55 : 1) * (ghost ? 0.25 : 1)
    readonly property real hueEff: sick ? 95 : hue

    function col(h, s, l, a) {
        h = ((h % 360) + 360) % 360 / 360;
        var r, g, b;
        if (s === 0) { r = g = b = l; }
        else {
            var q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q;
            var f = function (t) {
                if (t < 0) t += 1; if (t > 1) t -= 1;
                if (t < 1 / 6) return p + (q - p) * 6 * t;
                if (t < 1 / 2) return q;
                if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
                return p;
            };
            r = f(h + 1 / 3); g = f(h); b = f(h - 1 / 3);
        }
        return "rgba(" + Math.round(r * 255) + "," + Math.round(g * 255) + "," + Math.round(b * 255) + "," + (a === undefined ? 1 : a) + ")";
    }

    Canvas {
        id: bodyCanvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (root.width <= 0) return;
            if (root.species === "egg") root.drawEgg(ctx);
            else root.drawBody(ctx);
        }
    }

    Canvas {
        id: faceCanvas
        anchors.fill: parent
        antialiasing: true
        visible: root.species !== "egg"
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (root.width <= 0 || root.species === "egg") return;
            root.drawFace(ctx);
        }
    }

    onSpeciesChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }
    onHueChanged: bodyCanvas.requestPaint()
    onEggPatternChanged: bodyCanvas.requestPaint()
    onCrackChanged: bodyCanvas.requestPaint()
    onSickChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }
    onSeniorChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }
    onGhostChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }
    onExpressionChanged: faceCanvas.requestPaint()
    onWidthChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }
    onHeightChanged: { bodyCanvas.requestPaint(); faceCanvas.requestPaint(); }

    // ------------------------------------------------------------------ Ei
    function eggPath(ctx, x, b, w, h) {
        var t = b - h;
        ctx.beginPath();
        ctx.moveTo(x, t);
        ctx.bezierCurveTo(x + w * 0.42, t, x + w * 0.52, b - h * 0.42, x + w * 0.5, b - h * 0.3);
        ctx.bezierCurveTo(x + w * 0.48, b - h * 0.05, x + w * 0.26, b, x, b);
        ctx.bezierCurveTo(x - w * 0.26, b, x - w * 0.48, b - h * 0.05, x - w * 0.5, b - h * 0.3);
        ctx.bezierCurveTo(x - w * 0.52, b - h * 0.42, x - w * 0.42, t, x, t);
        ctx.closePath();
    }

    function drawEgg(ctx) {
        var w = unit * 0.66, h = unit * 0.84, b = baseY, x = cx, t = b - h;
        var g = ctx.createLinearGradient(0, t, 0, b);
        g.addColorStop(0, col(hue, 0.45, 0.96));
        g.addColorStop(1, col(hue, 0.35, 0.86));
        eggPath(ctx, x, b, w, h);
        ctx.fillStyle = g;
        ctx.fill();

        ctx.save();
        eggPath(ctx, x, b, w, h);
        ctx.clip();
        ctx.fillStyle = col(hue, 0.55, 0.72, 0.85);
        if (eggPattern === "dots") {
            var dots = [[-0.22, 0.30, 0.09], [0.18, 0.42, 0.07], [-0.05, 0.62, 0.11], [0.24, 0.72, 0.06], [-0.28, 0.80, 0.06], [0.06, 0.20, 0.05]];
            for (var i = 0; i < dots.length; i++) {
                ctx.beginPath();
                ctx.arc(x + dots[i][0] * w, t + dots[i][1] * h, dots[i][2] * w, 0, Math.PI * 2);
                ctx.fill();
            }
        } else {
            ctx.beginPath();
            var y0 = t + h * 0.52, amp = h * 0.06, n = 6;
            ctx.moveTo(x - w, y0);
            for (var k = 0; k <= n; k++) ctx.lineTo(x - w * 0.6 + k * (w * 1.2 / n), y0 + (k % 2 ? -amp : amp));
            ctx.lineTo(x + w, y0 + h * 0.12);
            for (var j = n; j >= 0; j--) ctx.lineTo(x - w * 0.6 + j * (w * 1.2 / n), y0 + h * 0.12 + (j % 2 ? -amp : amp));
            ctx.closePath();
            ctx.fill();
        }
        // Glanz
        ctx.fillStyle = "rgba(255,255,255,0.45)";
        ctx.beginPath();
        ctx.ellipse(x - w * 0.3, t + h * 0.14, w * 0.18, h * 0.22);
        ctx.fill();
        ctx.restore();

        if (crack > 0) {
            ctx.strokeStyle = col(hue, 0.25, 0.35, 0.8);
            ctx.lineWidth = Math.max(1.5, unit * 0.018);
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.beginPath();
            var cyc = t + h * 0.42, seg = Math.ceil(6 * crack);
            ctx.moveTo(x - w * 0.42, cyc);
            for (var c = 1; c <= seg; c++) ctx.lineTo(x - w * 0.42 + c * w * 0.14, cyc + (c % 2 ? -h * 0.05 : h * 0.04));
            ctx.stroke();
        }
    }

    // ------------------------------------------------------------------ Körper
    function bodyPath(ctx, kind, x, y, w, h) {
        var t = y - h / 2, b = y + h / 2;
        ctx.beginPath();
        if (kind === "drop") {
            t = y - h * 0.62;
            ctx.moveTo(x, t);
            ctx.bezierCurveTo(x + w * 0.10, t + h * 0.22, x + w * 0.50, y - h * 0.08, x + w * 0.50, y + h * 0.20);
            ctx.bezierCurveTo(x + w * 0.50, b, x + w * 0.28, b, x, b);
            ctx.bezierCurveTo(x - w * 0.28, b, x - w * 0.50, b, x - w * 0.50, y + h * 0.20);
            ctx.bezierCurveTo(x - w * 0.50, y - h * 0.08, x - w * 0.10, t + h * 0.22, x, t);
        } else if (kind === "squircle") {
            ctx.roundedRect(x - w / 2, t, w, h, w * 0.36, h * 0.40);
        } else {
            ctx.moveTo(x, t);
            ctx.bezierCurveTo(x + w * 0.42, t, x + w * 0.50, y - h * 0.10, x + w * 0.50, y + h * 0.18);
            ctx.bezierCurveTo(x + w * 0.50, b, x + w * 0.30, b, x, b);
            ctx.bezierCurveTo(x - w * 0.30, b, x - w * 0.50, b, x - w * 0.50, y + h * 0.18);
            ctx.bezierCurveTo(x - w * 0.50, y - h * 0.10, x - w * 0.42, t, x, t);
        }
        ctx.closePath();
    }

    // Mehrteilige Formen einzeln füllen (sonst entstehen Löcher durch Windungsregeln)
    function fillBody(ctx, kind, x, y, w, h, style) {
        ctx.fillStyle = style;
        var parts = [];
        if (kind === "cloud") {
            parts = [[x - w * 0.24, y - h * 0.06, w * 0.28], [x + w * 0.24, y - h * 0.04, w * 0.28], [x, y - h * 0.22, w * 0.30]];
            ctx.beginPath();
            ctx.roundedRect(x - w / 2, y - h * 0.1, w, h * 0.6, w * 0.26, h * 0.28);
            ctx.fill();
        } else if (kind === "fluffy") {
            ctx.beginPath();
            ctx.ellipse(x - w * 0.45, y - h / 2 + h * 0.04, w * 0.9, h * 0.94);
            ctx.fill();
            for (var i = 0; i < 12; i++) {
                var a = (i / 12) * Math.PI * 2;
                var py = y + Math.sin(a) * h * 0.44;
                if (py <= y + h * 0.35) parts.push([x + Math.cos(a) * w * 0.44, py, w * 0.11]);
            }
        } else {
            bodyPath(ctx, kind, x, y, w, h);
            ctx.fill();
            return;
        }
        for (var k = 0; k < parts.length; k++) {
            ctx.beginPath();
            ctx.arc(parts[k][0], parts[k][1], parts[k][2], 0, Math.PI * 2);
            ctx.fill();
        }
    }

    function topOf(kind) {
        if (kind === "drop") return cy - bodyH * 0.62;
        if (kind === "cloud") return cy - bodyH * 0.22 - bodyW * 0.30;
        if (kind === "fluffy") return cy - bodyH * 0.5 - bodyW * 0.06;
        return cy - bodyH / 2;
    }

    function drawBody(ctx) {
        var x = cx, y = cy, w = bodyW, h = bodyH, kind = spec.body;
        var extras = (spec.extra || "").split(",");
        var has = function (e) { return extras.indexOf(e) >= 0; };
        var light = col(hueEff, sat, ghost ? 0.94 : 0.84);
        var base = col(hueEff, sat, ghost ? 0.88 : 0.70);
        var deep = col(hueEff, sat, 0.56);
        var top = topOf(kind);
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        // Hinter dem Körper
        if (has("wings")) {
            ctx.fillStyle = ghost ? "rgba(255,255,255,0.5)" : col(hue, 0.5, 0.95);
            ctx.strokeStyle = col(hue, 0.3, 0.6, 0.25);
            ctx.lineWidth = Math.max(1, unit * 0.012);
            for (var sgn = -1; sgn <= 1; sgn += 2) {
                for (var f = 0; f < 2; f++) {
                    ctx.save();
                    ctx.translate(x + sgn * w * 0.40, y - h * (0.04 + f * 0.17));
                    ctx.rotate(sgn * (0.35 - f * 0.45));
                    ctx.beginPath();
                    ctx.ellipse(sgn > 0 ? 0 : -w * 0.26, -h * 0.10, w * 0.26, h * 0.20);
                    ctx.fill();
                    ctx.stroke();
                    ctx.restore();
                }
            }
        }
        if (has("cat")) {
            for (var c = -1; c <= 1; c += 2) {
                ctx.fillStyle = base;
                ctx.beginPath();
                ctx.moveTo(x + c * w * 0.40, top + h * 0.22);
                ctx.lineTo(x + c * w * 0.36, top - h * 0.16);
                ctx.lineTo(x + c * w * 0.10, top + h * 0.06);
                ctx.closePath();
                ctx.fill();
                ctx.fillStyle = "rgba(255,170,190,0.7)";
                ctx.beginPath();
                ctx.moveTo(x + c * w * 0.33, top + h * 0.14);
                ctx.lineTo(x + c * w * 0.33, top - h * 0.06);
                ctx.lineTo(x + c * w * 0.18, top + h * 0.07);
                ctx.closePath();
                ctx.fill();
            }
        }
        if (has("bunny")) {
            for (var bn = -1; bn <= 1; bn += 2) {
                ctx.save();
                ctx.translate(x + bn * w * 0.18, top + h * 0.05);
                ctx.rotate(bn * 0.22);
                ctx.fillStyle = base;
                ctx.beginPath();
                ctx.ellipse(-w * 0.09, -h * 0.46, w * 0.18, h * 0.5);
                ctx.fill();
                ctx.fillStyle = "rgba(255,180,200,0.6)";
                ctx.beginPath();
                ctx.ellipse(-w * 0.045, -h * 0.38, w * 0.09, h * 0.34);
                ctx.fill();
                ctx.restore();
            }
        }
        if (has("droopy")) {
            ctx.fillStyle = deep;
            for (var d = -1; d <= 1; d += 2) {
                ctx.save();
                ctx.translate(x + d * w * 0.44, y - h * 0.18);
                ctx.rotate(d * 0.5);
                ctx.beginPath();
                ctx.ellipse(-w * 0.08, -h * 0.04, w * 0.16, h * 0.42);
                ctx.fill();
                ctx.restore();
            }
        }
        if (has("horns")) {
            ctx.fillStyle = "rgba(250,236,214,1)";
            for (var hn = -1; hn <= 1; hn += 2) {
                ctx.beginPath();
                ctx.moveTo(x + hn * w * 0.16, top + h * 0.10);
                ctx.quadraticCurveTo(x + hn * w * 0.20, top - h * 0.20, x + hn * w * 0.38, top - h * 0.22);
                ctx.quadraticCurveTo(x + hn * w * 0.30, top - h * 0.05, x + hn * w * 0.32, top + h * 0.12);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Körper
        var g = ctx.createLinearGradient(0, top, 0, y + h / 2);
        g.addColorStop(0, light);
        g.addColorStop(1, base);
        fillBody(ctx, kind, x, y, w, h, g);

        // Bauch & Glanz
        ctx.fillStyle = ghost ? "rgba(255,255,255,0.25)" : "rgba(255,255,255,0.22)";
        ctx.beginPath();
        ctx.ellipse(x - w * 0.22, y + h * 0.12, w * 0.44, h * 0.32);
        ctx.fill();
        ctx.fillStyle = "rgba(255,255,255,0.5)";
        ctx.beginPath();
        ctx.ellipse(x - w * 0.34, y - h * 0.30, w * 0.16, h * 0.10);
        ctx.fill();

        // Auf dem Körper
        if (has("sprout")) {
            ctx.strokeStyle = "rgba(96,170,110,1)";
            ctx.lineWidth = Math.max(1.5, unit * 0.025);
            ctx.beginPath();
            ctx.moveTo(x, top + h * 0.03);
            ctx.quadraticCurveTo(x + w * 0.02, top - h * 0.10, x, top - h * 0.20);
            ctx.stroke();
            ctx.fillStyle = "rgba(120,196,124,1)";
            for (var l = -1; l <= 1; l += 2) {
                ctx.save();
                ctx.translate(x, top - h * 0.18);
                ctx.rotate(l * 0.9);
                ctx.beginPath();
                ctx.ellipse(-w * 0.05, -h * 0.17, w * 0.10, h * 0.17);
                ctx.fill();
                ctx.restore();
            }
        }
        if (has("star")) {
            ctx.strokeStyle = deep;
            ctx.lineWidth = Math.max(1.5, unit * 0.02);
            ctx.beginPath();
            ctx.moveTo(x + w * 0.04, top + h * 0.02);
            ctx.quadraticCurveTo(x + w * 0.16, top - h * 0.14, x + w * 0.12, top - h * 0.26);
            ctx.stroke();
            drawStar(ctx, x + w * 0.12, top - h * 0.30, unit * 0.075, "rgba(255,206,92,1)");
        }
        if (has("tuft")) {
            ctx.strokeStyle = deep;
            ctx.lineWidth = Math.max(1.5, unit * 0.028);
            for (var tf = -1; tf <= 1; tf++) {
                ctx.beginPath();
                ctx.moveTo(x + tf * w * 0.10, top + h * 0.03);
                ctx.quadraticCurveTo(x + tf * w * 0.16, top - h * 0.16, x + tf * w * 0.04 + w * 0.06, top - h * 0.12);
                ctx.stroke();
            }
        }
        if (has("halo")) {
            ctx.strokeStyle = "rgba(255,214,110,0.95)";
            ctx.lineWidth = Math.max(2, unit * 0.035);
            ctx.beginPath();
            ctx.ellipse(x - w * 0.24, top - h * 0.32, w * 0.48, h * 0.14);
            ctx.stroke();
        }
        if (has("crown")) {
            var cw = w * 0.42, cb = top + h * 0.06, ch = h * 0.24;
            ctx.fillStyle = "rgba(255,200,80,1)";
            ctx.beginPath();
            ctx.moveTo(x - cw / 2, cb);
            ctx.lineTo(x - cw / 2, cb - ch * 0.75);
            ctx.lineTo(x - cw / 4, cb - ch * 0.35);
            ctx.lineTo(x, cb - ch);
            ctx.lineTo(x + cw / 4, cb - ch * 0.35);
            ctx.lineTo(x + cw / 2, cb - ch * 0.75);
            ctx.lineTo(x + cw / 2, cb);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = "rgba(240,110,140,1)";
            ctx.beginPath();
            ctx.arc(x, cb - ch * 0.28, unit * 0.022, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    function drawStar(ctx, x, y, r, color) {
        ctx.fillStyle = color;
        ctx.beginPath();
        for (var i = 0; i < 10; i++) {
            var a = -Math.PI / 2 + i * Math.PI / 5, rr = i % 2 ? r * 0.45 : r;
            if (i === 0) ctx.moveTo(x + Math.cos(a) * rr, y + Math.sin(a) * rr);
            else ctx.lineTo(x + Math.cos(a) * rr, y + Math.sin(a) * rr);
        }
        ctx.closePath();
        ctx.fill();
    }

    function drawHeart(ctx, x, y, s, color) {
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.moveTo(x, y + s * 0.35);
        ctx.bezierCurveTo(x - s * 1.1, y - s * 0.4, x - s * 0.35, y - s * 1.0, x, y - s * 0.35);
        ctx.bezierCurveTo(x + s * 0.35, y - s * 1.0, x + s * 1.1, y - s * 0.4, x, y + s * 0.35);
        ctx.fill();
    }

    // ------------------------------------------------------------------ Gesicht
    function drawFace(ctx) {
        var w = bodyW, ex = w * 0.18, er = unit * 0.052, y = eyeY;
        var dark = ghost ? "rgba(90,90,110,0.6)" : "rgba(43,37,51,1)";
        var e = expression;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.strokeStyle = dark;
        ctx.fillStyle = dark;
        ctx.lineWidth = Math.max(1.6, er * 0.55);

        // Wangen
        if (!ghost) {
            ctx.fillStyle = sick ? "rgba(140,190,120,0.35)" : "rgba(255,140,160,0.38)";
            for (var s = -1; s <= 1; s += 2) {
                ctx.beginPath();
                ctx.ellipse(cx + s * w * 0.30 - er * 1.1, y + er * 1.2, er * 2.2, er * 1.1);
                ctx.fill();
            }
            ctx.fillStyle = dark;
        }

        for (var side = -1; side <= 1; side += 2) {
            var x = cx + side * ex;
            if (e === "happy" || e === "eat2") {
                ctx.beginPath();
                ctx.arc(x, y + er * 0.5, er * 1.05, Math.PI * 1.15, Math.PI * 1.85);
                ctx.stroke();
            } else if (e === "sleep" || e === "blink" || ghost) {
                ctx.beginPath();
                ctx.arc(x, y - er * 0.4, er * 1.0, Math.PI * 0.15, Math.PI * 0.85);
                ctx.stroke();
            } else if (e === "love") {
                drawHeart(ctx, x, y, er * 1.25, "rgba(240,90,120,1)");
                ctx.fillStyle = dark;
            } else if (e === "sick") {
                ctx.beginPath();
                ctx.arc(x, y, er * 0.9, 0, Math.PI * 1.5);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(x, y, er * 0.25, 0, Math.PI * 2);
                ctx.fill();
            } else if (e === "dead") {
                ctx.beginPath();
                ctx.moveTo(x - er * 0.8, y - er * 0.8); ctx.lineTo(x + er * 0.8, y + er * 0.8);
                ctx.moveTo(x + er * 0.8, y - er * 0.8); ctx.lineTo(x - er * 0.8, y + er * 0.8);
                ctx.stroke();
            } else {
                var hgt = e === "weak" ? er * 1.0 : er * 2.3;
                ctx.beginPath();
                ctx.ellipse(x - er * 0.95, y - hgt / 2, er * 1.9, hgt);
                ctx.fill();
                if (e !== "weak") {
                    ctx.fillStyle = "rgba(255,255,255,0.95)";
                    ctx.beginPath();
                    ctx.arc(x + er * 0.35, y - er * 0.5, er * 0.42, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.fillStyle = dark;
                }
                if (e === "sad") {
                    ctx.fillStyle = "rgba(120,180,240,0.8)";
                    ctx.beginPath();
                    ctx.ellipse(x + side * er * 0.4 - er * 0.3, y + er * 1.3, er * 0.6, er * 0.9);
                    ctx.fill();
                    ctx.fillStyle = dark;
                }
            }
        }

        // Augenbrauen
        if (spec.extra.indexOf("brows") >= 0 || e === "sad" || e === "sick") {
            var angry = spec.extra.indexOf("brows") >= 0 && e !== "sad";
            for (var b = -1; b <= 1; b += 2) {
                ctx.beginPath();
                ctx.moveTo(cx + b * (ex - er * 1.1), y - er * (angry ? 2.2 : 2.6));
                ctx.lineTo(cx + b * (ex + er * 1.1), y - er * (angry ? 2.9 : 2.2));
                ctx.stroke();
            }
        }

        // Brille für Senioren
        if (senior && !ghost) {
            ctx.strokeStyle = "rgba(90,80,100,0.85)";
            ctx.lineWidth = Math.max(1.2, er * 0.32);
            for (var g = -1; g <= 1; g += 2) {
                ctx.beginPath();
                ctx.arc(cx + g * ex, y, er * 1.9, 0, Math.PI * 2);
                ctx.stroke();
            }
            ctx.beginPath();
            ctx.moveTo(cx - ex + er * 1.9, y);
            ctx.lineTo(cx + ex - er * 1.9, y);
            ctx.stroke();
            ctx.strokeStyle = dark;
            ctx.lineWidth = Math.max(1.6, er * 0.55);
        }

        // Mund
        var my = y + er * 2.4;
        ctx.beginPath();
        if (e === "happy" || e === "love") {
            ctx.moveTo(cx - er * 1.1, my - er * 0.2);
            ctx.quadraticCurveTo(cx, my + er * 1.6, cx + er * 1.1, my - er * 0.2);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = "rgba(240,120,140,1)";
            ctx.beginPath();
            ctx.ellipse(cx - er * 0.5, my + er * 0.35, er * 1.0, er * 0.5);
            ctx.fill();
        } else if (e === "sad" || e === "dead") {
            ctx.arc(cx, my + er * 0.9, er * 0.9, Math.PI * 1.15, Math.PI * 1.85);
            ctx.stroke();
        } else if (e === "hungry" || e === "eat1") {
            ctx.ellipse(cx - er * 0.6, my - er * 0.4, er * 1.2, er * (e === "eat1" ? 1.6 : 1.2));
            ctx.fill();
        } else if (e === "sick" || e === "weak") {
            ctx.moveTo(cx - er * 1.0, my);
            ctx.quadraticCurveTo(cx - er * 0.5, my - er * 0.5, cx, my);
            ctx.quadraticCurveTo(cx + er * 0.5, my + er * 0.5, cx + er * 1.0, my);
            ctx.stroke();
        } else if (e === "sleep") {
            ctx.ellipse(cx - er * 0.35, my - er * 0.2, er * 0.7, er * 0.6);
            ctx.fill();
        } else {
            ctx.moveTo(cx - er * 0.9, my - er * 0.2);
            ctx.quadraticCurveTo(cx - er * 0.45, my + er * 0.6, cx, my - er * 0.05);
            ctx.quadraticCurveTo(cx + er * 0.45, my + er * 0.6, cx + er * 0.9, my - er * 0.2);
            ctx.stroke();
        }
    }
}
