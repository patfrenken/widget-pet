# Widget Pet

Ein kleines digitales Haustier als KDE-Plasma-6-Widget für den Desktop (getestet für Fedora mit Plasma 6).
Es schlüpft aus einem Ei, wächst über Kleinkind und Teenager zum Erwachsenen heran und reist nach
rund 12 Wochen zu den Sternen – danach liegt ein neues Ei bereit und der Ahnenbaum wächst.

![Widget](docs/widget.png)

## Installation

```bash
cd ~/Dokumente/widget-pet
bash install.sh
```

Danach: Rechtsklick auf den Desktop → **Widgets hinzufügen…** → „Widget Pet“ suchen und auf den Desktop ziehen.

Nach einem Update (`bash install.sh` erneut ausführen) lädt Plasma die neue Version erst nach
`systemctl --user restart plasma-plasmashell` oder einer Neuanmeldung.

Alternativ lässt sich `widget-pet.plasmoid` über **Widgets hinzufügen… → Neue Widgets holen → Widget aus lokaler Datei installieren** einspielen.

Zum Ausprobieren ohne Desktop: `sudo dnf install plasma-sdk` und dann `plasmoidviewer -a package`.

Deinstallieren: `bash uninstall.sh`

## Bedienung

Das Pet sitzt rahmenlos auf dem Desktop. Fährst du mit der Maus darüber, erscheinen ein dezenter Rahmen,
Name, Münzen, drei Werte und die Steuerleiste. In den Widget-Einstellungen kannst du den Rahmen auch dauerhaft einblenden.

| Knopf | Wirkung |
|---|---|
| Füttern | Futtermenü – Reisbällchen ist gratis, besseres Essen kostet Münzen |
| Spielen | Minispiele (je nach Alter freigeschaltet), bringen Laune und Münzen |
| Saubermachen | Häufchen wegräumen |
| Medizin | Heilt, wenn das Pet krank ist (sonst schadet sie ein bisschen) |
| Mehr | Ahnenbaum, Steckbrief, Neu beginnen |

Ein Klick auf das Pet streichelt es (beim Ei: wärmen, das verkürzt die Brutzeit). Eine kleine Sprechblase zeigt das dringendste Bedürfnis.

### Werte

- **Sättigung** sinkt mit der Zeit, Essen füllt sie auf. Überfüttern schadet.
- **Laune** sinkt mit der Zeit, Spielen und Streicheln heben sie. Spielt man sehr viel am Stück, bringt jede Runde etwas weniger Laune.
- **Gesundheit** sinkt bei Hunger, Langeweile, Häufchen und Krankheit und erholt sich, wenn alles passt.

Nachts (Standard 22–7 Uhr) schläft das Pet; die Werte sinken dann langsamer, Füttern und Spielen gehen erst wieder morgens.
Ist der PC aus, altert das Pet weiter, die Werte sinken aber nur gedrosselt und nie in den kritischen Bereich.
Steht die Gesundheit online zwei Tage lang auf null, stirbt das Pet vorzeitig.

## Lebenszyklus & Varianten

| Stadium | Dauer | Varianten (abhängig von Gesundheit & Laune im Stadium davor) |
|---|---|---|
| Ei | 2 Stunden (durch Wärmen bis zu 30 Min. kürzer) | Muster gepunktet oder gestreift, Farbe vom Elternteil geerbt |
| Kleinkind | 2 Wochen | Mochi (gepunktetes Ei), Tröpfi (gestreiftes Ei) |
| Teenager | 3 Wochen | Funkel (gesund + froh), Knuff (gesund), Wusel (froh), Mopp (vernachlässigt) |
| Erwachsen | ca. 6 Wochen, die letzte Woche als Senior mit Brille | Kiko (perfekt, selten), Lumi (sehr gut), Brumm (gesund), Flausch (froh), Grummel (vernachlässigt) |

Gute Pflege verlängert das Leben um bis zu 8 Tage. Ein Lumi- oder Kiko-Elternteil vererbt ein „gesegnetes“ Ei mit voller Gesundheit; die Hälfte der Münzen wird immer vererbt.

![Alle Formen](docs/formen.png)

## Minispiele

| Spiel | Ab | Ablauf |
|---|---|---|
| Kuscheln | Kleinkind | 15 Sekunden mit der Maus über das Pet streichen. Glitzernde Kitzelstellen geben dreifach Herzen. |
| Hüpfflug | Teenager | Mit Klick oder Leertaste durch Wolkentürme flattern. Sterne geben Bonus-Münzen, es wird langsam schneller. |
| Bubble-Tea-Bar | Erwachsen | 60-Sekunden-Schicht: Becher wie bestellt bauen (Tee + Topping, später mit Sahne) und servieren. Schnelle Bedienung und Serien geben mehr Trinkgeld. |

Das erste Spiel des Tages bringt 5 Münzen Tagesbonus. Rekorde werden pro Spiel gespeichert und vererbt.

![Spielfenster](docs/fenster.png)

## Zeitraffer zum Testen

In den Widget-Einstellungen gibt es neben Echtzeit die Stufen **60×** (ein Leben ≈ 1,4 Tage) und
**1440×** (ein Leben ≈ 1,4 Stunden). Ideal, um alle Stadien und Varianten zu sehen.

## Aufbau

```
package/
  metadata.json            Plasma-Paketbeschreibung
  contents/config/         Einstellungen (main.xml, config.qml)
  contents/ui/
    main.qml               Einstieg (PlasmoidItem)
    logic.js               Spiellogik ohne QML – auch mit Node testbar
    PetModel.qml           Zustand laden/speichern, Takt, Aktionen
    PetWidget.qml          Widget mit Hover-Rahmen und Steuerung
    PetScene.qml           Bühne mit Animationen
    PetCanvas.qml          zeichnet Pets und Eier
    MenuSheet.qml          Futter-, Spiele- und Mehr-Menü
    PetWindow.qml          Fenster für Minispiele und Ahnenbaum
    AncestryView.qml       Ahnenbaum
    games/                 Kuscheln, Hüpfflug, Bubble-Tea-Bar
```

Der Spielstand liegt in der Widget-Konfiguration (`~/.config/plasma-org.kde.plasma.desktop-appletsrc`).
Wird das Widget vom Desktop entfernt, ist auch das Pet weg.

## Git

Falls der Ordner noch kein Git-Repository ist: `bash setup-git.sh` übernimmt die mitgelieferte Historie aus `widget-pet.bundle`.
