import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: bar

    property string iconName: "hunger"
    property real value: 50
    property color barColor: "#8fc7a6"
    property string label: ""

    spacing: 4
    Accessible.role: Accessible.ProgressBar
    Accessible.name: label + " " + Math.round(value) + "%"

    LineIcon {
        Layout.preferredWidth: 12
        Layout.preferredHeight: 12
        name: bar.iconName
        color: Kirigami.Theme.textColor
        opacity: 0.7
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 5
        radius: 2.5
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.10)

        Rectangle {
            width: Math.max(height, parent.width * Math.max(0, Math.min(1, bar.value / 100)))
            height: parent.height
            radius: height / 2
            color: bar.value < 25 ? "#ef8a8a" : bar.barColor
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }
}
