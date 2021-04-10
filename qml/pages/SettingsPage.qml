import QtQuick 2.0
import Sailfish.Silica 1.0
import Settings 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: qsTr("Settings")
            }

            TextSwitch {
                id: sortCardsTextSwitch
                text: qsTr("Sort cards")
                checked: Settings.sortCards

                onCheckedChanged: {
                    Settings.sortCards = checked
                }
            }

            ComboBox {
                width: parent.width
                label: qsTr("Sort by")
                currentIndex: Settings.sortCardsBy
                enabled: sortCardsTextSwitch.checked

                menu: ContextMenu {
                    MenuItem { text: qsTr("Name") }
                    MenuItem { text: qsTr("Types") }
                    MenuItem { text: qsTr("Supertype") }
                    MenuItem { text: qsTr("National pokedex number") }
                }

                //description: qsTr("Works only with the screen on. If the screen is off, the program will automatically look for the nearest station after turning the screen on.")

                onCurrentIndexChanged: {
                    Settings.sortCardsBy = currentIndex
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
