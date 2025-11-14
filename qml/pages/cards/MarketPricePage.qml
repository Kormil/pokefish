import QtQuick 2.0
import Sailfish.Silica 1.0
import CardListModel 1.0
import Controller 1.0
import Settings 1.0
import MarketPrice 1.0

import "../../items"
import "../../dialogs"
import "../../db"

Item {
    property string card_id
    property var card : undefined
    property var parentPage: undefined
    property int current_index: 0

    property string colorScheme: Theme.colorScheme == Theme.LightOnDark ? "light" : "dark"

    id: marketPricePage

    CardsDB {
        id: cardsdb
    }

    function refresh(card) {
        marketPricePage.card = card
    }

    SilicaFlickable {
        id: mainColumnFlickable
        anchors.fill: parent

        clip: true

        Column {
            id: column
            anchors.fill: parent
            spacing: Theme.paddingMedium

            Item {
                property string market_name: "tcgplayer"
                id: iii
                height: Theme.itemSizeMedium * 1.5 + normal_price.visibleSize + holofoil_price.visibleSize + reverse_holofoil_price.visibleSize
                width: parent.width

                Column {


                    SectionHeader {
                        id: setion_name
                        text: iii.market_name
                    }

                    height: parent.height
                    width: parent.width
                    spacing: Theme.paddingSmall


                    Row {
                        height: Theme.itemSizeSmall
                        width: parent.width

                        Column {
                            width: parent.width / 3
                            height: Theme.itemSizeSmall
                        }


                        Column {
                            width: parent.width / 9 * 2
                            height: Theme.itemSizeSmall

                            Label {
                                text: "low"
                                color: Theme.highlightColor
                                horizontalAlignment: Text.AlignHCenter
                                height: parent.height
                                width: parent.width
                            }
                        }

                        Column {
                            width: parent.width / 9 * 2
                            height: Theme.itemSizeSmall

                            Label {
                                text: "market"
                                color: Theme.highlightColor
                                horizontalAlignment: Text.AlignHCenter
                                height: parent.height
                                width: parent.width
                                font.bold: true
                            }
                        }

                        Column {
                            width: parent.width / 9 * 2
                            height: Theme.itemSizeSmall

                            Label {
                                text: "high"
                                color: Theme.highlightColor
                                horizontalAlignment: Text.AlignHCenter
                                height: parent.height
                                width: parent.width
                            }
                        }
                    }

                    PriceItem {
                        id: normal_price
                        market_name: "tcgplayer"
                        price_name: "normal"
                        price_type: PriceType.Normal
                        width: parent.width
                    }

                    PriceItem {
                        id: holofoil_price
                        market_name: "tcgplayer"
                        price_name: "holofoil"
                        price_type: PriceType.Holofoil
                        width: parent.width
                    }

                    PriceItem {
                        id: reverse_holofoil_price
                        market_name: "tcgplayer"
                        price_name: "reverse holofoil"
                        price_type: PriceType.ReverseHolofoil
                        width: parent.width
                    }

                }
            }

            Item {
                property string market_name: "cardmarket"
                id: item_cardmarket
                height: Theme.itemSizeMedium
                width: parent.width

                Column {

                    SectionHeader {
                        text: item_cardmarket.market_name
                    }

                    height: Theme.itemSizeMedium
                    width: parent.width

                    Row {
                        spacing: Theme.paddingLarge
                        anchors.right: parent.right
                        anchors.margins: Theme.paddingLarge

                        Label {
                            text: "from"
                            color: Theme.primaryColor
                            horizontalAlignment: Text.AlignRight
                            height: Theme.itemSizeSmall
                        }
                        Label {
                            text: marketPricePage.card ? marketPricePage.card.prices("cardmarket", PriceType.Normal, PriceLevel.Low) : ""
                            color: Theme.primaryColor
                            horizontalAlignment: Text.AlignRight
                            height: Theme.itemSizeSmall
                            font.bold: true
                            rightPadding: Theme.paddingMedium
                        }
                    }
                    Row {
                        spacing: Theme.paddingLarge
                        anchors.right: parent.right
                        anchors.margins: Theme.paddingLarge

                        Label {
                            text: "average"
                            color: Theme.primaryColor
                            horizontalAlignment: Text.AlignRight
                            height: Theme.itemSizeSmall
                        }
                        Label {
                            text: marketPricePage.card ? marketPricePage.card.prices("cardmarket", PriceType.Normal, PriceLevel.Market) : ""
                            color: Theme.primaryColor
                            horizontalAlignment: Text.AlignRight
                            height: Theme.itemSizeSmall
                            font.bold: true
                            rightPadding: Theme.paddingMedium
                        }
                    }
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.bottom: bottom_link.top
            height: Theme.itemSizeExtraSmall
            width: page.width

            BackgroundItem {
                height: parent.height
                width: parent.width

            Label {
                text: "Open tcgplayer"
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignRight
                height: parent.height
                width: parent.width
            }

                onClicked: {
                    Qt.openUrlExternally(marketPricePage.card.priceUrl("tcgplayer"))
                }
            }
        }

        Row {
            id: bottom_link
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.bottom: column.bottom
            height: Theme.itemSizeExtraSmall
            width: page.width

            BackgroundItem {
                height: parent.height
                width: parent.width

                Label {
                    text: "Open cardplayer"
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignRight
                    height: parent.height
                    width: parent.width
                }

                onClicked: {
                    Qt.openUrlExternally(marketPricePage.card.priceUrl("cardmarket"))
                }
            }
        }

        VerticalScrollDecorator {
            flickable: mainColumnFlickable
        }
    }

}
