import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Das sichtbare Widget: Pet immer sichtbar, Rahmen & Steuerung beim Überfahren.
Item {
    id: widget

    required property var petModel
    property int frameMode: 0          // 0 = nur beim Überfahren, 1 = immer dezent
    property bool animate: true

    signal openWindow(string page)

    readonly property color fg: Kirigami.Theme.textColor
    readonly property bool chrome: hover.hovered || frameMode === 1 || sheet.open || petModel.dead || pinTimer.running

    Layout.minimumWidth: Kirigami.Units.gridUnit * 10
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 13
    Layout.preferredHeight: Kirigami.Units.gridUnit * 15

    HoverHandler { id: hover }
    Timer { id: pinTimer; interval: 2500 }   // UI kurz sichtbar halten, z. B. nach Meldungen

    Connections {
        target: widget.petModel
        function onNotify(text, kind) { toast.show(text, kind); }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.80)
        border.color: Qt.rgba(widget.fg.r, widget.fg.g, widget.fg.b, 0.10)
        opacity: widget.chrome ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 240 } }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        // Kopfzeile
        RowLayout {
            Layout.fillWidth: true
            opacity: widget.chrome ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 240 } }

            Text {
                Layout.fillWidth: true
                text: widget.petModel.name + "  <font color='" + Qt.rgba(widget.fg.r, widget.fg.g, widget.fg.b, 0.55) + "'>" + widget.petModel.stageLabel + "</font>"
                textFormat: Text.StyledText
                color: widget.fg
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            LineIcon {
                visible: widget.petModel.asleep
                Layout.preferredWidth: 13
                Layout.preferredHeight: 13
                name: "moon"
                color: widget.fg
                opacity: 0.6
            }
            LineIcon {
                Layout.preferredWidth: 13
                Layout.preferredHeight: 13
                name: "coin"
            }
            Text {
                text: widget.petModel.coins
                color: widget.fg
                opacity: 0.8
            }
        }

        PetScene {
            id: scene
            Layout.fillWidth: true
            Layout.fillHeight: true
            petModel: widget.petModel
            animate: widget.animate
        }

        // Werte
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            opacity: widget.chrome && !widget.petModel.isEgg && !widget.petModel.dead ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 240 } }

            StatBar { Layout.fillWidth: true; iconName: "hunger"; label: widget.petModel.t("Sättigung"); value: widget.petModel.hunger; barColor: "#f2c27b" }
            StatBar { Layout.fillWidth: true; iconName: "fun"; label: widget.petModel.t("Laune"); value: widget.petModel.fun; barColor: "#9fc7f0" }
            StatBar { Layout.fillWidth: true; iconName: "health"; label: widget.petModel.t("Gesundheit"); value: widget.petModel.health; barColor: "#9ed3a9" }
        }

        // Unterwegs: Hinweis & Zurückrufen
        ColumnLayout {
            Layout.fillWidth: true
            visible: widget.petModel.away
            spacing: 4
            opacity: widget.chrome ? 1 : 0
            enabled: opacity > 0.5
            Behavior on opacity { NumberAnimation { duration: 240 } }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: widget.fg
                opacity: 0.7
                font.pixelSize: Math.round((Kirigami.Theme.defaultFont.pixelSize > 0 ? Kirigami.Theme.defaultFont.pixelSize : 12) * 0.85)
                text: {
                    var h = widget.petModel.awayHours;
                    var since = h < 1 ? widget.petModel.t("seit %1 Min.").arg(Math.max(1, Math.round(h * 60)))
                              : (h < 48 ? widget.petModel.t("seit %1 Std.").arg(Math.floor(h)) : widget.petModel.t("seit %1 Tagen").arg(Math.floor(h / 24)));
                    return widget.petModel.awayText + " · " + since;
                }
            }
            PillButton {
                Layout.alignment: Qt.AlignHCenter
                text: widget.petModel.t("Zurückrufen")
                onClicked: widget.petModel.recall()
            }
        }

        // Steuerung
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: !widget.petModel.away
            spacing: 2
            opacity: widget.chrome && !widget.petModel.dead ? 1 : 0
            enabled: opacity > 0.5
            Behavior on opacity { NumberAnimation { duration: 240 } }

            Item { Layout.fillWidth: true }
            IconButton {
                glyph: "feed"; tip: widget.petModel.t("Füttern")
                enabled: !widget.petModel.isEgg
                attention: widget.petModel.need === "hungry"
                onClicked: sheet.show("food")
            }
            IconButton {
                glyph: "play"; tip: widget.petModel.t("Spielen")
                enabled: !widget.petModel.isEgg
                attention: widget.petModel.need === "bored"
                onClicked: sheet.show("games")
            }
            IconButton {
                glyph: "clean"; tip: widget.petModel.t("Saubermachen")
                enabled: widget.petModel.poop > 0
                attention: widget.petModel.need === "poop"
                onClicked: widget.petModel.clean()
            }
            IconButton {
                glyph: "heal"; tip: widget.petModel.t("Medizin")
                enabled: !widget.petModel.isEgg
                attention: widget.petModel.sick
                onClicked: widget.petModel.medicine()
            }
            IconButton {
                glyph: "bag"; tip: widget.petModel.sendLabel
                enabled: !widget.petModel.isEgg && !widget.petModel.sick
                onClicked: widget.petModel.sendAway()
            }
            IconButton {
                glyph: "more"; tip: widget.petModel.t("Mehr")
                onClicked: sheet.show("more")
            }
            Item { Layout.fillWidth: true }
        }
    }

    // Kurze Meldungen
    Rectangle {
        id: toast
        property string kind: "info"
        function show(text, k) {
            label.text = text;
            kind = k;
            opacity = 1;
            hideTimer.interval = k === "info" ? 1800 : 3600;
            hideTimer.restart();
            pinTimer.restart();
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: Kirigami.Units.gridUnit * 2.1
        width: Math.min(parent.width - 24, label.implicitWidth + 20)
        height: label.implicitHeight + 10
        radius: height / 2
        color: kind === "evolve" ? "#f8e7b0" : (kind === "warn" || kind === "death" ? "#f6d2d2" : Kirigami.Theme.backgroundColor)
        border.color: Qt.rgba(widget.fg.r, widget.fg.g, widget.fg.b, 0.08)
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            id: label
            anchors.centerIn: parent
            width: Math.min(implicitWidth, widget.width - 44)
            color: toast.kind === "info" ? widget.fg : "#3b3140"
            font.pixelSize: Math.round((Kirigami.Theme.defaultFont.pixelSize > 0 ? Kirigami.Theme.defaultFont.pixelSize : 12) * 0.9)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        Timer { id: hideTimer; onTriggered: toast.opacity = 0 }
    }

    // Sternenreise
    Column {
        visible: widget.petModel.dead
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: widget.petModel.name + " · " + widget.petModel.t("%1 Tage").arg(widget.petModel.ageDays)
            color: widget.fg
            opacity: 0.7
        }
        SheetRow {
            width: widget.width * 0.7
            title: widget.petModel.t("Neues Ei ausbrüten")
            subtitle: widget.petModel.t("Generation %1").arg(widget.petModel.generation + 1)
            glyph: "restart"
            dot: "#f8e7b0"
            onClicked: widget.petModel.newEgg()
        }
    }

    MenuSheet {
        id: sheet
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4
        petModel: widget.petModel
        onOpenWindow: page => widget.openWindow(page)
    }
}
