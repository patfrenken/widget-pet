import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_frameMode: frameCombo.currentIndex
    property int cfg_timeScale: 1
    property alias cfg_sleepStart: sleepStart.value
    property alias cfg_sleepEnd: sleepEnd.value

    readonly property var scales: [1, 60, 1440]

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: frameCombo
            Kirigami.FormData.label: qsTr("Rahmen & Steuerung:")
            model: [qsTr("Nur beim Überfahren"), qsTr("Immer dezent sichtbar")]
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: qsTr("Zeit:")
            model: [qsTr("Echtzeit (ein Leben ≈ 12 Wochen)"), qsTr("Zeitraffer 60× (≈ 1,4 Tage)"), qsTr("Zeitraffer 1440× (≈ 1,4 Stunden)")]
            currentIndex: Math.max(0, page.scales.indexOf(page.cfg_timeScale))
            onActivated: index => page.cfg_timeScale = page.scales[index]
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: sleepStart
            Kirigami.FormData.label: qsTr("Schlafenszeit ab:")
            from: 0
            to: 23
            textFromValue: v => v + ":00"
        }

        QQC2.SpinBox {
            id: sleepEnd
            Kirigami.FormData.label: qsTr("Aufwachen um:")
            from: 0
            to: 23
            textFromValue: v => v + ":00"
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: qsTr("Während der Schlafenszeit sinken die Bedürfnisse langsamer. Ist der PC aus, altert dein Pet weiter, seine Werte fallen aber nur gedrosselt und nie in den kritischen Bereich.")
        }
    }
}
