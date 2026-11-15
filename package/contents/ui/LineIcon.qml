import QtQuick

// Minimalistische Linien-Icons im 24er-Raster.
Canvas {
    id: icon

    property string name: "more"
    property color color: "#444"
    property color accent: "#f2b84b"

    implicitWidth: 18
    implicitHeight: 18
    antialiasing: true
    Accessible.ignored: true

    onNameChanged: requestPaint()
    onColorChanged: requestPaint()
    onAccentChanged: requestPaint()
    onWidthChanged: requestPaint()

    function rgba(c, a) {
        return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + (a === undefined ? c.a : a) + ")";
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        if (width <= 0) return;
        ctx.scale(width / 24, height / 24);
        ctx.lineWidth = 1.8;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        var c = rgba(color), a = rgba(accent);
        ctx.strokeStyle = c;
        ctx.fillStyle = c;
        var i;
        switch (name) {
        case "feed":      // Onigiri
            ctx.beginPath();
            ctx.moveTo(12, 4);
            ctx.quadraticCurveTo(13.5, 4, 19.5, 15);
            ctx.quadraticCurveTo(21, 19.5, 16, 19.5);
            ctx.lineTo(8, 19.5);
            ctx.quadraticCurveTo(3, 19.5, 4.5, 15);
            ctx.quadraticCurveTo(10.5, 4, 12, 4);
            ctx.stroke();
            ctx.beginPath();
            ctx.roundedRect(9, 14, 6, 5.5, 1, 1);
            ctx.fill();
            break;
        case "play":      // Gamepad
            ctx.beginPath();
            ctx.roundedRect(3, 7.5, 18, 10, 5, 5);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(8, 10.5); ctx.lineTo(8, 14.5);
            ctx.moveTo(6, 12.5); ctx.lineTo(10, 12.5);
            ctx.stroke();
            ctx.beginPath(); ctx.arc(15.5, 11.5, 1.1, 0, Math.PI * 2); ctx.fill();
            ctx.beginPath(); ctx.arc(17.5, 13.8, 1.1, 0, Math.PI * 2); ctx.fill();
            break;
        case "clean":     // Funkeln
            ctx.beginPath();
            ctx.moveTo(10, 3); ctx.quadraticCurveTo(10.6, 9.4, 17, 10);
            ctx.quadraticCurveTo(10.6, 10.6, 10, 17);
            ctx.quadraticCurveTo(9.4, 10.6, 3, 10);
            ctx.quadraticCurveTo(9.4, 9.4, 10, 3);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(18, 14.5); ctx.lineTo(18, 20.5);
            ctx.moveTo(15, 17.5); ctx.lineTo(21, 17.5);
            ctx.stroke();
            break;
        case "heal":      // Kapsel
            ctx.save();
            ctx.translate(12, 12);
            ctx.rotate(-Math.PI / 4);
            ctx.beginPath();
            ctx.roundedRect(-9, -4, 18, 8, 4, 4);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(0, -4); ctx.lineTo(0, 4);
            ctx.stroke();
            ctx.beginPath();
            ctx.roundedRect(-9, -4, 9, 8, 4, 4);
            ctx.fillStyle = rgba(color, 0.35);
            ctx.fill();
            ctx.restore();
            break;
        case "more":
            for (i = 0; i < 3; i++) { ctx.beginPath(); ctx.arc(6 + i * 6, 12, 1.6, 0, Math.PI * 2); ctx.fill(); }
            break;
        case "tree":      // Stammbaum
            ctx.beginPath(); ctx.arc(12, 5.5, 2.6, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath(); ctx.arc(6, 18.5, 2.6, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath(); ctx.arc(18, 18.5, 2.6, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(12, 8.1); ctx.lineTo(12, 12); ctx.lineTo(6, 12); ctx.lineTo(6, 15.9);
            ctx.moveTo(12, 12); ctx.lineTo(18, 12); ctx.lineTo(18, 15.9);
            ctx.stroke();
            break;
        case "info":
            ctx.beginPath(); ctx.arc(12, 12, 8.5, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(12, 11); ctx.lineTo(12, 16.5); ctx.stroke();
            ctx.beginPath(); ctx.arc(12, 7.8, 1.1, 0, Math.PI * 2); ctx.fill();
            break;
        case "restart":
            ctx.beginPath(); ctx.arc(12, 12, 7.5, -Math.PI * 0.35, Math.PI * 1.45); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(16.5, 3.5); ctx.lineTo(16.7, 7.3); ctx.lineTo(12.9, 7.6); ctx.stroke();
            break;
        case "close":
            ctx.beginPath(); ctx.moveTo(6.5, 6.5); ctx.lineTo(17.5, 17.5); ctx.moveTo(17.5, 6.5); ctx.lineTo(6.5, 17.5); ctx.stroke();
            break;
        case "back":
            ctx.beginPath(); ctx.moveTo(14.5, 5.5); ctx.lineTo(8, 12); ctx.lineTo(14.5, 18.5); ctx.stroke();
            break;
        case "lock":
            ctx.beginPath(); ctx.roundedRect(5.5, 11, 13, 9, 2.5, 2.5); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(8.5, 11); ctx.lineTo(8.5, 8); ctx.arc(12, 8, 3.5, Math.PI, 0); ctx.lineTo(15.5, 11); ctx.stroke();
            break;
        case "moon":
            ctx.beginPath();
            ctx.arc(12, 12, 8, Math.PI * 0.35, Math.PI * 1.65);
            ctx.quadraticCurveTo(10, 12, 17.5, 17.8);
            ctx.fill();
            break;
        case "coin":
            ctx.fillStyle = a;
            ctx.beginPath(); ctx.arc(12, 12, 9, 0, Math.PI * 2); ctx.fill();
            ctx.fillStyle = "rgba(255,255,255,0.75)";
            ctx.beginPath();
            ctx.moveTo(12, 6.5); ctx.lineTo(16, 12); ctx.lineTo(12, 17.5); ctx.lineTo(8, 12);
            ctx.closePath(); ctx.fill();
            break;
        case "heart":
            ctx.fillStyle = a;
            ctx.beginPath();
            ctx.moveTo(12, 20);
            ctx.bezierCurveTo(2, 13, 4, 4, 12, 8.5);
            ctx.bezierCurveTo(20, 4, 22, 13, 12, 20);
            ctx.fill();
            break;
        case "hunger":
            ctx.beginPath(); ctx.arc(12, 12, 7.5, 0, Math.PI); ctx.closePath(); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(9, 4.5); ctx.quadraticCurveTo(7.5, 6.5, 9, 8.5); ctx.moveTo(14, 4.5); ctx.quadraticCurveTo(12.5, 6.5, 14, 8.5); ctx.stroke();
            break;
        case "fun":
            ctx.beginPath(); ctx.arc(12, 12, 8.5, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath(); ctx.arc(12, 12.5, 4.5, Math.PI * 0.15, Math.PI * 0.85); ctx.stroke();
            ctx.beginPath(); ctx.arc(9, 10, 1.1, 0, Math.PI * 2); ctx.fill();
            ctx.beginPath(); ctx.arc(15, 10, 1.1, 0, Math.PI * 2); ctx.fill();
            break;
        case "health":
            ctx.beginPath();
            ctx.moveTo(12, 20);
            ctx.bezierCurveTo(2, 13, 4, 4, 12, 8.5);
            ctx.bezierCurveTo(20, 4, 22, 13, 12, 20);
            ctx.stroke();
            break;
        case "poop":
            ctx.fillStyle = a;
            ctx.beginPath(); ctx.ellipse(3.5, 14.5, 17, 7); ctx.fill();
            ctx.beginPath(); ctx.ellipse(6, 9.5, 12, 6.5); ctx.fill();
            ctx.beginPath(); ctx.ellipse(8.5, 5, 7, 5.5); ctx.fill();
            ctx.beginPath(); ctx.moveTo(12, 5); ctx.quadraticCurveTo(14, 2, 15, 3); ctx.lineTo(13.5, 5.5); ctx.fill();
            ctx.fillStyle = "rgba(255,255,255,0.35)";
            ctx.beginPath(); ctx.ellipse(6.5, 15.5, 5, 2.2); ctx.fill();
            ctx.fillStyle = "rgba(60,40,50,0.9)";
            ctx.beginPath(); ctx.arc(10, 12, 0.9, 0, Math.PI * 2); ctx.fill();
            ctx.beginPath(); ctx.arc(14, 12, 0.9, 0, Math.PI * 2); ctx.fill();
            break;
        case "paw":       // Pfote als eigener Mauszeiger
            ctx.fillStyle = a;
            ctx.strokeStyle = "rgba(255,255,255,0.95)";
            ctx.lineWidth = 1.4;
            var toes = [[6.2, 9.2, 2.3], [10, 6.2, 2.5], [14.6, 6.4, 2.5], [18.2, 9.6, 2.3]];
            for (i = 0; i < toes.length; i++) {
                ctx.beginPath();
                ctx.ellipse(toes[i][0] - toes[i][2], toes[i][1] - toes[i][2] * 1.2, toes[i][2] * 2, toes[i][2] * 2.4);
                ctx.fill();
                ctx.stroke();
            }
            ctx.beginPath();
            ctx.moveTo(12.2, 11);
            ctx.bezierCurveTo(17.5, 11, 19.5, 17.5, 16.8, 19.6);
            ctx.bezierCurveTo(14.8, 21.2, 13.4, 19.8, 12.2, 19.8);
            ctx.bezierCurveTo(11, 19.8, 9.6, 21.2, 7.6, 19.6);
            ctx.bezierCurveTo(4.9, 17.5, 6.9, 11, 12.2, 11);
            ctx.fill();
            ctx.stroke();
            break;
        case "star":
            ctx.fillStyle = a;
            ctx.beginPath();
            for (i = 0; i < 10; i++) {
                var ang = -Math.PI / 2 + i * Math.PI / 5, r = i % 2 ? 4 : 9;
                if (i === 0) ctx.moveTo(12 + Math.cos(ang) * r, 12 + Math.sin(ang) * r);
                else ctx.lineTo(12 + Math.cos(ang) * r, 12 + Math.sin(ang) * r);
            }
            ctx.closePath(); ctx.fill();
            break;
        }
    }
}
