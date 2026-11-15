import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "logic.js" as Logic

// Ahnenbaum: aktuelle Generation oben, Vorfahren darunter.
Item {
    id: view

    required property var petModel

    readonly property color fg: Kirigami.Theme.textColor
    readonly property var entries: {
        var p = petModel;
        var list = [{
            current: true, gen: p.generation, name: p.name, hue: p.hue,
            forms: p.ready ? [p.s.species.baby, p.s.species.teen, p.s.species.adult] : [],
            days: p.ageDays, cause: ""
        }];
        var a = p.ancestry;
        for (var i = a.length - 1; i >= 0; i--) list.push(a[i]);
        return list;
    }

    function lastForm(forms) {
        for (var i = forms.length - 1; i >= 0; i--) if (forms[i]) return forms[i];
        return "egg";
    }

    function causeText(e) {
        if (e.current) return petModel.isEgg ? qsTr("wird gerade ausgebrütet") : qsTr("lebt gerade · %1 Tage").arg(e.days);
        if (e.cause === "age") return qsTr("Sternenreise nach %1 Tagen").arg(e.days);
        if (e.cause === "neglect") return qsTr("vernachlässigt · %1 Tage").arg(e.days);
        return qsTr("neu begonnen nach %1 Tagen").arg(e.days);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Text {
            text: qsTr("Ahnenbaum")
            color: view.fg
            font.pixelSize: 22
            font.weight: Font.Bold
        }
        Text {
            text: qsTr("%1 Generation(en)").arg(view.entries.length)
            color: view.fg
            opacity: 0.6
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: column.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            // Verbindungslinie
            Rectangle {
                x: 38
                y: 40
                width: 2
                height: Math.max(0, column.implicitHeight - 80)
                color: Qt.rgba(view.fg.r, view.fg.g, view.fg.b, 0.12)
            }

            Column {
                id: column
                width: parent.width
                spacing: 10

                Repeater {
                    model: view.entries
                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        width: column.width
                        height: 86
                        radius: 16
                        color: modelData.current ? Qt.rgba(1, 0.92, 0.7, 0.35) : Qt.rgba(view.fg.r, view.fg.g, view.fg.b, 0.04)
                        border.color: Qt.rgba(view.fg.r, view.fg.g, view.fg.b, modelData.current ? 0.18 : 0.06)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            PetCanvas {
                                Layout.preferredWidth: 62
                                Layout.preferredHeight: 62
                                species: view.lastForm(card.modelData.forms)
                                hue: card.modelData.hue
                                eggPattern: "dots"
                                expression: card.modelData.current ? "happy" : "sleep"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: card.modelData.name + "  <font color='" + Qt.rgba(view.fg.r, view.fg.g, view.fg.b, 0.5) + "'>" + qsTr("Gen. %1").arg(card.modelData.gen) + "</font>"
                                    textFormat: Text.StyledText
                                    color: view.fg
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: view.causeText(card.modelData)
                                    color: view.fg
                                    opacity: 0.6
                                    font.pixelSize: 12
                                }
                                Row {
                                    spacing: 2
                                    Repeater {
                                        model: card.modelData.forms
                                        delegate: Row {
                                            required property var modelData
                                            required property int index
                                            visible: !!modelData
                                            spacing: 2
                                            Text {
                                                visible: parent.index > 0
                                                text: "›"
                                                color: view.fg
                                                opacity: 0.35
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            PetCanvas {
                                                width: 26
                                                height: 26
                                                species: parent.modelData || "mochi"
                                                hue: card.modelData.hue
                                            }
                                            Text {
                                                text: parent.modelData && Logic.SPECIES[parent.modelData] ? Logic.SPECIES[parent.modelData].label : ""
                                                color: view.fg
                                                opacity: 0.55
                                                font.pixelSize: 11
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
