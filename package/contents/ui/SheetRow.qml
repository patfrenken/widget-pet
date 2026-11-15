import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

AbstractButton {
    id: row

    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property string glyph: ""
    property color dot: "transparent"
    property bool locked: false
    property bool showCoin: false

    readonly property color fg: Kirigami.Theme.textColor

    implicitHeight: Kirigami.Units.gridUnit * 2.3
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    opacity: enabled ? 1 : 0.45
    Accessible.name: title + ", " + subtitle

    background: Rectangle {
        radius: 10
        color: Qt.rgba(row.fg.r, row.fg.g, row.fg.b, row.pressed ? 0.12 : (row.hovered ? 0.06 : 0))
    }

    contentItem: RowLayout {
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            Layout.leftMargin: 4
            radius: 11
            color: row.dot

            LineIcon {
                anchors.centerIn: parent
                visible: row.glyph !== ""
                width: 16
                height: 16
                name: row.glyph
                color: row.fg
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: row.title
                color: row.fg
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize > 0 ? Kirigami.Theme.defaultFont.pixelSize : 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: row.subtitle !== ""
                text: row.subtitle
                color: row.fg
                opacity: 0.6
                font.pixelSize: Math.round((Kirigami.Theme.defaultFont.pixelSize > 0 ? Kirigami.Theme.defaultFont.pixelSize : 12) * 0.82)
                elide: Text.ElideRight
            }
        }

        LineIcon {
            visible: row.locked
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            name: "lock"
            color: row.fg
        }

        Text {
            visible: row.trailing !== ""
            text: row.trailing
            color: row.fg
            opacity: 0.75
            font.pixelSize: Math.round((Kirigami.Theme.defaultFont.pixelSize > 0 ? Kirigami.Theme.defaultFont.pixelSize : 12) * 0.85)
        }

        LineIcon {
            visible: row.showCoin
            Layout.preferredWidth: 13
            Layout.preferredHeight: 13
            Layout.rightMargin: 4
            name: "coin"
        }
    }
}
