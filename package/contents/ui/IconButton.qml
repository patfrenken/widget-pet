import QtQuick
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

AbstractButton {
    id: btn

    property string glyph: "more"
    property string tip: ""
    property bool attention: false
    property color tint: Kirigami.Theme.textColor

    implicitWidth: Kirigami.Units.gridUnit * 1.9
    implicitHeight: implicitWidth
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: tip

    ToolTip.text: tip
    ToolTip.visible: hovered && tip.length > 0
    ToolTip.delay: 600

    background: Rectangle {
        radius: width / 2
        color: Qt.rgba(btn.tint.r, btn.tint.g, btn.tint.b, btn.pressed ? 0.16 : (btn.hovered ? 0.09 : 0))
        Behavior on color { ColorAnimation { duration: 120 } }

        Rectangle {
            visible: btn.attention
            width: 6
            height: 6
            radius: 3
            color: "#ef8a8a"
            anchors { right: parent.right; top: parent.top; margins: 3 }
        }
    }

    contentItem: Item {
        LineIcon {
            anchors.centerIn: parent
            width: Math.round(btn.width * 0.54)
            height: width
            name: btn.glyph
            color: btn.enabled ? btn.tint : Qt.rgba(btn.tint.r, btn.tint.g, btn.tint.b, 0.35)
        }
    }
}
