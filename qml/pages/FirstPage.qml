import QtQuick 2.0
import Sailfish.Silica 1.0

import "../items"
import "../dialogs"

Page {
    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About Pokefish")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            anchors.bottom: parent.bottom
            width: page.width
            spacing: Theme.paddingLarge

            Row {
                TextButton {
                    height: page.height / 3
                    width: page.width / 2
                    text: qsTr("Search by name")
                    image: "qrc:///graphics/icons/" + colorScheme + "/pokeball.png"

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../dialogs/SearchByNameDialog.qml"))
                    }
                }

                TextButton {
                    height: page.height / 3
                    width: page.width / 2
                    text: qsTr("Search by series")
                    image: "qrc:///graphics/icons/" + colorScheme + "/set.png"

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("SearchBySetPage.qml"))
                    }
                }
            }

            Row {

                TextButton {
                    height: page.height / 3
                    width: page.width / 2
                    text: qsTr("Rules")
                    image: "qrc:///graphics/icons/" + colorScheme + "/rules.png"
                    onClicked: {
                        Qt.openUrlExternally("https://www.pokemon.com/us/play-pokemon/about/tournaments-rules-and-resources")
                    }
                }

                TextButton {
                    height: page.height / 3
                    width: page.width / 2
                    text: qsTr("Decks")
                    image: "qrc:///graphics/icons/" + colorScheme + "/deck.png"

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("DeckListPage.qml"))
                    }
                }
            }
        }
    }
}
