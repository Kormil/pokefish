import QtQuick 2.0
import Sailfish.Silica 1.0

import "../db"
import "../items"

Dialog {
    id: page
    property int choosed: -1;
    property int highlight: -1;
    property int card;

    DecksDB {
        id: decksdb
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All


    function initialize() {
        deckList.clear()
        decksdb.dbReadAllDecks(deckList)
        decksdb.dbNumberOfCards(deckList, card)
    }


    SilicaFlickable {
        anchors.fill: parent

            DialogHeader {
                id: header
            }

            ListModel {
                id: deckList
            }

            SilicaListView {

                id: listView
                anchors.top: header.bottom
                height: parent.height
                width: parent.width

                model: deckList

                delegate: ListItem {
                    DeckItem {
                    }

                    id: delegate
                    _showPress: index == page.highlight

                    onClicked: {
                        page.highlight = index
                        page.choosed = deckList.get(index).id;
                    }
                }
                VerticalScrollDecorator {}
            }
    }

}
