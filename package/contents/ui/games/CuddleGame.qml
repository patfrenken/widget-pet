import QtQuick
import org.kde.kirigami as Kirigami
import ".."

// Minispiel 1: Kuscheln – über das Pet streichen, Kitzelstellen finden.
Item {
    id: game

    required property var petModel
    property bool running: false
    property int hearts: 0
    property real timeLeft: 15
    property real dist: 0
    property real lastX: -1
    property real lastY: -1
    property bool rubbing: false
    property bool dizzy: false
    property real speed: 0          // geglättete Streichelgeschwindigkeit in px/s
    property real travel: 0         // gesamte Streichelstrecke für die Geschwindigkeitsmessung
    property var trail: []          // [{t, d}] der letzten 250 ms
    property real pawX: -100
    property real pawY: -100

    readonly property real wildSpeed: 1100

    readonly property real duration: 15
    readonly property color fg: Kirigami.Theme.textColor

    signal finished(int score, int coins, int funBase)

    function start() {
        hearts = 0;
        timeLeft = duration;
        dist = 0;
        lastX = -1;
        speed = 0;
        travel = 0;
        trail = [];
        dizzy = false;
        running = true;
        moveSpot();
    }

    function moveSpot() {
        var r = pet.width * 0.22;
        spot.x = pet.x + pet.width / 2 + (Math.random() * 2 - 1) * r - spot.width / 2;
        spot.y = pet.y + pet.height * 0.62 + (Math.random() * 2 - 1) * r * 0.7 - spot.height / 2;
        spotTimer.restart();
    }

    function addHearts(n, px, py) {
        hearts += n;
        for (var i = 0; i < Math.min(n, 3); i++)
            heartComp.createObject(game, { x: px - 10 + (i - 1) * 14, y: py - 10 });
    }

    // Kopf: Zeit & Herzen
    Rectangle {
        id: timeBar
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 6
        radius: 3
        color: Qt.rgba(game.fg.r, game.fg.g, game.fg.b, 0.1)
        Rectangle {
            width: parent.width * game.timeLeft / game.duration
            height: parent.height
            radius: 3
            color: "#f08ca4"
        }
    }

    Row {
        anchors { top: timeBar.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter }
        spacing: 6
        LineIcon { width: 22; height: 22; name: "heart"; accent: "#f08ca4" }
        Text { text: game.hearts; color: game.fg; font.pixelSize: 20; font.weight: Font.Bold }
    }

    PetCanvas {
        id: pet
        width: Math.min(parent.width, parent.height) * 0.8
        height: width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        species: game.petModel.species
        hue: game.petModel.hue
        senior: game.petModel.senior
        expression: game.dizzy ? "sick" : (game.rubbing ? "love" : (game.running ? "happy" : "neutral"))
        transform: Scale { id: wiggle; origin.x: pet.width / 2; origin.y: pet.height * 0.93 }
    }

    LineIcon {
        id: spot
        visible: game.running
        width: 34
        height: 34
        name: "star"
        accent: "#ffd36e"
        SequentialAnimation on scale {
            running: spot.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0.7; to: 1.1; duration: 450; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.1; to: 0.7; duration: 450; easing.type: Easing.InOutSine }
        }
    }

    // Fängt die Maus im ganzen Spielbereich: Systemzeiger ausblenden, Pfote zeigen.
    // So kann „Zeiger schütteln zum Finden“ (Plasma/macOS) nichts vergrößern.
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: game.running ? Qt.BlankCursor : Qt.ArrowCursor
        onPositionChanged: mouse => {
            game.pawX = mouse.x;
            game.pawY = mouse.y;
            if (!game.running) return;
            var now = Date.now();
            var gx = mouse.x, gy = mouse.y;
            var onPet = Math.hypot(gx - (pet.x + pet.width / 2), gy - (pet.y + pet.height * 0.62)) < pet.width * 0.42;
            if (game.lastX >= 0 && onPet) {
                var d = Math.hypot(gx - game.lastX, gy - game.lastY);
                game.travel += d;
                var tr = game.trail.filter(p => now - p.t <= 250);
                tr.push({ t: now, d: game.travel });
                game.trail = tr;
                var span = Math.max(120, now - tr[0].t) / 1000;
                game.speed = (game.travel - tr[0].d) / span;
                if (game.speed > game.wildSpeed) {
                    game.dizzy = true;
                    game.rubbing = false;
                    dizzyOff.restart();
                } else if (!game.dizzy) {
                    game.dist += d;
                    game.rubbing = true;
                    rubOff.restart();
                }
            }
            game.lastX = onPet ? gx : -1;
            game.lastY = gy;
            if (!onPet || game.dizzy) return;
            var sx = spot.x + spot.width / 2, sy = spot.y + spot.height / 2;
            if (Math.hypot(gx - sx, gy - sy) < spot.width * 0.9) {
                game.addHearts(3, sx, sy);
                wiggleAnim.restart();
                game.moveSpot();
            }
            while (game.dist >= 70) {
                game.dist -= 70;
                game.addHearts(1, gx, gy);
            }
        }
        onExited: { game.lastX = -1; game.pawX = -100; }
    }

    LineIcon {
        visible: game.running && area.containsMouse
        x: game.pawX - width / 2
        y: game.pawY - height / 2
        width: 30
        height: 30
        name: "paw"
        accent: "#f08ca4"
        rotation: -15
        z: 10
    }

    Text {
        visible: game.dizzy
        anchors { top: pet.top; horizontalCenter: pet.horizontalCenter; topMargin: pet.height * 0.08 }
        text: qsTr("Sanfter, mir wird schwindelig!")
        color: "#c46a6a"
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    Timer { id: dizzyOff; interval: 900; onTriggered: { game.dizzy = false; game.speed = 0; game.trail = []; } }
    Timer { id: rubOff; interval: 260; onTriggered: game.rubbing = false }
    Timer { id: spotTimer; interval: 2600; repeat: true; running: game.running; onTriggered: game.moveSpot() }

    Timer {
        interval: 100
        repeat: true
        running: game.running
        onTriggered: {
            game.timeLeft = Math.max(0, game.timeLeft - 0.1);
            if (game.timeLeft <= 0) {
                game.running = false;
                game.rubbing = false;
                game.dizzy = false;
                game.finished(game.hearts, Math.min(15, Math.floor(game.hearts / 5)), Math.min(30, 10 + Math.round(game.hearts / 2)));
            }
        }
    }

    SequentialAnimation {
        id: wiggleAnim
        NumberAnimation { target: wiggle; property: "xScale"; to: 1.08; duration: 90 }
        NumberAnimation { target: wiggle; property: "xScale"; to: 0.95; duration: 90 }
        NumberAnimation { target: wiggle; property: "xScale"; to: 1.0; duration: 120 }
    }

    Component {
        id: heartComp
        LineIcon {
            id: h
            width: 22
            height: 22
            name: "heart"
            accent: "#f08ca4"
            ParallelAnimation {
                running: true
                NumberAnimation { target: h; property: "y"; to: h.y - 70; duration: 800; easing.type: Easing.OutQuad }
                NumberAnimation { target: h; property: "opacity"; to: 0; duration: 800; easing.type: Easing.InQuad }
                onFinished: h.destroy()
            }
        }
    }
}
