import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0

import "../items"
import "../dialogs"
import "../db"

Page {
    property var card : undefined
    property string cardId
    property var parentPage: undefined

    id: page

    allowedOrientations: Orientation.All

    CardsDB {
        id: cardsdb
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 2 * Theme.paddingMedium

        PullDownMenu {
            MenuItem {
                text: qsTr("Add to deck")
                onClicked: {
                    var cardID = {key: 0}
                    cardsdb.dbGetCardIdByCardApiId(card.id, cardID);
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/SelectDeckDialog.qml"), {card: cardID.key})
                    dialog.initialize()

                    dialog.accepted.connect(function() {
                        if (dialog.choosed !== -1) {
                            cardsdb.dbAddCard(card, dialog.choosed)

                            if (parentPage) {
                                parentPage.updateModels(dialog.choosed)
                            }
                        }
                    })
                }
            }
        }

        Column {
            id: mainColumn
            width: parent.width - 2 * Theme.horizontalPageMargin
            x: Theme.horizontalPageMargin
            y: Theme.paddingMedium
            spacing: Theme.paddingMedium
            visible: true

            Column {
                anchors.right: parent.right

                Label {
                    id: title
                    text: card ? card.name : ""
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.highlightColor
                    anchors.right: parent.right
                }

                Row {
                    anchors.right: parent.right
                    spacing: Theme.paddingMedium

                    Label {
                        text: card ? card.supertype : ""
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    Label {
                        text: card ? card.subtype : ""
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    Label {
                        text: "HP"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        anchors.bottom: parent.bottom
                        visible: hpLabel.text.length
                    }
                    Label {
                        id: hpLabel
                        text: card ? card.hp : ""
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    Image {
                        id: weaknessIcon
                        fillMode: Image.PreserveAspectFit
                        height: parent.height - Theme.paddingMedium
                        source: "qrc:///graphics/types/"+card.type+".png"
                        smooth: false
                        cache: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            BackgroundItem {
                id: cardItem
                height: page.height / 2
                width: page.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.horizontalPageMargin

                Image {
                    id: bigCardImage
                    anchors.fill: parent
                    sourceSize.height: parent.height
                    sourceSize.width: page.width * 0.7
                    fillMode: Image.PreserveAspectFit
                    source: card ? Qt.resolvedUrl(Settings.alwaysLargeImages ? card.largeImageUrl : card.smallImageUrl) : ""

                     onStatusChanged: {
                         if (bigCardImage.status == Image.Ready) {
                             loadingImageIndicator.running = false
                             loadingImageIndicator.visible = false
                         } else if (bigCardImage.status == Image.Loading) {
                             loadingImageIndicator.running = true
                             loadingImageIndicator.visible = true
                         }
                     }
                }

                BusyIndicator {
                    id: loadingImageIndicator
                    anchors.centerIn: parent
                    running: true
                    size: BusyIndicatorSize.Medium
                    anchors.verticalCenter: parent.verticalCenter
                    visible: false
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("BigCardPage.qml"), {card: card})
                }
            }

            Row {
                anchors.right: parent.right
                spacing: Theme.paddingMedium
                Label {
                    id: typeLabel
                    text: qsTr("Rules")
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignRight
                }
                visible: card ? card.rulesSize : false
            }

            Repeater {
                model: card ? card.rulesSize : 0

                AdditionalTextItem {
                    id: additionalTextInfo
                    text: card.rule(index)
                }
            }

            Repeater {
                model: card ? card.abilitiesSize : 0

                AbilityInfo {
                    id: abilityInfo

                    visible: true
                    name: card.ability(index).name
                    type: card.ability(index).type
                    text: card.ability(index).text
                }
            }

            Repeater {
                model: card ? card.attackSize : 0

                AtackInfo {
                    id: atackInfo

                    visible: true
                    name: card.attack(index).name
                    damage: card.attack(index).damage
                    text: card.attack(index).text
                    cost: card.attack(index).costList
                }
            }

            GlassItem {
                id: effect
                height: Theme.paddingMedium
                width: page.width
                color: Theme.secondaryColor
                cache: false
                visible: card.weakness || card.resistances || card.retreatCost
            }

            Row {
                width: parent.width
                visible: card.weakness || card.resistances

                WeaknessInfoItem {
                    name: "weakness"
                    type: card.weakness
                    value: card.weaknessValue

                    width: parent.width / 2
                }

                WeaknessInfoItem {
                    name: "resistance"
                    type: card.resistances
                    value: card.resistancesValue

                    width: parent.width / 2
                }
            }

            Label {
                id: nameLabel
                text: "retreat"
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
                visible: card.retreatCost
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall

                Repeater {
                    model: card && card.hasRetreatCost ? card.retreatCost : 0

                    Image {
                        fillMode: Image.PreserveAspectFit
                        height: nameLabel.height
                        source: "qrc:///graphics/types/Colorless.png"
                        smooth: false
                        cache: true
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        id: loading
        anchors.centerIn: parent
        running: true
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    Connections {
        target: Controller
        onSearchStarted: {
            loading.enabled = true
            loading.visible = true
            loading.running = true

            mainColumn.visible = false
        }
    }

    Connections {
        target: Controller
        onSearchCompleted: {
            loading.enabled = false
            loading.visible = false
            loading.running = false

            mainColumn.visible = true
            card = searchedCardListModel.card(cardId)
            cardsdb.dbUpdateCard(card, cardId)
        }
    }

}
