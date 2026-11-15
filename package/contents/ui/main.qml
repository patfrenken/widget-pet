import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    PetModel {
        id: pet
        config: Plasmoid.configuration
    }

    fullRepresentation: PetWidget {
        petModel: pet
        frameMode: Plasmoid.configuration.frameMode
        onOpenWindow: page => {
            windowLoader.page = page;
            windowLoader.active = true;
            if (windowLoader.status === Loader.Ready) {
                windowLoader.item.show();
                windowLoader.item.raise();
                windowLoader.item.requestActivate();
            }
        }
    }

    Loader {
        id: windowLoader
        property string page: ""
        active: false
        sourceComponent: PetWindow {
            petModel: pet
            page: windowLoader.page
            onClosing: windowLoader.active = false
        }
    }
}
