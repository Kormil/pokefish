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
                    pageStack.push(Qt.resolvedUrl("CardInfoPage.qml"), {cardId: model.card_id, parentPage: thisPage})
                    Controller.searchCardsByIdList(model.card_id)
                }
            }

            VerticalScrollDecorator {}
        }

    }
}
