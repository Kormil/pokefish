import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0

import "../items"
import "../dialogs"
import "../db"

Page {
    property var card : undefined

    id: page

    SilicaFlickable {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            Image {
                id: bigCardImage
                anchors.fill: parent
                sourceSize.height: parent.height
                sourceSize.width: parent.width
                fillMode: Image.PreserveAspectFit
                source: card ? Qt.resolvedUrl(card.largeImageUrl) : ""
                smooth: true
            }
        }

        VerticalScrollDecorator {}
    }
}
