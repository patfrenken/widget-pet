import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "games"
import "logic.js" as Logic

// Eigenes Fenster für Minispiele und Ahnenbaum.
Window {
    id: win

    required property var petModel
    property string page: ""
    property string phase: "intro"          // intro | play | result
    property var result: null
    property int lastScore: 0

    readonly property color fg: Kirigami.Theme.textColor
    readonly property var game: {
        for (var i = 0; i < Logic.GAMES.length; i++) if (Logic.GAMES[i].id === page) return Logic.GAMES[i];
        return null;
    }

    width: 400
    height: 580
    minimumWidth: 360
    minimumHeight: 540
    visible: true
    title: (page === "tree" ? qsTr("Ahnenbaum") : (game ? game.label : "")) + " · Widget Pet"
    color: Kirigami.Theme.backgroundColor

    onPageChanged: phase = "intro"

    function begin() {
        phase = "play";
        gameLoader.item.start();
        gameLoader.item.forceActiveFocus();
    }

    function done(score, coins, funBase) {
        lastScore = score;
        result = petModel.gameResult(page, score, coins, funBase);
        phase = "result";
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        anchors.margins: 12
        sourceComponent: ({ cuddle: cuddleComp, flap: flapComp, cafe: cafeComp, tree: treeComp })[win.page] || null
    }

    Connections {
        target: gameLoader.item
        ignoreUnknownSignals: true
        function onFinished(score, coins, funBase) { win.done(score, coins, funBase); }
    }

    Component { id: cuddleComp; CuddleGame { petModel: win.petModel } }
    Component { id: flapComp; FlapGame { petModel: win.petModel } }
    Component { id: cafeComp; CafeGame { petModel: win.petModel } }
    Component { id: treeComp; AncestryView { petModel: win.petModel } }

    // Intro & Ergebnis
    Rectangle {
        anchors.fill: parent
        visible: win.game !== null && win.phase !== "play"
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.88)

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.78
            spacing: 10

            PetCanvas {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                species: win.petModel.species
                hue: win.petModel.hue
                senior: win.petModel.senior
                expression: win.phase === "result" ? "happy" : "neutral"
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: win.phase === "result" ? (win.result && win.result.record ? qsTr("Neuer Rekord!") : qsTr("Geschafft!")) : (win.game ? win.game.label : "")
                color: win.fg
                font.pixelSize: 22
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: win.fg
                opacity: 0.75
                visible: win.phase === "intro"
                text: (win.game ? win.game.desc : "") + "\n" + ({
                    cuddle: qsTr("Streichle dein Pet sanft mit der Maus – zu wildes Rubbeln macht es schwindelig. Glitzernde Stellen geben extra Herzen."),
                    flap: qsTr("Klick oder Leertaste zum Flattern. Sterne geben Bonus-Münzen."),
                    cafe: qsTr("Bau den Becher wie bestellt und serviere. Schnelle Bedienung = mehr Trinkgeld.")
                })[win.page]
            }

            // Ergebnis-Zeilen
            GridLayout {
                visible: win.phase === "result" && win.result !== null
                Layout.alignment: Qt.AlignHCenter
                columns: 2
                columnSpacing: 16
                rowSpacing: 4

                Text { text: qsTr("Punkte"); color: win.fg; opacity: 0.7 }
                Text { text: win.lastScore; color: win.fg; font.weight: Font.DemiBold }
                Text { text: qsTr("Münzen"); color: win.fg; opacity: 0.7 }
                Text { text: win.result ? "+" + win.result.coins + (win.result.bonus ? qsTr("  (+%1 Tagesbonus)").arg(win.result.bonus) : "") : ""; color: win.fg; font.weight: Font.DemiBold }
                Text { text: qsTr("Laune"); color: win.fg; opacity: 0.7 }
                Text { text: win.result ? "+" + win.result.fun : ""; color: win.fg; font.weight: Font.DemiBold }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: win.phase === "result" && win.result !== null && win.result.tired
                text: qsTr("%1 wird langsam müde – eine Pause bringt mehr Spaß.").arg(win.petModel.name)
                color: win.fg
                opacity: 0.6
                font.pixelSize: 12
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: win.phase === "intro" && win.petModel.bestScore(win.page) > 0
                text: qsTr("Rekord: %1").arg(win.petModel.bestScore(win.page))
                color: win.fg
                opacity: 0.6
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 6
                spacing: 8
                PillButton {
                    visible: win.phase === "result"
                    text: qsTr("Fertig")
                    subtle: true
                    onClicked: win.close()
                }
                PillButton {
                    text: win.phase === "result" ? qsTr("Nochmal") : qsTr("Los geht's")
                    enabled: !win.petModel.asleep && !win.petModel.dead && !win.petModel.away
                    onClicked: win.begin()
                }
            }
        }
    }
}
