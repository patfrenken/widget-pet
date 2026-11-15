import QtQuick
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

AbstractButton {
    id: btn

    property color fill: Kirigami.Theme.highlightColor
    property color ink: "white"
    property bool subtle: false

    readonly property color fg: Kirigami.Theme.textColor

    implicitHeight: Kirigami.Units.gridUnit * 2.2
    implicitWidth: Math.max(implicitHeight * 2, label.implicitWidth + implicitHeight)
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: text

    background: Rectangle {
        radius: height / 2
        color: btn.subtle ? Qt.rgba(btn.fg.r, btn.fg.g, btn.fg.b, btn.pressed ? 0.16 : (btn.hovered ? 0.11 : 0.07))
                          : (btn.pressed ? Qt.darker(btn.fill, 1.12) : (btn.hovered ? Qt.lighter(btn.fill, 1.06) : btn.fill))
        opacity: btn.enabled ? 1 : 0.4
        scale: btn.pressed ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: 90 } }
    }

    contentItem: Text {
        id: label
        text: btn.text
        color: btn.subtle ? btn.fg : btn.ink
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: btn.enabled ? 1 : 0.5
    }
}
