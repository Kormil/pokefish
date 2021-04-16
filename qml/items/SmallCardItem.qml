import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property var card : undefined
    height: nameRow.height + setRow.height + typeRow.height + rarityRow.height
    width: parent.width

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.10) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Row {
        x: Theme.horizontalPageMargin
        spacing: Theme.paddingLarge
        height: nameRow.height + setRow.height * 3

        id: row
        Item {
            height: parent.height
            width: parent.height * 0.8

            Image {
                id: icon
                height: parent.height
                sourceSize.height: parent.height
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl(card.small_image_url)
                smooth: false
                cache: true

                onStatusChanged: {
                    if (icon.status == Image.Ready) {
                        loadingImageIndicator.running = false
                        loadingImageIndicator.visible = false
                    } else if (icon.status == Image.Loading) {
                        loadingImageIndicator.running = true
                        loadingImageIndicator.visible = true
                    }
                }
            }

            BusyIndicator {
                id: loadingImageIndicator
                anchors.centerIn: parent
                running: true
                size: BusyIndicatorSize.Small
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
        }
        Column {
            Row {
                id: nameRow
                spacing: Theme.paddingSmall
                Label {
                    font.pixelSize: Theme.fontSizeMedium
                    text: card.name
                    color: pressed ? Theme.highlightColor : Theme.primaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: card.super_type
                    color: pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: "-"
                    color: pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: card.sub_type
                    color: pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                id: setRow
                spacing: Theme.paddingSmall
                Label {
                    text: qsTr("Set")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: card.set
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                id: typeRow
                visible: card.types.length
                spacing: Theme.paddingSmall
                Label {
                    text: qsTr("Types")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: card.types
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                id: rarityRow
                spacing: Theme.paddingSmall
                Label {
                    text: qsTr("Rarity")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: card.rarity
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
        }
    }
}
