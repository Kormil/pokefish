import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Nemo.Notifications 1.0

import DeckImporter 1.0
import CardListModel 1.0
import Settings 1.0

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

                loaded = deckImporter.loadDataFromFile(selectedFile)
                if (loaded) {
                    loading.maximumValue = loaded
                    searchedCardListModel.reset()
                    deckImporter.start();
                }
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
                text: qsTr("From clipboard")
                onClicked: {
                    loaded = deckImporter.loadData(Clipboard.text)
                    if (loaded) {
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

            if (deckImporter.downloadErrors) {
                notification.publish()
            }
        }
    }

    Connections {
        target: deckImporter
        onTooManyCardsError: {
            tooManyCardsNotification.publish()
        }
    }

    Notification {
        property int errors: deckImporter.downloadErrors
        id: notification

        summary: qsTr("Errors: ") + errors
        body: qsTr("There was problem with ") + errors + (errors === 1 ? qsTr(" card") : qsTr(" cards"))
        isTransient: true
    }

    Notification {
        id: tooManyCardsNotification

        summary: qsTr("Too many cards")
        body: qsTr("Cannot import more than 30 different cards in one shot")
        isTransient: true
    }
}
