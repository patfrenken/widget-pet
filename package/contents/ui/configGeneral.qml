import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "strings.js" as Strings

KCM.SimpleKCM {
    id: page

    property string cfg_language: "en"
    property int cfg_frameMode: 0
    property int cfg_timeScale: 1
    property alias cfg_sleepStart: sleepStart.value
    property alias cfg_sleepEnd: sleepEnd.value

    readonly property var scales: [1, 60, 1440]

    function t(text) { return Strings.tr(page.cfg_language === "de" ? "de" : "en", text, []); }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: "Language / Sprache:"
            model: ["English", "Deutsch"]
            currentIndex: page.cfg_language === "de" ? 1 : 0
            onActivated: index => page.cfg_language = index === 1 ? "de" : "en"
        }

        QQC2.ComboBox {
            id: frameCombo
            currentIndex: page.cfg_frameMode
            onActivated: index => page.cfg_frameMode = index
            Kirigami.FormData.label: page.t("Rahmen & Steuerung:")
            model: [page.t("Nur beim Überfahren"), page.t("Immer dezent sichtbar")]
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: page.t("Zeit:")
            model: [page.t("Echtzeit (ein Leben ≈ 12 Wochen)"), page.t("Zeitraffer 60× (≈ 1,4 Tage)"), page.t("Zeitraffer 1440× (≈ 1,4 Stunden)")]
            currentIndex: Math.max(0, page.scales.indexOf(page.cfg_timeScale))
            onActivated: index => page.cfg_timeScale = page.scales[index]
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: sleepStart
            Kirigami.FormData.label: page.t("Schlafenszeit ab:")
            from: 0
            to: 23
            textFromValue: v => v + ":00"
        }

        QQC2.SpinBox {
            id: sleepEnd
            Kirigami.FormData.label: page.t("Aufwachen um:")
            from: 0
            to: 23
            textFromValue: v => v + ":00"
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: page.t("Während der Schlafenszeit sinken die Bedürfnisse langsamer. Ist der PC aus, laufen sie fast normal weiter – schick dein Pet vorher in Kita, Schule, Arbeit oder zum Entspannen, dann sinken sie kaum.")
        }
    }
}
