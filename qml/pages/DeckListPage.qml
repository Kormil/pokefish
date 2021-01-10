import QtQuick 2.0
import Sailfish.Silica 1.0

import "../db"
import "../dialogs"
import "../items"

Page {
    id: page
    DecksDB {
        id: decksdb
    }
    CardsDB {
        id: cardsdb
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        deckList.clear()
        decksdb.dbReadAllDecks(deckList)
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Add new deck")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/CreateDeckDialog.qml"))

                    dialog.accepted.connect(function() {
                        deckList.clear()
                        decksdb.dbReadAllDecks(deckList)
                    })
                }
            }
        }

        ListModel {
            id: deckList
        }

        SilicaListView {
            id: listView

            model: deckList

            anchors.fill: parent

            header: PageHeader {
                title: qsTr("Decks")
            }

            delegate: ListItem {

                function remove() {
                    remorseDelete(function() {
                        var choosed = deckList.get(index).id;
                        deckList.remove(index)
                        decksdb.dbRemoveDeck(choosed)
                    })
                }

                function edit() {
                    var choosed = deckList.get(index).id;
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/EditDeckDialog.qml"), {deckId: choosed})

                    dialog.accepted.connect(function() {
                        deckList.clear()
                        decksdb.dbReadAllDecks(deckList)
                    })
                }

                DeckItem {
                    id: delegate
                    showCard: false
                }

                ListView.onRemove: animateRemoval()
                opacity: enabled ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator {}}

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: qsTr("Rename")
                            onClicked: edit()
                        }
                        MenuItem {
                            text: qsTr("Delete")
                            onClicked: remove()
                        }
                    }
                }

                onClicked: {
                    var choosed = deckList.get(index).id;
                    pageStack.push(Qt.resolvedUrl("CardInDeckPage.qml"), {name: model.name, deckId: choosed, deckModel: deckList})
                }
            }
            VerticalScrollDecorator {}
        }
    }

}
