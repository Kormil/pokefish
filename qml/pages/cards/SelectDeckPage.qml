import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../db"
import "../../items"

Item {
    id: page
    property int choosed: -1;
    property int highlight: -1;
    property var card : undefined
    property string card_id

    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"

    CardsDB {
        id: cardsdb
    }

    DecksDB {
        id: decksdb
    }

    function refresh(card) {
        page.card = card

        deckList.clear()
        decksdb.dbReadAllDecks(deckList)

        var cardID = {key: 0}
        cardsdb.dbGetCardIdByCardApiId(card.id, cardID);
        card_id = cardID.key

        decksdb.dbNumberOfCards(deckList, card_id)
    }

    PageHeader {
        id: header
        title: qsTr("Decks")
    }

    SilicaFlickable {
        id: mainColumnFlickable
        anchors.top: header.bottom
        width: parent.width
        height: page.height - bottombar.height - Theme.paddingMedium * 2
        clip: true

        ListModel {
            id: deckList
        }

        SilicaListView {
            id: listView
            height: parent.height
            width: parent.width
            model: deckList

            delegate: AddToDeckItem {
                property int deck_id: model.id
                card_id: card_id
            }
        }

        VerticalScrollDecorator {
            flickable: mainColumnFlickable
        }
    }
}
