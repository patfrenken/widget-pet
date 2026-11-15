import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import ".."
import "../logic.js" as Logic

// Minispiel 3: Bubble-Tea-Bar – 60 Sekunden Schicht.
Item {
    id: game

    required property var petModel
    property bool running: false
    property real elapsed: 0
    property int served: 0
    property int tips: 0
    property int combo: 0
    property var customers: [null, null, null]
    property int rev: 0
    property string cupBase: ""
    property string cupTopping: ""
    property bool cupCream: false
    property string flash: ""

    readonly property real duration: 60
    readonly property color fg: Kirigami.Theme.textColor
    readonly property var bases: [
        { id: "matcha", label: qsTr("Matcha"), color: "#a9d6a0" },
        { id: "taro", label: qsTr("Taro"), color: "#c8b2e8" },
        { id: "mango", label: qsTr("Mango"), color: "#f6c47a" },
        { id: "milk", label: qsTr("Milchtee"), color: "#ecdcc4" }
    ]
    readonly property var toppings: [
        { id: "pearls", label: qsTr("Perlen"), color: "#8a7280" },
        { id: "jelly", label: qsTr("Jelly"), color: "#f4a3bb" }
    ]
    readonly property var guestSpecies: ["mochi", "tropf", "funkel", "knuff", "wusel", "lumi", "brumm", "flausch"]

    signal finished(int score, int coins, int funBase)

    function start() {
        elapsed = 0;
        served = 0;
        tips = 0;
        combo = 0;
        customers = [null, null, null];
        clearCup();
        running = true;
        spawn(0);
        spawnLater.restart();
    }

    function clearCup() { cupBase = ""; cupTopping = ""; cupCream = false; }

    function makeOrder() {
        var b = bases[Math.floor(Math.random() * bases.length)].id;
        var t = toppings[Math.floor(Math.random() * toppings.length)].id;
        var creamChance = elapsed < 15 ? 0 : (elapsed < 35 ? 0.35 : 0.6);
        var patience = Math.max(9, 15 - elapsed / 8);
        return {
            base: b, topping: t, cream: Math.random() < creamChance,
            patience: patience, left: patience,
            species: guestSpecies[Math.floor(Math.random() * guestSpecies.length)],
            hue: Math.random() * 360, mood: "neutral"
        };
    }

    function spawn(slot) {
        var c = customers.slice();
        c[slot] = makeOrder();
        customers = c;
    }

    function freeSlot() {
        for (var i = 0; i < 3; i++) if (customers[i] === null) return i;
        return -1;
    }

    function leave(slot, happy) {
        var c = customers.slice();
        if (c[slot]) c[slot].mood = happy ? "happy" : "sad";
        customers = c;
        leaveTimer.slots.push(slot);
        leaveTimer.restart();
    }

    function serve() {
        if (!running || cupBase === "") return;
        for (var i = 0; i < 3; i++) {
            var o = customers[i];
            if (o && o.mood === "neutral" && o.base === cupBase && o.topping === cupTopping && o.cream === cupCream) {
                combo++;
                var tip = 3 + Math.round(4 * o.left / o.patience) + Math.min(combo - 1, 5);
                tips += tip;
                served++;
                flash = "+" + tip + (combo > 1 ? "  ×" + combo : "");
                flashTimer.restart();
                leave(i, true);
                clearCup();
                return;
            }
        }
        combo = 0;
        flash = qsTr("Passt zu keiner Bestellung");
        flashTimer.restart();
        clearCup();
    }

    Timer {
        interval: 100
        repeat: true
        running: game.running
        onTriggered: {
            game.elapsed += 0.1;
            var c = game.customers;
            for (var i = 0; i < 3; i++) {
                if (c[i] && c[i].mood === "neutral") {
                    c[i].left -= 0.1;
                    if (c[i].left <= 0) { game.combo = 0; game.leave(i, false); }
                }
            }
            game.rev++;
            if (game.elapsed >= game.duration) {
                game.running = false;
                game.finished(game.served, Math.min(70, game.tips), Math.min(32, 12 + game.served * 2));
            }
        }
    }

    Timer {
        id: leaveTimer
        property var slots: []
        interval: 650
        onTriggered: {
            var c = game.customers.slice();
            for (var i = 0; i < slots.length; i++) c[slots[i]] = null;
            slots = [];
            game.customers = c;
        }
    }

    Timer {
        id: spawnLater
        interval: 1200
        repeat: true
        running: game.running
        onTriggered: {
            var s = game.freeSlot();
            if (s >= 0 && Math.random() < 0.7) game.spawn(s);
            interval = 900 + Math.random() * 1400;
        }
    }

    Timer { id: flashTimer; interval: 1100; onTriggered: game.flash = "" }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Kopf
        RowLayout {
            Layout.fillWidth: true
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Qt.rgba(game.fg.r, game.fg.g, game.fg.b, 0.1)
                Rectangle {
                    width: parent.width * Math.max(0, 1 - game.elapsed / game.duration)
                    height: parent.height
                    radius: 3
                    color: "#9fc7f0"
                }
            }
            Text { text: qsTr("%1 verkauft").arg(game.served); color: game.fg; opacity: 0.75 }
            LineIcon { Layout.preferredWidth: 16; Layout.preferredHeight: 16; name: "coin" }
            Text { text: game.tips; color: game.fg; font.weight: Font.DemiBold }
        }

        // Kundschaft
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 170
            Layout.maximumHeight: 170
            spacing: 6

            Repeater {
                model: 3
                delegate: Item {
                    id: slot
                    required property int index
                    readonly property var order: { game.rev; return game.customers[index]; }
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        visible: slot.order !== null
                        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                        width: 64
                        height: 78
                        radius: 14
                        color: Kirigami.Theme.backgroundColor
                        border.color: Qt.rgba(game.fg.r, game.fg.g, game.fg.b, 0.14)

                        CupView {
                            anchors.fill: parent
                            anchors.margins: 6
                            base: slot.order ? slot.order.base : ""
                            topping: slot.order ? slot.order.topping : ""
                            cream: slot.order ? slot.order.cream : false
                        }
                    }

                    PetCanvas {
                        visible: slot.order !== null
                        anchors { bottom: patience.top; horizontalCenter: parent.horizontalCenter }
                        width: 78
                        height: 78
                        species: slot.order ? slot.order.species : "mochi"
                        hue: slot.order ? slot.order.hue : 0
                        expression: slot.order ? (slot.order.mood !== "neutral" ? slot.order.mood : (slot.order.left / slot.order.patience < 0.3 ? "sad" : "neutral")) : "neutral"
                    }

                    Rectangle {
                        id: patience
                        visible: slot.order !== null && slot.order.mood === "neutral"
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        width: 60
                        height: 5
                        radius: 2.5
                        color: Qt.rgba(game.fg.r, game.fg.g, game.fg.b, 0.1)
                        Rectangle {
                            readonly property real frac: slot.order ? Math.max(0, slot.order.left / slot.order.patience) : 0
                            width: parent.width * frac
                            height: parent.height
                            radius: 2.5
                            color: frac < 0.3 ? "#ef8a8a" : "#9ed3a9"
                        }
                    }
                }
            }
        }

        // Theke mit Becher
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: parent.height * 0.35
                radius: 14
                color: Qt.rgba(game.fg.r, game.fg.g, game.fg.b, 0.05)
            }
            CupView {
                anchors.centerIn: parent
                height: Math.min(parent.height * 0.95, 150)
                width: height * 0.8
                base: game.cupBase
                topping: game.cupTopping
                cream: game.cupCream
            }
            Text {
                visible: game.flash !== ""
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                text: game.flash
                color: game.flash.charAt(0) === "+" ? "#4f9a6a" : "#c46a6a"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
        }

        // Zutaten
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            Repeater {
                model: game.bases
                delegate: PillButton {
                    required property var modelData
                    Layout.fillWidth: true
                    text: modelData.label
                    fill: modelData.color
                    ink: "#3b3140"
                    onClicked: game.cupBase = modelData.id
                }
            }
            Repeater {
                model: game.toppings
                delegate: PillButton {
                    required property var modelData
                    Layout.fillWidth: true
                    text: modelData.label
                    fill: modelData.color
                    ink: "#3b3140"
                    enabled: game.cupBase !== ""
                    onClicked: game.cupTopping = modelData.id
                }
            }
            PillButton {
                Layout.fillWidth: true
                text: qsTr("Sahne")
                fill: "#fbf6ee"
                ink: "#3b3140"
                enabled: game.cupBase !== ""
                onClicked: game.cupCream = !game.cupCream
            }
            PillButton {
                Layout.fillWidth: true
                text: qsTr("Weg")
                subtle: true
                onClicked: game.clearCup()
            }
            PillButton {
                Layout.fillWidth: true
                Layout.columnSpan: 4
                text: qsTr("Servieren")
                enabled: game.cupBase !== "" && game.cupTopping !== ""
                onClicked: game.serve()
            }
        }
    }
}
