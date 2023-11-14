import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import DeckImporter 1.0
import CardListModel 1.0

import "../items"
import "../db"

Dialog {
    id: deckImportDialog

    property string text: ""
    property string selectedFile: ""
    property int loaded: 0
    property var root

    allowedOrientations: Orientation.All
    canAccept: loaded > 0
    acceptDestination: Qt.resolvedUrl("../dialogs/CreateDeckDialog.qml")

    CardsDB {
        id: cardsdb
    }

    onAcceptPendingChanged: {
        if (acceptPending) {
            acceptDestinationInstance.acceptDestination = root
            acceptDestinationInstance.acceptDestinationAction = PageStackAction.Pop

            acceptDestinationInstance.accepted.connect(function() {
                if (acceptDestinationInstance.deckId !== -1) {
                    cardsdb.dbAddCardListToDeck(deckImporter.importedCards, acceptDestinationInstance.deckId)
                    root.reloadDecks()
                }
            })
        }
    }

    Component.onCompleted: {
        searchedCardListModel.reset()
    }

    DeckImporter {
        id: deckImporter
    }

    Component {
        id: filePickerPage
        FilePickerPage {
            nameFilters: [ '*.txt' ]
            onSelectedContentPropertiesChanged: {
                selectedFile = selectedContentProperties.filePath
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("From file")
                onClicked: {
                    pageStack.push(filePickerPage)
                }
            }

            MenuItem {
                //visible: Clipboard.hasText
                text: qsTr("From clipboard")
                onClicked: {
                    Clipboard.text = "Pokemon - 15
2 Lillipup SUM 103"

                    loaded = deckImporter.loadData(Clipboard.text)

                    console.debug(loaded)

                    if (loaded) {
                        //get pokemon
                        //get trainer
                        //get energy

                        console.debug("Start")
                        loading.maximumValue = loaded
                        searchedCardListModel.reset()
                        deckImporter.start();
                    }
                }
            }
        }

        Column {
            anchors.fill: parent
            DialogHeader { }

        }

        SilicaListView {
            id: listView

            model: CardListProxyModel {
                id: cardListProxyModel
                cardListModel: deckImporter.importedCards
                sorting: Settings.sortCards
                sortBy: Settings.sortCardsBy
            }

            currentIndex: -1
            anchors.fill: parent
            spacing: Theme.paddingMedium

            header: PageHeader {
                id: title
                title: qsTr("Results")
            }

            delegate: ListItem {
                contentHeight: smallCardItem.height
                SmallCardItem {
                    id: smallCardItem
                    card: model
                    howMany: counter
                }
            }

            VerticalScrollDecorator {}
        }
    }

    ProgressBar {
        id: loading
        anchors.bottom: parent.bottom
        width: parent.width
        maximumValue: 100
        value: deckImporter.alreadyDownloaded
        valueText: ""
        label: "Loading"
        visible: false
//        Timer {
//            interval: 100
//            repeat: true
//            onTriggered: progressBar.value = (progressBar.value + 1) % 100
//            running: false
//        }
    }

    Connections {
        target: deckImporter
        onImportStarted: {
            loading.enabled = true
            loading.visible = true
        }
    }

    Connections {
        target: deckImporter
        onImportedAllCards: {
            loading.enabled = false
            loading.visible = false
        }
    }
}
