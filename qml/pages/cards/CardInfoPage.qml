import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0

import "../../items"
import "../../dialogs"
import "../../db"

Item {
    property var card : undefined
    property string card_id
    property var parentPage: undefined
    property int current_index: 0

    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"

    id: cardInfoPage

    CardsDB {
        id: cardsdb
    }

    SilicaListView {
        id: listView

        currentIndex: current_index

        anchors.fill: parent
        clip: true
        snapMode: ListView.SnapOneItem
        orientation: ListView.HorizontalFlick
        highlightRangeMode: ListView.StrictlyEnforceRange
        cacheBuffer: width

        model: CardListProxyModel {
            id: cardListProxyModel
            cardListModel: searchedCardListModel
            sorting: Settings.sortCards
            sortBy: Settings.sortCardsBy
        }

        onCurrentItemChanged: {
            cardInfoPage.card_id = currentItem.card_id
            current_index = listView.currentIndex

            card = searchedCardListModel.getRaw(currentItem.card_id)
        }

        delegate:
        SilicaFlickable {
            property var card: searchedCardListModel.getRaw(model.card_id)
            property string card_id: model.card_id

            id: mainColumnFlickable
            width: cardInfoPage.width
            contentHeight: mainColumn.height + 2 * Theme.paddingMedium
            height: cardInfoPage.height
            clip: true

            Column {
                id: mainColumn
                width: parent.width - 2 * Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                y: Theme.paddingMedium
                spacing: Theme.paddingMedium
                visible: true

                Column {
                    id: nameColumn
                    anchors.right: parent.right

                    Label {
                        id: title
                        text: model.name
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.highlightColor
                        anchors.right: parent.right
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: Theme.paddingMedium

                        Label {
                            text: model.super_type
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label {
                            text: model.sub_type
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
                            text: model.hp
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Image {
                            id: weaknessIcon
                            fillMode: Image.PreserveAspectFit
                            height: parent.height - Theme.paddingMedium
                            source: "qrc:///graphics/types/"+model.types+".png"
                            smooth: false
                            cache: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                BackgroundItem {
                    id: cardItem
                    height: cardInfoPage.height / 2
                    width: cardInfoPage.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: Theme.horizontalPageMargin

                    Image {
                        id: bigCardImage
                        anchors.fill: parent
                        sourceSize.height: parent.height
                        sourceSize.width: cardInfoPage.width * 0.7
                        fillMode: Image.PreserveAspectFit
                        source: card ? Qt.resolvedUrl(Settings.alwaysLargeImages ? model.large_image_url : model.small_image_url) : ""

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
                        pageStack.push(Qt.resolvedUrl("../BigCardPage.qml"), {card: card})
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

                    visible: model.rules_size > 0
                }

                Repeater {
                    model: card.rules_size

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
                    width: cardInfoPage.width
                    color: Theme.secondaryColor
                    cache: false
                    anchors.horizontalCenter: parent.horizontalCenter
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
            card = searchedCardListModel.getRaw(cardId)
            cardsdb.dbUpdateCard(card, cardId)
        }
    }

}
