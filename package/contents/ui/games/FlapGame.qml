import QtQuick
import org.kde.kirigami as Kirigami
import ".."

// Minispiel 2: Hüpfflug – durch Wolkentürme flattern.
Item {
    id: game

    required property var petModel
    property bool running: false
    property bool waiting: false
    property int score: 0
    property int stars: 0
    property real py: 0
    property real vy: 0
    property real speed: 140
    property var pipes: []
    property real lastTime: 0

    readonly property real pipeW: 58
    readonly property real spacing: 210
    readonly property real playerX: width * 0.24
    readonly property real playerR: 16
    readonly property real groundH: 34
    readonly property real gap: Math.max(122, 172 - score * 2.5)
    readonly property color fg: Kirigami.Theme.textColor
    readonly property color pipeColor: Qt.hsla(((game.petModel.hue + 140) % 360) / 360, 0.45, 0.80, 1)

    signal finished(int score, int coins, int funBase)

    clip: true
    focus: true

    function randomGapY() {
        var h = Math.max(height, 400) - groundH;
        return 70 + Math.random() * (h - 140);
    }

    function start() {
        score = 0;
        stars = 0;
        speed = 140;
        py = Math.max(height, 400) * 0.42;
        vy = 0;
        var arr = [];
        for (var i = 0; i < 4; i++) arr.push({ x: Math.max(width, 360) + 60 + i * spacing, gapY: randomGapY(), passed: false, star: Math.random() < 0.5 });
        pipes = arr;
        sync();
        waiting = true;
        running = true;
        lastTime = Date.now();
    }

    function flap() {
        if (!running) return;
        waiting = false;
        vy = -390;
        flapAnim.restart();
    }

    function sync() {
        for (var i = 0; i < pipes.length; i++) {
            var it = pipeRepeater.itemAt(i);
            if (!it) continue;
            it.x = pipes[i].x;
            it.gapY = pipes[i].gapY;
            it.hasStar = pipes[i].star;
        }
    }

    function crash() {
        running = false;
        crashTimer.start();
    }

    function stepFrame() {
        var now = Date.now();
        var dt = Math.min(0.035, (now - lastTime) / 1000);
        lastTime = now;
        if (waiting) return;
        vy += 1250 * dt;
        py += vy * dt;
        speed = Math.min(235, speed + 2.2 * dt);
        if (py < playerR) { py = playerR; vy = 0; }
        if (py + playerR > height - groundH) { py = height - groundH - playerR; crash(); return; }
        for (var i = 0; i < pipes.length; i++) {
            var p = pipes[i];
            p.x -= speed * dt;
            if (p.x < -pipeW) {
                var maxX = 0;
                for (var j = 0; j < pipes.length; j++) maxX = Math.max(maxX, pipes[j].x);
                p.x = maxX + spacing;
                p.gapY = randomGapY();
                p.passed = false;
                p.star = Math.random() < 0.45;
            }
            if (!p.passed && p.x + pipeW < playerX - playerR) { p.passed = true; score++; }
            if (playerX + playerR > p.x + 4 && playerX - playerR < p.x + pipeW - 4) {
                if (py - playerR < p.gapY - gap / 2 || py + playerR > p.gapY + gap / 2) { crash(); }
            }
            if (p.star && Math.hypot(playerX - (p.x + pipeW / 2), py - p.gapY) < playerR + 14) {
                p.star = false;
                stars++;
            }
        }
        sync();
    }

    Keys.onSpacePressed: flap()
    Keys.onUpPressed: flap()

    // Himmel
    Rectangle {
        anchors.fill: parent
        radius: 14
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.hsla(((game.petModel.hue + 180) % 360) / 360, 0.55, 0.90, 1) }
            GradientStop { position: 1; color: Qt.hsla(((game.petModel.hue + 200) % 360) / 360, 0.45, 0.96, 1) }
        }
    }

    Repeater {
        model: 4
        delegate: Rectangle {
            required property int index
            width: 70 + index * 18
            height: width * 0.38
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.65)
            y: 40 + index * 85
            NumberAnimation on x {
                running: game.running && !game.waiting
                loops: Animation.Infinite
                from: game.width + 40 + index * 60
                to: -160
                duration: 14000 + index * 3500
            }
        }
    }

    Repeater {
        id: pipeRepeater
        model: 4
        delegate: Item {
            property real gapY: 200
            property bool hasStar: false
            width: game.pipeW
            height: game.height

            Rectangle {
                width: parent.width
                y: -20
                height: parent.gapY - game.gap / 2 + 20
                radius: 16
                color: game.pipeColor
                Rectangle { width: parent.width * 0.22; height: parent.height - 30; x: 8; y: 20; radius: width / 2; color: Qt.rgba(1, 1, 1, 0.35) }
            }
            Rectangle {
                width: parent.width
                y: parent.gapY + game.gap / 2
                height: game.height - y + 20
                radius: 16
                color: game.pipeColor
                Rectangle { width: parent.width * 0.22; height: parent.height - 40; x: 8; y: 10; radius: width / 2; color: Qt.rgba(1, 1, 1, 0.35) }
            }
            LineIcon {
                visible: parent.hasStar
                width: 26
                height: 26
                x: (parent.width - width) / 2
                y: parent.gapY - height / 2
                name: "star"
                accent: "#ffcf5c"
            }
        }
    }

    // Boden
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: game.groundH
        radius: 14
        color: Qt.hsla(((game.petModel.hue + 90) % 360) / 360, 0.35, 0.78, 1)
    }

    PetCanvas {
        id: player
        width: game.playerR * 3.4
        height: width
        x: game.playerX - width / 2
        y: game.py - height * 0.62
        species: game.petModel.species
        hue: game.petModel.hue
        expression: game.running ? (game.vy < -100 ? "happy" : "neutral") : "sad"
        rotation: Math.max(-20, Math.min(55, game.vy * 0.07))
        transform: Scale { id: flapScale; origin.x: player.width / 2; origin.y: player.height / 2 }
    }

    Text {
        anchors { top: parent.top; topMargin: 14; horizontalCenter: parent.horizontalCenter }
        text: game.score
        color: "white"
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.18)
        font.pixelSize: 42
        font.weight: Font.Black
    }

    Row {
        anchors { top: parent.top; right: parent.right; margins: 14 }
        spacing: 4
        LineIcon { width: 18; height: 18; name: "star"; accent: "#ffcf5c" }
        Text { text: game.stars; color: game.fg; font.weight: Font.DemiBold }
    }

    Text {
        visible: game.waiting
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 70
        text: qsTr("Klick oder Leertaste")
        color: game.fg
        opacity: 0.6
    }

    MouseArea {
        anchors.fill: parent
        onPressed: game.flap()
    }

    SequentialAnimation {
        id: flapAnim
        NumberAnimation { target: flapScale; property: "yScale"; to: 0.85; duration: 70 }
        NumberAnimation { target: flapScale; property: "yScale"; to: 1.0; duration: 120; easing.type: Easing.OutBack }
    }

    Timer {
        interval: 16
        repeat: true
        running: game.running
        onTriggered: game.stepFrame()
    }

    Timer {
        id: crashTimer
        interval: 700
        onTriggered: game.finished(game.score, game.score + game.stars * 2, Math.min(30, 8 + game.score * 2))
    }
}
