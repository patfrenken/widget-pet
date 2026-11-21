import QtQuick

// Ersatzbild, solange das Pet unterwegs ist: Kita, Schule, Bubble-Tea-Bar oder Liegestuhl.
// Gezeichnet in einem 200×150-Raster, das auf die verfügbare Fläche skaliert wird.
Canvas {
    id: away

    property string place: "kita"
    property real hue: 200

    antialiasing: true
    Accessible.role: Accessible.Graphic
    Accessible.name: ({ kita: qsTr("Kita"), school: qsTr("Schule"), work: qsTr("Bubble-Tea-Bar"), relax: qsTr("Liegestuhl") })[place] || ""

    onPlaceChanged: requestPaint()
    onHueChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function hsl(h, s, l, a) {
        h = ((h % 360) + 360) % 360 / 360;
        var q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q;
        var f = function (t) {
            if (t < 0) t += 1; if (t > 1) t -= 1;
            if (t < 1 / 6) return p + (q - p) * 6 * t;
            if (t < 1 / 2) return q;
            if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
            return p;
        };
        return "rgba(" + Math.round(f(h + 1 / 3) * 255) + "," + Math.round(f(h) * 255) + "," + Math.round(f(h - 1 / 3) * 255) + "," + (a === undefined ? 1 : a) + ")";
    }

    function rr(ctx, x, y, w, h, r, color) {
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.roundedRect(x, y, w, h, r, r);
        ctx.fill();
    }

    function circle(ctx, x, y, r, color) {
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(x, y, r, 0, Math.PI * 2);
        ctx.fill();
    }

    // Kleiner Pet-Kopf in der Farbe des eigenen Pets
    function petHead(ctx, x, y, r, sleepy) {
        circle(ctx, x, y, r, hsl(hue, 0.55, 0.74));
        ctx.fillStyle = "rgba(255,255,255,0.45)";
        ctx.beginPath();
        ctx.ellipse(x - r * 0.65, y - r * 0.75, r * 0.6, r * 0.35);
        ctx.fill();
        ctx.fillStyle = "rgba(43,37,51,1)";
        ctx.strokeStyle = "rgba(43,37,51,1)";
        ctx.lineWidth = Math.max(1, r * 0.14);
        ctx.lineCap = "round";
        for (var s = -1; s <= 1; s += 2) {
            if (sleepy) {
                ctx.beginPath();
                ctx.arc(x + s * r * 0.36, y - r * 0.05, r * 0.16, Math.PI * 0.15, Math.PI * 0.85);
                ctx.stroke();
            } else {
                ctx.beginPath();
                ctx.ellipse(x + s * r * 0.36 - r * 0.1, y - r * 0.25, r * 0.2, r * 0.32);
                ctx.fill();
            }
        }
        ctx.fillStyle = "rgba(255,140,160,0.45)";
        for (var b = -1; b <= 1; b += 2) {
            ctx.beginPath();
            ctx.ellipse(x + b * r * 0.62 - r * 0.18, y + r * 0.12, r * 0.36, r * 0.2);
            ctx.fill();
        }
    }

    function label(ctx, text, x, y, color) {
        ctx.fillStyle = color;
        ctx.font = "bold 8px sans-serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillText(text, x, y);
    }

    function sun(ctx, x, y) {
        circle(ctx, x, y, 11, "rgba(255,211,110,0.95)");
        ctx.strokeStyle = "rgba(255,211,110,0.7)";
        ctx.lineWidth = 2;
        ctx.lineCap = "round";
        for (var i = 0; i < 8; i++) {
            var a = i * Math.PI / 4;
            ctx.beginPath();
            ctx.moveTo(x + Math.cos(a) * 15, y + Math.sin(a) * 15);
            ctx.lineTo(x + Math.cos(a) * 19, y + Math.sin(a) * 19);
            ctx.stroke();
        }
    }

    function drawKita(ctx) {
        sun(ctx, 172, 26);
        rr(ctx, 50, 62, 100, 78, 8, "rgba(251,227,200,1)");
        ctx.fillStyle = "rgba(244,166,166,1)";
        ctx.beginPath();
        ctx.moveTo(38, 68); ctx.lineTo(100, 20); ctx.lineTo(162, 68);
        ctx.closePath();
        ctx.fill();
        // Wimpelkette
        var cols = ["rgba(169,214,160,1)", "rgba(159,199,240,1)", "rgba(255,211,110,1)", "rgba(200,178,232,1)"];
        for (var i = 0; i < 6; i++) {
            ctx.fillStyle = cols[i % 4];
            ctx.beginPath();
            ctx.moveTo(58 + i * 14, 70); ctx.lineTo(70 + i * 14, 70); ctx.lineTo(64 + i * 14, 79);
            ctx.closePath();
            ctx.fill();
        }
        // Fenster mit Pet
        circle(ctx, 72, 96, 13, "rgba(207,232,247,1)");
        ctx.save();
        ctx.beginPath(); ctx.arc(72, 96, 13, 0, Math.PI * 2); ctx.clip();
        petHead(ctx, 72, 104, 10, false);
        ctx.restore();
        circle(ctx, 128, 96, 13, "rgba(207,232,247,1)");
        rr(ctx, 89, 104, 22, 36, 6, "rgba(201,142,122,1)");
        circle(ctx, 106, 123, 1.8, "rgba(255,230,180,1)");
        rr(ctx, 80, 40, 40, 13, 4, "rgba(255,255,255,0.9)");
        label(ctx, "KITA", 100, 46.5, "rgba(214,110,120,1)");
    }

    function drawSchool(ctx) {
        sun(ctx, 176, 24);
        rr(ctx, 32, 62, 136, 78, 6, "rgba(230,224,245,1)");
        rr(ctx, 28, 56, 144, 10, 4, "rgba(176,160,214,1)");
        rr(ctx, 84, 26, 32, 34, 4, "rgba(230,224,245,1)");
        ctx.fillStyle = "rgba(176,160,214,1)";
        ctx.beginPath();
        ctx.moveTo(80, 28); ctx.lineTo(100, 10); ctx.lineTo(120, 28);
        ctx.closePath();
        ctx.fill();
        // Uhr
        circle(ctx, 100, 42, 9, "rgba(255,255,255,1)");
        ctx.strokeStyle = "rgba(90,80,100,0.9)";
        ctx.lineWidth = 1.5;
        ctx.lineCap = "round";
        ctx.beginPath();
        ctx.moveTo(100, 42); ctx.lineTo(100, 36);
        ctx.moveTo(100, 42); ctx.lineTo(104, 44);
        ctx.stroke();
        // Fahne
        ctx.strokeStyle = "rgba(120,110,130,1)";
        ctx.beginPath(); ctx.moveTo(100, 10); ctx.lineTo(100, 0); ctx.stroke();
        ctx.fillStyle = "rgba(240,140,164,1)";
        ctx.beginPath(); ctx.moveTo(100, 0); ctx.lineTo(110, 3); ctx.lineTo(100, 6); ctx.closePath(); ctx.fill();
        // Fenster
        var wins = [[42, 74], [64, 74], [118, 74], [140, 74]];
        for (var i = 0; i < wins.length; i++) rr(ctx, wins[i][0], wins[i][1], 18, 22, 4, "rgba(207,232,247,1)");
        ctx.save();
        ctx.beginPath(); ctx.roundedRect(64, 74, 18, 22, 4, 4); ctx.clip();
        petHead(ctx, 73, 92, 8, false);
        ctx.restore();
        rr(ctx, 88, 102, 24, 38, 5, "rgba(176,140,120,1)");
        rr(ctx, 76, 64, 48, 12, 4, "rgba(255,255,255,0.9)");
        label(ctx, "SCHULE", 100, 70, "rgba(120,100,170,1)");
    }

    function drawWork(ctx) {
        rr(ctx, 40, 58, 120, 82, 6, "rgba(253,243,231,1)");
        // Markise
        for (var i = 0; i < 8; i++) {
            ctx.fillStyle = i % 2 ? "rgba(255,255,255,1)" : "rgba(244,166,166,1)";
            ctx.fillRect(36 + i * 16, 50, 16, 14);
            ctx.beginPath();
            ctx.arc(44 + i * 16, 64, 8, 0, Math.PI);
            ctx.fill();
        }
        // Schaufenster mit Pet hinter der Theke
        rr(ctx, 50, 78, 100, 44, 6, "rgba(215,238,245,1)");
        ctx.save();
        ctx.beginPath(); ctx.roundedRect(50, 78, 100, 44, 6, 6); ctx.clip();
        petHead(ctx, 100, 104, 15, false);
        ctx.restore();
        rr(ctx, 46, 112, 108, 10, 3, "rgba(201,162,126,1)");
        // Becher auf der Theke
        ctx.fillStyle = "rgba(200,178,232,1)";
        ctx.beginPath();
        ctx.moveTo(126, 98); ctx.lineTo(138, 98); ctx.lineTo(136, 112); ctx.lineTo(128, 112);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = "rgba(240,140,164,1)";
        ctx.lineWidth = 2;
        ctx.beginPath(); ctx.moveTo(133, 98); ctx.lineTo(135, 91); ctx.stroke();
        // Schild
        rr(ctx, 62, 24, 76, 20, 8, "rgba(255,255,255,0.95)");
        label(ctx, "BUBBLE TEA", 100, 34, "rgba(200,110,130,1)");
        rr(ctx, 40, 122, 120, 18, 0, "rgba(253,243,231,1)");
    }

    function drawRelax(ctx) {
        sun(ctx, 176, 26);
        // Sonnenschirm
        ctx.strokeStyle = "rgba(170,150,140,1)";
        ctx.lineWidth = 3;
        ctx.lineCap = "round";
        ctx.beginPath(); ctx.moveTo(62, 50); ctx.lineTo(62, 140); ctx.stroke();
        for (var i = 0; i < 6; i++) {
            ctx.fillStyle = i % 2 ? "rgba(255,255,255,1)" : "rgba(159,199,240,1)";
            ctx.beginPath();
            ctx.moveTo(62, 50);
            ctx.arc(62, 50, 46, Math.PI + i * Math.PI / 6, Math.PI + (i + 1) * Math.PI / 6);
            ctx.closePath();
            ctx.fill();
        }
        // Liegestuhl: Beine, dann gestreifter Stoff (Rückenlehne + Sitz)
        ctx.strokeStyle = "rgba(190,150,110,1)";
        ctx.lineWidth = 3;
        ctx.lineCap = "round";
        ctx.beginPath();
        ctx.moveTo(104, 140); ctx.lineTo(116, 122);
        ctx.moveTo(126, 122); ctx.lineTo(114, 140);
        ctx.moveTo(150, 128); ctx.lineTo(158, 140);
        ctx.stroke();
        var cloth = function (x1, y1, x2, y2, n) {
            var dx = (x2 - x1) / n, dy = (y2 - y1) / n;
            for (var k = 0; k < n; k++) {
                ctx.strokeStyle = k % 2 ? "rgba(255,255,255,1)" : "rgba(244,166,166,1)";
                ctx.lineWidth = 9;
                ctx.lineCap = "butt";
                ctx.beginPath();
                ctx.moveTo(x1 + dx * k, y1 + dy * k);
                ctx.lineTo(x1 + dx * (k + 1), y1 + dy * (k + 1));
                ctx.stroke();
            }
        };
        cloth(104, 92, 118, 122, 3);
        cloth(118, 122, 158, 126, 4);
        // Pet liegt darauf: Körper auf dem Sitz, Kopf an der Lehne
        ctx.save();
        ctx.translate(136, 117);
        ctx.rotate(0.08);
        ctx.fillStyle = hsl(hue, 0.55, 0.74);
        ctx.beginPath();
        ctx.ellipse(-20, -7, 40, 14);
        ctx.fill();
        ctx.restore();
        petHead(ctx, 113, 100, 14, true);
        ctx.fillStyle = "rgba(60,55,70,0.9)";
        ctx.beginPath(); ctx.ellipse(101, 95, 9, 6); ctx.fill();
        ctx.beginPath(); ctx.ellipse(113, 95, 9, 6); ctx.fill();
        ctx.fillRect(109, 97, 5, 1.5);
        // Getränk
        rr(ctx, 168, 120, 22, 4, 2, "rgba(190,150,110,1)");
        ctx.strokeStyle = "rgba(190,150,110,1)";
        ctx.lineWidth = 2;
        ctx.beginPath(); ctx.moveTo(179, 124); ctx.lineTo(179, 140); ctx.stroke();
        ctx.fillStyle = "rgba(255,190,120,1)";
        ctx.beginPath();
        ctx.moveTo(172, 106); ctx.lineTo(186, 106); ctx.lineTo(183, 120); ctx.lineTo(175, 120);
        ctx.closePath();
        ctx.fill();
        ctx.strokeStyle = "rgba(240,140,164,1)";
        ctx.beginPath(); ctx.moveTo(181, 106); ctx.lineTo(184, 98); ctx.stroke();
        // Wellen
        ctx.strokeStyle = "rgba(159,199,240,0.8)";
        ctx.lineWidth = 2;
        for (var w = 0; w < 2; w++) {
            ctx.beginPath();
            for (var x = 0; x <= 200; x += 10) {
                var yy = 146 - w * 5 + (x / 10 % 2 ? -1.5 : 1.5);
                if (x === 0) ctx.moveTo(x, yy); else ctx.lineTo(x, yy);
            }
            ctx.stroke();
        }
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        if (width <= 0 || height <= 0) return;
        var k = Math.min(width / 200, height / 150);
        ctx.translate((width - 200 * k) / 2, height - 150 * k);
        ctx.scale(k, k);
        if (place === "kita") drawKita(ctx);
        else if (place === "school") drawSchool(ctx);
        else if (place === "work") drawWork(ctx);
        else drawRelax(ctx);
    }
}
