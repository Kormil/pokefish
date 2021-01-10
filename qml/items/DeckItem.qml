import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"
    property bool showCard: true

    height: Theme.itemSizeMedium
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter

    Label {
        x: Theme.horizontalPageMargin
        text: model.name
        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
        truncationMode: TruncationMode.Fade
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        id: deckData
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Image {
            id: cardsNumberImage
            height: parent.height
            source: "qrc:///graphics/icons/" + colorScheme + "/card.png"
            fillMode: Image.PreserveAspectFit
            visible: showCard
        }

        Label {
            id: cardsNumberLabel
            anchors.verticalCenter: parent.verticalCenter
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            text: model.card
            visible: showCard
        }

        Image {
            id: allCardsNumberImage
            height: parent.height
            source: "qrc:///graphics/icons/" + colorScheme + "/deck.png"
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: allCardsNumberLabel
            text: model.cards
            anchors.verticalCenter: parent.verticalCenter
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
        }

    }
}
