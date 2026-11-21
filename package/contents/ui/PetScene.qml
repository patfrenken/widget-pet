import QtQuick
import org.kde.kirigami as Kirigami

// Die kleine Bühne: Pet mit Atmen, Blinzeln, Hüpfen, Häufchen, Sprechblase.
Item {
    id: scene

    required property var petModel
    property bool animate: true

    readonly property real petSize: Math.min(width * 0.7, height)
    readonly property bool idle: animate && !petModel.dead
    property bool blinking: false
    property bool eating: false
    property bool eatOpen: false
    property bool loving: false
    property real wander: 0

    readonly property string expression: {
        if (petModel.dead) return "sleep";
        if (eating) return eatOpen ? "eat1" : "eat2";
        if (loving) return "love";
        if (blinking && petModel.mood !== "sleep") return "blink";
        return petModel.mood;
    }

    function hop() {
        hopAnim.restart();
        spawnHeart();
    }

    function spawnHeart() {
        heartComponent.createObject(scene, {
            x: petBox.x + petBox.width * (0.35 + Math.random() * 0.3),
            y: petBox.y + petBox.height * 0.25
        });
    }

    Connections {
        target: scene.petModel
        function onFed(foodId) {
            scene.eating = true;
            eatTimer.count = 0;
            eatTimer.restart();
        }
        function onHopRequested() { scene.hop(); }
    }

    // Ersatzbild, solange das Pet unterwegs ist
    AwayCanvas {
        anchors.fill: parent
        visible: scene.petModel.away
        place: scene.petModel.awayPlace
        hue: scene.petModel.hue
    }

    // Schatten
    Rectangle {
        visible: !scene.petModel.away
        width: petBox.width * (scene.petModel.isEgg ? 0.40 : 0.5) * (1 + lift.y / (scene.petSize + 1))
        height: Math.max(4, width * 0.11)
        radius: height / 2
        x: petBox.x + (petBox.width - width) / 2
        y: petBox.y + petBox.height * 0.955 - height / 2
        color: Qt.rgba(0, 0, 0, scene.petModel.dead ? 0.03 : 0.07)
    }

    // Häufchen
    Repeater {
        model: scene.petModel.poop
        delegate: LineIcon {
            required property int index
            width: scene.petSize * 0.2
            height: width
            name: "poop"
            accent: "#b89aa6"
            x: index % 2 === 0 ? scene.width - width * (1.1 + index * 0.45) : width * (0.1 + index * 0.4)
            y: scene.height - height * 1.02
        }
    }

    Item {
        id: petBox
        visible: !scene.petModel.away
        width: scene.petSize
        height: scene.petSize
        x: (scene.width - width) / 2 + scene.wander
        y: scene.height - height
        transformOrigin: Item.Bottom

        Behavior on x { NumberAnimation { duration: 1800; easing.type: Easing.InOutSine } }

        PetCanvas {
            id: pet
            anchors.fill: parent
            species: scene.petModel.species
            hue: scene.petModel.hue
            eggPattern: scene.petModel.eggPattern
            crack: scene.petModel.isEgg ? Math.max(0, (scene.petModel.hatch - 0.6) / 0.4) : 0
            sick: scene.petModel.sick
            senior: scene.petModel.senior
            ghost: scene.petModel.dead
            expression: scene.expression
            opacity: scene.petModel.dead ? 0.75 : 1
            transform: [
                Scale { id: squash; origin.x: pet.width / 2; origin.y: pet.height * 0.93 },
                Translate { id: lift }
            ]
        }

        MouseArea {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.7
            cursorShape: Qt.PointingHandCursor
            onClicked: scene.petModel.pat()
        }
    }

    // Sprechblase mit dem dringendsten Bedürfnis
    Rectangle {
        id: bubble
        readonly property var icons: ({ hungry: "feed", poop: "clean", bored: "play", sick: "heal" })
        visible: scene.petModel.need !== "" && !scene.eating
        width: Kirigami.Units.gridUnit * 1.5
        height: width
        radius: width / 2
        color: Kirigami.Theme.backgroundColor
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
        x: petBox.x + petBox.width * 0.74
        y: petBox.y + petBox.height * 0.12 + bubbleBob.y
        transform: Translate { id: bubbleBob }

        LineIcon {
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: width
            name: bubble.icons[scene.petModel.need] || "more"
            color: scene.petModel.need === "sick" ? "#d97a7a" : Kirigami.Theme.textColor
        }

        SequentialAnimation {
            running: bubble.visible && scene.animate
            loops: Animation.Infinite
            NumberAnimation { target: bubbleBob; property: "y"; to: -3; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { target: bubbleBob; property: "y"; to: 0; duration: 900; easing.type: Easing.InOutSine }
        }
    }

    // Zzz
    Repeater {
        model: scene.petModel.asleep && scene.animate && !scene.petModel.away ? 3 : 0
        delegate: Text {
            id: zz
            required property int index
            text: "z"
            color: Kirigami.Theme.textColor
            font.pixelSize: scene.petSize * (0.09 + index * 0.03)
            font.weight: Font.DemiBold
            x: petBox.x + petBox.width * (0.68 + index * 0.08)
            y: petBox.y + petBox.height * 0.35
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: zz.index * 700 }
                NumberAnimation { from: 0; to: 0.6; duration: 600 }
                NumberAnimation { to: 0; duration: 1300 }
            }
            NumberAnimation on y {
                loops: Animation.Infinite
                from: petBox.y + petBox.height * 0.35
                to: petBox.y + petBox.height * 0.05
                duration: 2600
            }
        }
    }

    Component {
        id: heartComponent
        LineIcon {
            id: heart
            width: scene.petSize * 0.13
            height: width
            name: "heart"
            accent: "#f08ca4"
            ParallelAnimation {
                running: true
                NumberAnimation { target: heart; property: "y"; to: heart.y - scene.petSize * 0.35; duration: 900; easing.type: Easing.OutQuad }
                NumberAnimation { target: heart; property: "opacity"; from: 1; to: 0; duration: 900; easing.type: Easing.InQuad }
                onFinished: heart.destroy()
            }
        }
    }

    // ------------------------------------------------------------ Animationen
    SequentialAnimation {
        id: breathe
        running: scene.animate && !scene.petModel.dead && !scene.petModel.away
        loops: Animation.Infinite
        ParallelAnimation {
            NumberAnimation { target: squash; property: "yScale"; to: 1.035; duration: scene.petModel.asleep ? 2600 : 1500; easing.type: Easing.InOutSine }
            NumberAnimation { target: squash; property: "xScale"; to: 0.985; duration: scene.petModel.asleep ? 2600 : 1500; easing.type: Easing.InOutSine }
        }
        ParallelAnimation {
            NumberAnimation { target: squash; property: "yScale"; to: 1.0; duration: scene.petModel.asleep ? 2600 : 1500; easing.type: Easing.InOutSine }
            NumberAnimation { target: squash; property: "xScale"; to: 1.0; duration: scene.petModel.asleep ? 2600 : 1500; easing.type: Easing.InOutSine }
        }
    }

    SequentialAnimation {
        id: hopAnim
        ParallelAnimation {
            NumberAnimation { target: lift; property: "y"; to: -scene.petSize * 0.12; duration: 170; easing.type: Easing.OutQuad }
            NumberAnimation { target: squash; property: "yScale"; to: 1.08; duration: 170 }
        }
        ParallelAnimation {
            NumberAnimation { target: lift; property: "y"; to: 0; duration: 190; easing.type: Easing.InQuad }
            NumberAnimation { target: squash; property: "yScale"; to: 0.92; duration: 190 }
        }
        NumberAnimation { target: squash; property: "yScale"; to: 1; duration: 160; easing.type: Easing.OutBack }
    }

    SequentialAnimation {
        id: ghostFloat
        running: scene.animate && scene.petModel.dead
        loops: Animation.Infinite
        NumberAnimation { target: lift; property: "y"; to: -scene.petSize * 0.08; duration: 1800; easing.type: Easing.InOutSine }
        NumberAnimation { target: lift; property: "y"; to: -scene.petSize * 0.02; duration: 1800; easing.type: Easing.InOutSine }
    }

    SequentialAnimation {
        id: wobble
        running: scene.animate && scene.petModel.isEgg
        loops: Animation.Infinite
        PauseAnimation { duration: Math.max(600, 4000 * (1 - scene.petModel.hatch)) }
        RotationAnimation { target: petBox; to: -6 - 6 * scene.petModel.hatch; duration: 140 }
        RotationAnimation { target: petBox; to: 6 + 6 * scene.petModel.hatch; duration: 200 }
        RotationAnimation { target: petBox; to: 0; duration: 140 }
    }

    Timer {
        interval: 2600 + Math.random() * 3500
        running: scene.idle && !scene.petModel.isEgg && !scene.petModel.asleep && !scene.petModel.away
        repeat: true
        onTriggered: {
            scene.blinking = true;
            blinkOff.restart();
            interval = 2600 + Math.random() * 3500;
        }
    }
    Timer { id: blinkOff; interval: 140; onTriggered: scene.blinking = false }

    Timer {
        interval: 7000
        running: scene.idle && !scene.petModel.isEgg && !scene.petModel.asleep && !scene.petModel.sick && !scene.petModel.away
        repeat: true
        onTriggered: {
            var range = Math.max(0, (scene.width - petBox.width) / 2);
            scene.wander = Math.random() < 0.3 ? 0 : (Math.random() * 2 - 1) * range;
            interval = 5000 + Math.random() * 9000;
        }
    }

    Timer {
        id: eatTimer
        property int count: 0
        interval: 220
        repeat: true
        onTriggered: {
            scene.eatOpen = !scene.eatOpen;
            if (++count >= 8) { stop(); scene.eating = false; scene.spawnHeart(); }
        }
    }
}
