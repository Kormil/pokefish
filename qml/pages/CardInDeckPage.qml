import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0
import DeckExporter 1.0

import "../items"
import "../db"

Page {
    property string name
    property int deckId
    property var deckModel: undefined
    property bool loaded: false
    property int requestSerial: 0

    id: thisPage
    allowedOrientations: Orientation.All

    DecksDB {
        id: decksdb
    }

    CardsDB {
        id: cardsdb
    }

    DeckExporter {
        id: exporter
    }

    CardListModel {
        id: cardList
    }

    function updateModels(selectedDeckId) {
        if (deckModel) {
            decksdb.dbReadAllDecks(deckModel)
        }

        if (selectedDeckId === deckId) {
            cardsdb.dbGetCardsByDeckId(deckId, cardList)
        }
    }

    Component.onCompleted: {
        cardsdb.dbGetCardsByDeckId(deckId, cardList)
        requestSerial = Controller.searchCardsByIdList(cardList.idList())
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Export")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../pages/DeckExportPage.qml"),
                                                {deckExporter: exporter,
                                                deckName: name})
                    exporter.loadData(cardList)
                }
            }
        }

        SilicaListView {
            id: listView

            enabled: loaded

            model: CardListProxyModel {
                id: cardListProxyModel
                cardListModel: cardList
                sorting: Settings.sortCards
                sortBy: Settings.sortCardsBy
            }

            currentIndex: -1
            anchors.fill: parent
            spacing: Theme.paddingMedium

            header: PageHeader {
                id: title
                title: name
            }

            delegate: ListItem {
                property int indexOfThisDelegate: index

                function remove() {
                    remorseDelete(function() {
                        var cardID = {key: 0}
                        cardsdb.dbGetCardIdByCardApiId(model.card_id, cardID);
                        cardsdb.dbRemoveCardFromDeck(cardID.key, deckId)
                        cardList.remove(index)

                        if (deckModel) {
                            decksdb.dbReadAllDecks(deckModel)
                        }
                    })
                }

                contentHeight: smallCardItem.height
                SmallCardItem {
                    id: smallCardItem
                    card: model
                    howMany: model.counter
                }

                ListView.onRemove: animateRemoval()
                opacity: enabled ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator {}}

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: qsTr("Delete")
                            onClicked: remove()
                        }
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("cards/CardInfoMainPage.qml"), {
                                       current_index: indexOfThisDelegate
                                   })
                }
            }

            VerticalScrollDecorator {}
        }

    }

    ProgressBar {
        id: loading
        anchors.bottom: thisPage.bottom
        width: thisPage.width
        indeterminate: true
    }

    Connections {
        target: Controller
        onSearchStarted: {
            thisPage.loaded = false

            loading.visible = true
        }
    }

    Connections {
        target: Controller
        onSearchWithSerialCompleted: {
            if (requestSerial === serial) {
                thisPage.loaded = true

                loading.visible = false
            }
        }
    }
}
