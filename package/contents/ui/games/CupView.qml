import QtQuick

// Bubble-Tea-Becher: Basis, Topping, optional Sahnehaube.
Canvas {
    id: cup

    property string base: ""
    property string topping: ""
    property bool cream: false

    readonly property var baseColors: ({ matcha: "#a9d6a0", taro: "#c8b2e8", mango: "#f6c47a", milk: "#ecdcc4" })

    antialiasing: true
    Accessible.ignored: true

    onBaseChanged: requestPaint()
    onToppingChanged: requestPaint()
    onCreamChanged: requestPaint()
    onWidthChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        var w = width, h = height;
        if (w <= 0) return;
        var top = h * 0.22, bot = h * 0.97, lt = w * 0.18, rt = w * 0.82, lb = w * 0.27, rb = w * 0.73;
        var cupPath = function () {
            ctx.beginPath();
            ctx.moveTo(lt, top);
            ctx.lineTo(rt, top);
            ctx.lineTo(rb, bot - h * 0.04);
            ctx.quadraticCurveTo(rb, bot, rb - w * 0.05, bot);
            ctx.lineTo(lb + w * 0.05, bot);
            ctx.quadraticCurveTo(lb, bot, lb, bot - h * 0.04);
            ctx.closePath();
        };
        // Strohhalm
        ctx.strokeStyle = "rgba(240,140,164,0.95)";
        ctx.lineWidth = w * 0.07;
        ctx.lineCap = "round";
        ctx.beginPath();
        ctx.moveTo(w * 0.56, h * 0.88);
        ctx.lineTo(w * 0.64, h * 0.04);
        ctx.stroke();

        ctx.save();
        cupPath();
        ctx.clip();
        ctx.fillStyle = "rgba(255,255,255,0.55)";
        ctx.fillRect(0, 0, w, h);
        if (base !== "") {
            ctx.fillStyle = baseColors[base];
            ctx.fillRect(0, top + h * 0.10, w, h);
        }
        var i;
        if (topping === "pearls") {
            ctx.fillStyle = "rgba(78,60,72,0.95)";
            for (i = 0; i < 9; i++) {
                ctx.beginPath();
                ctx.arc(w * (0.34 + (i % 5) * 0.08), bot - h * (0.06 + Math.floor(i / 5) * 0.08) - (i % 2) * h * 0.02, w * 0.045, 0, Math.PI * 2);
                ctx.fill();
            }
        } else if (topping === "jelly") {
            ctx.fillStyle = "rgba(242,128,160,0.9)";
            for (i = 0; i < 6; i++) {
                ctx.save();
                ctx.translate(w * (0.36 + (i % 3) * 0.13), bot - h * (0.08 + Math.floor(i / 3) * 0.10));
                ctx.rotate(0.3 * (i % 2 ? 1 : -1));
                ctx.fillRect(-w * 0.045, -w * 0.045, w * 0.09, w * 0.09);
                ctx.restore();
            }
        }
        ctx.restore();

        if (cream) {
            ctx.fillStyle = "rgba(255,252,246,1)";
            ctx.beginPath();
            ctx.arc(w * 0.36, top + h * 0.02, w * 0.14, Math.PI, 0);
            ctx.arc(w * 0.5, top - h * 0.03, w * 0.15, Math.PI, 0);
            ctx.arc(w * 0.64, top + h * 0.02, w * 0.14, Math.PI, 0);
            ctx.closePath();
            ctx.fill();
            ctx.fillRect(lt, top - h * 0.01, rt - lt, h * 0.04);
        }

        cupPath();
        ctx.strokeStyle = "rgba(90,80,100,0.35)";
        ctx.lineWidth = Math.max(1.2, w * 0.025);
        ctx.lineJoin = "round";
        ctx.stroke();
        ctx.fillStyle = "rgba(255,255,255,0.35)";
        ctx.fillRect(lt + w * 0.06, top + h * 0.06, w * 0.05, h * 0.55);
    }
}
