import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: item

    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"
    property bool showCard: true
    property int card_id : undefined

    height: Theme.itemSizeMedium * 1.1
    width: parent.width

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.10) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Label {
        x: Theme.horizontalPageMargin
        text: model.name
        color: Theme.primaryColor
        truncationMode: TruncationMode.Fade
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        height: parent.height
    }

    Row {
        id: deckData
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        IconButton {
            icon.source: "image://theme/icon-splus-remove"
            anchors.verticalCenter: parent.verticalCenter
            visible: model.card > 0

            onClicked: {
                var card_counter = {value: 0}
                cardsdb.dbRemoveCardFromDeck(card_id, deck_id, card_counter)
                model.card = parseInt(card_counter.value)

                var all_card_counter = {value: 0}
                decksdb.dbCountCardsInDeck(deck_id, all_card_counter);
                model.cards = parseInt(all_card_counter.value)
            }
        }

        Column {
            height: item.height
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: cardsNumberLabel
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                text: model.card
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: allCardsNumberLabel
                text: model.cards ? model.cards : "0"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter

            }
        }

            IconButton {
                icon.source: "image://theme/icon-splus-add"
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    var card_id = {value: 0}
                    var card_counter = {value: 0}
                    cardsdb.dbAddCardToDeck(page.card, deck_id, card_id, card_counter)
                    model.card = parseInt(card_counter.value)
                    item.card_id = parseInt(card_id.value)

                    var all_card_counter = {value: 0}
                    decksdb.dbCountCardsInDeck(deck_id, all_card_counter);
                    model.cards = parseInt(all_card_counter.value)
                }
            }

    }
}
