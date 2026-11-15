import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "logic.js" as Logic

// Ausklappbares Menü im Widget: Futter, Spiele, Mehr, Steckbrief, Bestätigung.
Rectangle {
    id: sheet

    required property var petModel
    property string mode: ""
    readonly property bool open: mode !== ""

    signal openWindow(string page)

    readonly property color fg: Kirigami.Theme.textColor
    readonly property var stageNames: ({ baby: qsTr("Kleinkind"), teen: qsTr("Teenager"), adult: qsTr("Erwachsen") })
    readonly property var foodColors: ({ rice: "#f3efe6", apple: "#f6b3a8", cake: "#f7c6dc", bento: "#c9e2b8", feast: "#f5d58f" })

    color: Kirigami.Theme.backgroundColor
    radius: 16
    border.color: Qt.rgba(fg.r, fg.g, fg.b, 0.10)
    height: Math.min(parent.height - 8, header.height + list.contentHeight + 20)
    y: open ? parent.height - height - 4 : parent.height + 8
    visible: y < parent.height
    Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    function show(m) { mode = m; }
    function close() { mode = ""; }

    MouseArea { anchors.fill: parent }   // Klicks nicht zum Pet durchreichen

    RowLayout {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 6
            text: ({ food: qsTr("Füttern"), games: qsTr("Spielen"), more: qsTr("Mehr"), info: qsTr("Steckbrief"), confirm: qsTr("Neu beginnen?") })[sheet.mode] || ""
            color: sheet.fg
            font.weight: Font.DemiBold
        }

        Row {
            visible: sheet.mode === "food"
            spacing: 3
            LineIcon { width: 13; height: 13; name: "coin"; anchors.verticalCenter: parent.verticalCenter }
            Text { text: sheet.petModel.coins; color: sheet.fg; opacity: 0.8 }
        }

        IconButton {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.4
            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.4
            glyph: "close"
            tip: qsTr("Schließen")
            onClicked: sheet.close()
        }
    }

    Flickable {
        id: list
        anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom; margins: 8; topMargin: 4 }
        contentHeight: content.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: contentHeight > height

        ColumnLayout {
            id: content
            width: list.width
            spacing: 2

            // Futter
            Repeater {
                model: sheet.mode === "food" ? Logic.FOODS : []
                delegate: SheetRow {
                    required property var modelData
                    Layout.fillWidth: true
                    title: modelData.label
                    subtitle: "+" + modelData.hunger + " " + qsTr("Sättigung") + " · " + modelData.note
                    trailing: modelData.price > 0 ? modelData.price : qsTr("gratis")
                    showCoin: modelData.price > 0
                    dot: sheet.foodColors[modelData.id]
                    enabled: sheet.petModel.coins >= modelData.price
                    onClicked: { sheet.petModel.feed(modelData.id); sheet.close(); }
                }
            }

            // Spiele
            Repeater {
                model: sheet.mode === "games" ? Logic.GAMES : []
                delegate: SheetRow {
                    required property var modelData
                    readonly property bool unlocked: sheet.petModel.gameUnlocked(modelData.id)
                    Layout.fillWidth: true
                    title: modelData.label
                    subtitle: unlocked ? modelData.desc : qsTr("ab %1").arg(sheet.stageNames[modelData.minStage])
                    trailing: unlocked && sheet.petModel.bestScore(modelData.id) > 0 ? "★ " + sheet.petModel.bestScore(modelData.id) : ""
                    glyph: "play"
                    locked: !unlocked
                    enabled: unlocked && !sheet.petModel.asleep
                    onClicked: { sheet.openWindow(modelData.id); sheet.close(); }
                }
            }

            // Mehr
            SheetRow {
                visible: sheet.mode === "more"
                Layout.fillWidth: true
                glyph: "tree"
                title: qsTr("Ahnenbaum")
                subtitle: qsTr("%1 Generation(en)").arg(sheet.petModel.ancestry.length + 1)
                onClicked: { sheet.openWindow("tree"); sheet.close(); }
            }
            SheetRow {
                visible: sheet.mode === "more"
                Layout.fillWidth: true
                glyph: "info"
                title: qsTr("Steckbrief")
                subtitle: qsTr("Alter, Werte, Entwicklung")
                onClicked: sheet.show("info")
            }
            SheetRow {
                visible: sheet.mode === "more"
                Layout.fillWidth: true
                glyph: "restart"
                title: qsTr("Neu beginnen")
                subtitle: qsTr("Aktuelles Pet wandert in den Ahnenbaum")
                onClicked: sheet.show("confirm")
            }

            // Steckbrief
            Text {
                visible: sheet.mode === "info"
                Layout.fillWidth: true
                Layout.margins: 6
                color: sheet.fg
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                lineHeight: 1.15
                text: {
                    var p = sheet.petModel;
                    if (!p.ready) return "";
                    var spec = Logic.SPECIES[p.species];
                    return "<b>" + p.name + "</b> · " + p.speciesLabel + "<br>"
                        + (spec ? "<i>" + spec.desc + "</i><br>" : "")
                        + qsTr("Generation %1 · %2 · %3 Tage").arg(p.generation).arg(p.stageLabel).arg(p.ageDays) + "<br>"
                        + qsTr("Sättigung %1 · Laune %2 · Gesundheit %3").arg(Math.round(p.hunger)).arg(Math.round(p.fun)).arg(Math.round(p.health));
                }
            }

            // Bestätigung
            Text {
                visible: sheet.mode === "confirm"
                Layout.fillWidth: true
                Layout.margins: 6
                color: sheet.fg
                wrapMode: Text.WordWrap
                text: qsTr("%1 wird in den Ahnenbaum eingetragen und ein neues Ei gelegt.").arg(sheet.petModel.name)
            }
            RowLayout {
                visible: sheet.mode === "confirm"
                Layout.fillWidth: true
                SheetRow {
                    Layout.fillWidth: true
                    title: qsTr("Abbrechen")
                    glyph: "back"
                    onClicked: sheet.show("more")
                }
                SheetRow {
                    Layout.fillWidth: true
                    title: qsTr("Neues Ei")
                    glyph: "restart"
                    dot: "#f6c8c8"
                    onClicked: { sheet.petModel.restart(); sheet.close(); }
                }
            }
        }
    }
}
