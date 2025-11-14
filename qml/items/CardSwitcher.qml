import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import CardListModel 1.0

Item {
    property int big_card_height: parent.height / 2
    property int big_card_width: parent.width * 0.7

    property var main_card : undefined

    id: cardsSwitcher
    width: parent.width
    height: big_card_height

    Item {
        height: big_card_height / 2
        width: big_card_width
        anchors.right: bigCard.left
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: imagePrev
            anchors.fill: parent
            sourceSize.height: parent.height
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(prevcard.smallImageUrl)
            horizontalAlignment: Image.AlignRight
            anchors.right: parent.right
        }

        Desaturate {
            anchors.fill: imagePrev
            source: imagePrev
            desaturation: 0.8
        }
    }

    Item {
        id: bigCard
        height: big_card_height
        width: big_card_width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: bigCardImage
            anchors.fill: parent
            sourceSize.height: big_card_height
            sourceSize.width: big_card_width
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(main_card.smallImageUrl)
            //visible: false
        }

        Desaturate {
            id: bigCardDesaturate
            anchors.fill: bigCard
            source: bigCard
            desaturation: 0.0
            cached: true
        }
    }

    Item {
        height: big_card_height / 2
        width: big_card_width
        anchors.left: bigCard.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: imageNext
            anchors.fill: parent
            sourceSize.height: parent.height
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(nextcard.smallImageUrl)
            horizontalAlignment: Image.AlignLeft
            anchors.left: parent.left
        }

        Desaturate {
            anchors.fill: imageNext
            source: imageNext
            desaturation: 0.8
        }
    }

    MouseArea {
        id: mouseArea

        width: parent.width
        height: parent.height
        anchors.centerIn: parent

        drag.axis: Drag.XAxis
        drag.target: bigCard

        property real xclick: 0

        onPressed: {
            bigCard.smooth = false
            xclick = mapToItem(cardsSwitcher, mouseX, mouseY).x
        }

        onReleased: {
            bigCard.smooth = true
            bigCard.height = big_card_height
            bigCardDesaturate.desaturation = 0.0
        }

        onMouseXChanged: {
            if(drag.active){
                var globalPosition = mapToItem(cardsSwitcher, mouseX, mouseY)
                var dx = xclick - globalPosition.x
                var dx_abs = Math.abs(dx)
                xclick = globalPosition.x

                var lowers = false

                if (dx > 0 && xclick < parent.width / 2) {
                    lowers = true
                } else if (dx < 0 && xclick > parent.width / 2) {
                    lowers = true
                }

                if (lowers) {
                    dx_abs = -dx_abs
                }

                bigCard.height = bigCard.height + dx_abs

                //var dx_abs_desaturation = dx_abs / 1000.0
                //bigCardDesaturate.desaturation = bigCardDesaturate.desaturation  - dx_abs_desaturation
                //console.debug(bigCardDesaturate.desaturation)

                if(bigCard.height < big_card_height / 2) {
                    bigCard.height = big_card_height / 2
                } else if(bigCard.height > big_card_height) {
                    bigCard.height = big_card_height
                }
            }
        }
    }
}
